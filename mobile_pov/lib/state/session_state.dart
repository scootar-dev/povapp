import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage.dart';
import '../models/frame_model.dart';
import '../models/sticker_model.dart';
import '../services/api_service.dart';

class MobileSessionData {
  final int? sessionId;
  final String? sessionCode;
  final FrameModel? frame;
  final List<PlacedSticker> stickers;
  final List<String> localPhotos;
  final List<int> selectedIndices;
  final int? printOutputId;
  final int? digitalOutputId;
  final String? printPath;
  final String? digitalPath;

  const MobileSessionData({
    this.sessionId,
    this.sessionCode,
    this.frame,
    this.stickers = const [],
    this.localPhotos = const [],
    this.selectedIndices = const [],
    this.printOutputId,
    this.digitalOutputId,
    this.printPath,
    this.digitalPath,
  });

  MobileSessionData copyWith({
    int? sessionId,
    String? sessionCode,
    FrameModel? frame,
    List<PlacedSticker>? stickers,
    List<String>? localPhotos,
    List<int>? selectedIndices,
    int? printOutputId,
    int? digitalOutputId,
    String? printPath,
    String? digitalPath,
  }) => MobileSessionData(
        sessionId: sessionId ?? this.sessionId,
        sessionCode: sessionCode ?? this.sessionCode,
        frame: frame ?? this.frame,
        stickers: stickers ?? this.stickers,
        localPhotos: localPhotos ?? this.localPhotos,
        selectedIndices: selectedIndices ?? this.selectedIndices,
        printOutputId: printOutputId ?? this.printOutputId,
        digitalOutputId: digitalOutputId ?? this.digitalOutputId,
        printPath: printPath ?? this.printPath,
        digitalPath: digitalPath ?? this.digitalPath,
      );
}

class MobileSessionNotifier extends StateNotifier<MobileSessionData> {
  MobileSessionNotifier() : super(const MobileSessionData());
  final _api = ApiService();

  void selectFrame(FrameModel f) => state = state.copyWith(frame: f);

  void toggleSticker(StickerModel s) {
    final exists = state.stickers.any((p) => p.sticker.id == s.id);
    if (exists) {
      state = state.copyWith(stickers: state.stickers.where((p) => p.sticker.id != s.id).toList());
    } else {
      final dx = 0.2 + (state.stickers.length * 0.15) % 0.6;
      final dy = 0.2 + (state.stickers.length * 0.12) % 0.6;
      state = state.copyWith(stickers: [...state.stickers, PlacedSticker(sticker: s, dx: dx, dy: dy)]);
    }
  }

  void updateStickerPos(int idx, double dx, double dy) {
    final list = [...state.stickers];
    list[idx] = PlacedSticker(sticker: list[idx].sticker, dx: dx, dy: dy, scale: list[idx].scale);
    state = state.copyWith(stickers: list);
  }

  Future<void> startSession() async {
    if (state.frame == null) throw Exception('Pilih frame dulu');
    final res = await _api.createSession(frameId: state.frame!.id);
    final d = res.data['data'];
    state = state.copyWith(sessionId: d['id'], sessionCode: d['session_code']);
    await _api.updateStatus(state.sessionId!, 'shooting');
  }

  void addLocalPhoto(String path) => state = state.copyWith(localPhotos: [...state.localPhotos, path]);

  void toggleSelect(int idx) {
    final s = [...state.selectedIndices];
    if (s.contains(idx)) {
      s.remove(idx);
    } else {
      s.add(idx);
    }
    state = state.copyWith(selectedIndices: s);
  }

  /// Unggah hanya foto yang dipilih, dipetakan berurutan ke slot frame.
  Future<void> uploadSelected() async {
    if (state.sessionId == null) throw Exception('Sesi belum dimulai');
    final indices = [...state.selectedIndices]..sort();
    if (indices.isEmpty) throw Exception('Pilih minimal 1 foto');

    final slots = state.frame?.photoCount ?? indices.length;
    if (indices.length < slots) {
      throw Exception('Pilih $slots foto dulu untuk frame ini');
    }

    for (var slot = 0; slot < slots && slot < indices.length; slot++) {
      await _api.uploadPhoto(state.sessionId!, slot, state.localPhotos[indices[slot]]);
    }
  }

  Future<int> render() async {
    final sid = state.sessionId;
    if (sid == null) throw Exception('Sesi belum dimulai');

    await _api.updateStatus(sid, 'rendering');

    final placements = <Map<String, dynamic>>[];
    for (final p in state.stickers) {
      final stickerId = int.tryParse(p.sticker.id);
      if (stickerId == null) continue;
      placements.add({
        'sticker_id': stickerId,
        'x': p.dx.clamp(0.0, 0.95),
        'y': p.dy.clamp(0.0, 0.95),
        'size': (0.18 * p.scale).clamp(0.05, 1.0),
        'rotation': 0,
      });
    }
    await _api.saveStickers(sid, placements);

    await _api.renderOutput(sid);

    for (var i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 2));
      final res = await _api.getOutputs(sid);
      final outs = (res.data['data'] as List).cast<Map<String, dynamic>>();

      final printMatches = outs.where((o) => o['type'] == 'print_image').toList();
      final digitalMatches = outs.where((o) => o['type'] == 'digital_image').toList();
      final printOut = printMatches.isEmpty ? null : printMatches.first;
      final digitalOut = digitalMatches.isEmpty ? null : digitalMatches.first;

      if (printOut != null) {
        state = state.copyWith(
          printOutputId: printOut['id'] as int,
          printPath: printOut['file_path'] as String?,
          digitalOutputId: digitalOut?['id'] as int?,
          digitalPath: digitalOut?['file_path'] as String?,
        );
        return printOut['id'] as int;
      }
    }
    throw Exception('Render timeout — cek queue worker');
  }

  Future<void> complete() async {
    if (state.sessionId != null) await _api.complete(state.sessionId!);
  }

  void reset() => state = const MobileSessionData();
}

final mobileSessionProvider = StateNotifierProvider<MobileSessionNotifier, MobileSessionData>((ref) => MobileSessionNotifier());

final framesProvider = FutureProvider<List<FrameModel>>((ref) async {
  final res = await ApiService().getFrames();
  return (res.data['data'] as List).map((f) => FrameModel.fromJson(f)).toList();
});

final stickersProvider = FutureProvider<List<StickerModel>>((ref) async {
  final res = await ApiService().getStickers();
  return (res.data['data'] as List).map((s) => StickerModel.fromJson(s)).toList();
});

/// Base URL runtime untuk membangun URL file storage & link download.
final baseUrlProvider = FutureProvider<String>((ref) => MobileStorage.getBaseUrl());
