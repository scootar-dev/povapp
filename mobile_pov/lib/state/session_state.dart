import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage.dart';
import '../models/frame_model.dart';
import '../models/sticker_model.dart';
import '../services/api_service.dart';
import '../services/composite_render_service.dart';

class MobileSessionData {
  final int? sessionId;
  final String? sessionCode;
  final FrameModel? frame;
  final List<PlacedSticker> stickers;
  final List<String> localPhotos;
  final int? printOutputId;
  final int? digitalOutputId;
  final String? printPath;
  final String? digitalPath;
  final String? localCompositePath;

  const MobileSessionData({
    this.sessionId,
    this.sessionCode,
    this.frame,
    this.stickers = const [],
    this.localPhotos = const [],
    this.printOutputId,
    this.digitalOutputId,
    this.printPath,
    this.digitalPath,
    this.localCompositePath,
  });

  MobileSessionData copyWith({
    int? sessionId,
    String? sessionCode,
    FrameModel? frame,
    List<PlacedSticker>? stickers,
    List<String>? localPhotos,
    int? printOutputId,
    int? digitalOutputId,
    String? printPath,
    String? digitalPath,
    String? localCompositePath,
  }) =>
      MobileSessionData(
        sessionId: sessionId ?? this.sessionId,
        sessionCode: sessionCode ?? this.sessionCode,
        frame: frame ?? this.frame,
        stickers: stickers ?? this.stickers,
        localPhotos: localPhotos ?? this.localPhotos,
        printOutputId: printOutputId ?? this.printOutputId,
        digitalOutputId: digitalOutputId ?? this.digitalOutputId,
        printPath: printPath ?? this.printPath,
        digitalPath: digitalPath ?? this.digitalPath,
        localCompositePath: localCompositePath ?? this.localCompositePath,
      );
}

class MobileSessionNotifier extends StateNotifier<MobileSessionData> {
  MobileSessionNotifier()
      : super(MobileSessionData(frame: FrameModel.defaultFrames.first));

  final _api = ApiService();

  void selectFrame(FrameModel f) => state = state.copyWith(frame: f);

  void addSticker(StickerModel s) {
    final dx = 0.35 + (state.stickers.length * 0.12) % 0.35;
    final dy = 0.30 + (state.stickers.length * 0.10) % 0.35;
    state = state.copyWith(
      stickers: [
        ...state.stickers,
        PlacedSticker(sticker: s, dx: dx, dy: dy),
      ],
    );
  }

  void removeSticker(int idx) {
    if (idx >= 0 && idx < state.stickers.length) {
      final list = [...state.stickers];
      list.removeAt(idx);
      state = state.copyWith(stickers: list);
    }
  }

  void updateStickerPos(int idx, double dx, double dy) {
    if (idx < 0 || idx >= state.stickers.length) return;
    final list = [...state.stickers];
    list[idx] = PlacedSticker(
      sticker: list[idx].sticker,
      dx: dx.clamp(0.0, 0.85),
      dy: dy.clamp(0.0, 0.85),
      scale: list[idx].scale,
    );
    state = state.copyWith(stickers: list);
  }

  Future<void> startSession() async {
    if (state.frame == null) {
      state = state.copyWith(frame: FrameModel.defaultFrames.first);
    }

    try {
      if (state.frame!.id > 0) {
        final res = await _api.createSession(frameId: state.frame!.id);
        final d = res.data['data'];
        state = state.copyWith(
          sessionId: d['id'],
          sessionCode: d['session_code'],
          localPhotos: [],
        );
        await _api.updateStatus(state.sessionId!, 'shooting');
        return;
      }
    } catch (_) {
      // Backend offline / frame preset lokal
    }

    // Fallback ID & Session Code lokal
    final localCode =
        'POV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    state = state.copyWith(
      sessionId: DateTime.now().millisecondsSinceEpoch,
      sessionCode: localCode,
      localPhotos: [],
    );
  }

  void addLocalPhoto(String path) =>
      state = state.copyWith(localPhotos: [...state.localPhotos, path]);

  void retakePhoto(int slot, String path) {
    if (slot >= 0 && slot < state.localPhotos.length) {
      final list = [...state.localPhotos];
      list[slot] = path;
      state = state.copyWith(localPhotos: list);
    } else {
      addLocalPhoto(path);
    }
  }

  /// Render komposit instan di perangkat (lokal) dan sinkronisasi ke server jika online
  Future<String> render() async {
    final frame = state.frame ?? FrameModel.defaultFrames.first;

    // 1. Render Komposit Lokal (Instan di HP, pasti berhasil)
    final localPath = await CompositeRenderService.renderAndSave(
      frame: frame,
      photoPaths: state.localPhotos,
      stickers: state.stickers,
    );

    state = state.copyWith(
      localCompositePath: localPath,
      printPath: localPath,
      digitalPath: localPath,
    );

    // 2. Coba Sinkronisasi ke Server (Optional / Non-blocking)
    final sid = state.sessionId;
    if (sid != null && state.frame != null && state.frame!.id > 0) {
      try {
        final slots = frame.photoCount;
        for (var slot = 0; slot < slots && slot < state.localPhotos.length; slot++) {
          await _api.uploadPhoto(sid, slot, state.localPhotos[slot]);
        }

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
        final renderRes = await _api.renderOutput(sid);

        final outs = (renderRes.data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        final printOut = outs.firstWhere((o) => o['type'] == 'print_image', orElse: () => {});
        final digitalOut = outs.firstWhere((o) => o['type'] == 'digital_image', orElse: () => {});

        if (printOut.isNotEmpty) {
          state = state.copyWith(
            printOutputId: printOut['id'] as int?,
            printPath: printOut['file_path'] as String?,
            digitalOutputId: digitalOut['id'] as int?,
            digitalPath: digitalOut['file_path'] as String?,
          );
        }
      } catch (_) {
        // Jika server bermasalah, localCompositePath tetap dipakai 100%
      }
    }

    return localPath;
  }

  Future<void> complete() async {
    if (state.sessionId != null) {
      try {
        await _api.complete(state.sessionId!);
      } catch (_) {}
    }
  }

  void reset() => state = MobileSessionData(frame: FrameModel.defaultFrames.first);
}

final mobileSessionProvider =
    StateNotifierProvider<MobileSessionNotifier, MobileSessionData>(
        (ref) => MobileSessionNotifier());

final framesProvider = FutureProvider<List<FrameModel>>((ref) async {
  try {
    final res = await ApiService().getFrames();
    final apiList = (res.data['data'] as List)
        .map((f) => FrameModel.fromJson(f))
        .toList();
    if (apiList.isNotEmpty) {
      return [...apiList, ...FrameModel.defaultFrames];
    }
  } catch (_) {
    // Backend offline fallback
  }
  return FrameModel.defaultFrames;
});

final stickersProvider = FutureProvider<List<StickerModel>>((ref) async {
  try {
    final res = await ApiService().getStickers();
    final apiList = (res.data['data'] as List)
        .map((s) => StickerModel.fromJson(s))
        .toList();
    if (apiList.isNotEmpty) {
      return [...apiList, ...kStickers];
    }
  } catch (_) {
    // Fallback stiker
  }
  return kStickers;
});

final baseUrlProvider =
    FutureProvider<String>((ref) => MobileStorage.getBaseUrl());
