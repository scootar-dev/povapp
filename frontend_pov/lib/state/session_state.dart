import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../models/frame_model.dart';
import '../models/photo_model.dart';

/// Data sesi yang hidup dari Frame Selection sampai Thank You screen.
/// Ini satu-satunya sumber kebenaran (single source of truth) untuk sesi
/// yang sedang berjalan — semua layar tinggal `ref.watch` state ini.
class SessionData {
  final int? sessionId;
  final String? sessionCode;
  final FrameModel? frame;
  final List<PhotoModel> photos;
  final int retakeQuota;
  final int retakeUsed;
  final PhotoColorFilter selectedFilter;
  final int? printOutputId;

  const SessionData({
    this.sessionId,
    this.sessionCode,
    this.frame,
    this.photos = const [],
    this.retakeQuota = 2,
    this.retakeUsed = 0,
    this.selectedFilter = PhotoColorFilter.original,
    this.printOutputId,
  });

  int get retakeRemaining => (retakeQuota - retakeUsed).clamp(0, retakeQuota);

  SessionData copyWith({
    int? sessionId,
    String? sessionCode,
    FrameModel? frame,
    List<PhotoModel>? photos,
    int? retakeQuota,
    int? retakeUsed,
    PhotoColorFilter? selectedFilter,
    int? printOutputId,
  }) {
    return SessionData(
      sessionId: sessionId ?? this.sessionId,
      sessionCode: sessionCode ?? this.sessionCode,
      frame: frame ?? this.frame,
      photos: photos ?? this.photos,
      retakeQuota: retakeQuota ?? this.retakeQuota,
      retakeUsed: retakeUsed ?? this.retakeUsed,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      printOutputId: printOutputId ?? this.printOutputId,
    );
  }
}

class SessionNotifier extends StateNotifier<SessionData> {
  SessionNotifier() : super(const SessionData());

  final _api = ApiClient.instance;

  /// Langkah 1: dipanggil setelah pelanggan menyentuh layar Welcome
  /// dan memilih frame.
  Future<void> startSession(FrameModel frame) async {
    final res = await _api.createSession(frameId: frame.id);
    final data = res.data['data'];
    state = SessionData(
      sessionId: data['id'],
      sessionCode: data['session_code'],
      frame: frame,
      retakeQuota: data['retake_quota'],
    );
    await _api.updateSessionStatus(state.sessionId!, 'shooting');
  }

  /// Dipanggil tiap satu foto selesai diambil.
  Future<void> addPhoto(int slotIndex, String localFilePath) async {
    final res = await _api.uploadPhoto(state.sessionId!, slotIndex, localFilePath);
    final photo = PhotoModel.fromJson(res.data['data']);
    state = state.copyWith(photos: [...state.photos, photo]);
  }

  /// Dipanggil saat pelanggan menandai satu foto untuk retake.
  Future<void> retakePhoto(int photoId) async {
    await _api.retakePhoto(state.sessionId!, photoId);
    state = state.copyWith(
      photos: state.photos.where((p) => p.id != photoId).toList(),
      retakeUsed: state.retakeUsed + 1,
    );
  }

  Future<void> setFilter(PhotoColorFilter filter) async {
    await _api.applyFilter(state.sessionId!, filter.apiValue);
    state = state.copyWith(selectedFilter: filter);
  }

  Future<int> renderAndWaitOutput() async {
    await _api.updateSessionStatus(state.sessionId!, 'rendering');
    await _api.renderOutput(state.sessionId!);

    // Polling sederhana — untuk produksi, ganti dengan WebSocket/Pusher event
    // agar tidak perlu menunggu-nunggu lewat interval.
    for (var i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 2));
      final res = await _api.getOutputs(state.sessionId!);
      final outputs = res.data['data'] as List;
      final printOutput = outputs.firstWhere(
        (o) => o['type'] == 'print_image',
        orElse: () => null,
      );
      if (printOutput != null) {
        state = state.copyWith(printOutputId: printOutput['id']);
        return printOutput['id'];
      }
    }
    throw Exception('Render timeout — cek queue worker Laravel.');
  }

  Future<void> printResult() async {
    if (state.printOutputId == null) return;
    await _api.queuePrint(state.sessionId!, state.printOutputId!);
  }

  Future<void> shareResult(String channel, String recipient) async {
    await _api.share(state.sessionId!, channel, recipient);
  }

  /// Terakhir: reset ke kondisi awal untuk pelanggan berikutnya.
  Future<void> completeAndReset() async {
    if (state.sessionId != null) {
      await _api.completeSession(state.sessionId!);
    }
    state = const SessionData();
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionData>(
  (ref) => SessionNotifier(),
);

/// Daftar frame aktif — di-fetch sekali saat idle, dipakai di Frame Selection screen.
final framesProvider = FutureProvider<List<FrameModel>>((ref) async {
  final res = await ApiClient.instance.getFrames();
  return (res.data['data'] as List).map((f) => FrameModel.fromJson(f)).toList();
});
