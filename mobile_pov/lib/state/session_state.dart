import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/frame_model.dart';
import '../models/sticker_model.dart';
import '../services/api_service.dart';

class MobileSessionData {
  final int? sessionId;
  final String? sessionCode;
  final FrameModel? frame;
  final List<PlacedSticker> stickers;
  final List<String> localPhotos; // file paths lokal
  final List<int> selectedIndices; // index foto yang dipilih untuk cetak/unduh
  final int? printOutputId;

  const MobileSessionData({
    this.sessionId,
    this.sessionCode,
    this.frame,
    this.stickers = const [],
    this.localPhotos = const [],
    this.selectedIndices = const [],
    this.printOutputId,
  });

  MobileSessionData copyWith({
    int? sessionId,
    String? sessionCode,
    FrameModel? frame,
    List<PlacedSticker>? stickers,
    List<String>? localPhotos,
    List<int>? selectedIndices,
    int? printOutputId,
  }) => MobileSessionData(
        sessionId: sessionId ?? this.sessionId,
        sessionCode: sessionCode ?? this.sessionCode,
        frame: frame ?? this.frame,
        stickers: stickers ?? this.stickers,
        localPhotos: localPhotos ?? this.localPhotos,
        selectedIndices: selectedIndices ?? this.selectedIndices,
        printOutputId: printOutputId ?? this.printOutputId,
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
      // place random position
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

  Future<void> uploadAll() async {
    for (int i = 0; i < state.localPhotos.length; i++) {
      await _api.uploadPhoto(state.sessionId!, i, state.localPhotos[i]);
    }
  }

  void toggleSelect(int idx) {
    final s = [...state.selectedIndices];
    if (s.contains(idx)) {
      s.remove(idx);
    } else {
      s.add(idx);
    }
    state = state.copyWith(selectedIndices: s);
  }

  Future<int> render() async {
    await _api.updateStatus(state.sessionId!, 'rendering');
    await _api.renderOutput(state.sessionId!);
    for (var i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 2));
      final res = await _api.getOutputs(state.sessionId!);
      final outs = res.data['data'] as List;
      final printOut = outs.cast<Map?>().firstWhere((o) => o != null && o['type'] == 'print_image', orElse: () => null);
      if (printOut != null) {
        state = state.copyWith(printOutputId: printOut['id'] as int);
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
