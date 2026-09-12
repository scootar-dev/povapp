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
  String? lastError;

  Future<void> startSession(FrameModel frame) async {
    try {
      final res = await _api.createSession(frameId: frame.id);
      final data = res.data['data'];
      state = SessionData(
        sessionId: data['id'],
        sessionCode: data['session_code'],
        frame: frame,
        retakeQuota: (data['retake_quota'] as num?)?.toInt() ?? 2,
      );
      await _api.updateSessionStatus(state.sessionId!, 'shooting');
      lastError = null;
    } catch (e) {
      lastError = e.toString();
      rethrow;
    }
  }

  Future<void> addPhoto(int slotIndex, String localFilePath) async {
    try {
      final res = await _api.uploadPhoto(state.sessionId!, slotIndex, localFilePath);
      final photo = PhotoModel.fromJson(res.data['data']);
      // Hindari duplikat slot: ganti foto lama di slot sama jika ada
      final filtered = state.photos.where((p) => p.slotIndex != slotIndex).toList();
      state = state.copyWith(photos: [...filtered, photo]..sort((a,b)=>a.slotIndex.compareTo(b.slotIndex)));
      lastError = null;
    } catch (e) {
      lastError = e.toString();
      rethrow;
    }
  }

  Future<void> retakePhoto(int photoId) async {
    try {
      await _api.retakePhoto(state.sessionId!, photoId);
      state = state.copyWith(
        photos: state.photos.where((p) => p.id != photoId).toList(),
        retakeUsed: state.retakeUsed + 1,
      );
      lastError = null;
    } catch (e) {
      lastError = e.toString();
      rethrow;
    }
  }

  Future<void> setFilter(PhotoColorFilter filter) async {
    try {
      await _api.applyFilter(state.sessionId!, filter.apiValue);
      state = state.copyWith(selectedFilter: filter);
      lastError = null;
    } catch (e) {
      lastError = e.toString();
      rethrow;
    }
  }

  Future<int> renderAndWaitOutput({void Function(int attempt)? onTick}) async {
    try {
      await _api.updateSessionStatus(state.sessionId!, 'rendering');
      await _api.renderOutput(state.sessionId!);
      for (var i = 0; i < 30; i++) {
        onTick?.call(i);
        await Future.delayed(const Duration(seconds: 2));
        final res = await _api.getOutputs(state.sessionId!);
        final outputs = res.data['data'] as List;
        final printOutput = outputs.cast<Map?>().firstWhere(
          (o) => o != null && o['type'] == 'print_image',
          orElse: () => null,
        );
        if (printOutput != null) {
          state = state.copyWith(printOutputId: printOutput['id'] as int);
          lastError = null;
          return printOutput['id'] as int;
        }
      }
      throw Exception('Render timeout — pastikan php artisan queue:listen jalan.');
    } catch (e) {
      lastError = e.toString();
      rethrow;
    }
  }

  Future<void> printResult() async {
    if (state.printOutputId == null) throw Exception('Output belum siap');
    try {
      await _api.queuePrint(state.sessionId!, state.printOutputId!);
      lastError = null;
    } catch (e) { lastError = e.toString(); rethrow; }
  }

  Future<void> shareResult(String channel, String recipient) async {
    try {
      await _api.share(state.sessionId!, channel, recipient);
      lastError = null;
    } catch (e) { lastError = e.toString(); rethrow; }
  }

  Future<void> completeAndReset() async {
    if (state.sessionId != null) {
      try { await _api.completeSession(state.sessionId!); } catch (_) {}
    }
    state = const SessionData();
    lastError = null;
  }

  void resetLocal() => state = const SessionData();
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionData>(
  (ref) => SessionNotifier(),
);

/// Daftar frame aktif — di-fetch sekali saat idle, dipakai di Frame Selection screen.
final framesProvider = FutureProvider<List<FrameModel>>((ref) async {
  final res = await ApiClient.instance.getFrames();
  return (res.data['data'] as List).map((f) => FrameModel.fromJson(f)).toList();
});
