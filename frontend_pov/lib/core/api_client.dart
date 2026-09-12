import 'package:dio/dio.dart';
import 'storage.dart';

/// Wrapper Dio untuk endpoint /kiosk/*. Support runtime config via SharedPreferences
/// + retry 1x untuk timeout/502, + error mapping user friendly.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (o, h) async {
        // Inject baseUrl & token terbaru tiap request (bisa diubah di Settings tanpa restart)
        o.baseUrl = await KioskStorage.getBaseUrl();
        o.headers['Authorization'] = 'Bearer ${await KioskStorage.getToken()}';
        return h.next(o);
      },
      onError: (e, h) async {
        // Retry sekali untuk timeout / 502 / 503
        final shouldRetry = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.response?.statusCode == 502 ||
            e.response?.statusCode == 503;
        final alreadyRetried = e.requestOptions.extra['retried'] == true;
        if (shouldRetry && !alreadyRetried) {
          e.requestOptions.extra['retried'] = true;
          await Future.delayed(const Duration(milliseconds: 800));
          try {
            final res = await _dio.fetch(e.requestOptions);
            return h.resolve(res);
          } catch (_) {}
        }
        return h.next(e);
      },
    ));

    // Log di debug mode
    _dio.interceptors.add(LogInterceptor(requestBody: false, responseBody: false));
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio _dio;
  Dio get dio => _dio;

  String _msg(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi timeout — cek jaringan / IP server.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak bisa terhubung ke server. Cek API_BASE_URL di Settings.';
    }
    final code = e.response?.statusCode;
    final body = e.response?.data;
    if (code == 401) return 'Token studio tidak valid — cek STUDIO_TOKEN di Settings.';
    if (code == 422) {
      final m = body is Map ? (body['message'] ?? body['msg']) : null;
      return m?.toString() ?? 'Validasi gagal (422).';
    }
    if (code == 404) return 'Data tidak ditemukan (404).';
    if (body is Map && body['message'] != null) return body['message'].toString();
    return e.message ?? 'Terjadi kesalahan jaringan.';
  }

  Future<Response> _guard(Future<Response> Function() fn) async {
    try {
      return await fn();
    } on DioException catch (e) {
      throw Exception(_msg(e));
    }
  }

  // ----- Frames -----
  Future<Response> getFrames() => _guard(() => _dio.get('/kiosk/frames'));
  Future<Response> getFrameDetail(int id) => _guard(() => _dio.get('/kiosk/frames/$id'));

  // ----- Sessions -----
  Future<Response> createSession({int? frameId, int? retakeQuota}) => _guard(() => _dio.post('/kiosk/sessions', data: {
        if (frameId != null) 'frame_id': frameId,
        if (retakeQuota != null) 'retake_quota': retakeQuota,
      }));

  Future<Response> updateSessionStatus(int sessionId, String status) =>
      _guard(() => _dio.patch('/kiosk/sessions/$sessionId/status', data: {'status': status}));

  Future<Response> applyFilter(int sessionId, String filter) =>
      _guard(() => _dio.post('/kiosk/sessions/$sessionId/apply-filter', data: {'filter': filter}));

  // ----- Photos -----
  Future<Response> uploadPhoto(int sessionId, int slotIndex, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'slot_index': slotIndex,
        'photo': await MultipartFile.fromFile(filePath),
      });
      return await _dio.post('/kiosk/sessions/$sessionId/photos', data: formData);
    } on DioException catch (e) {
      throw Exception(_msg(e));
    }
  }

  Future<Response> getPhotos(int sessionId) => _guard(() => _dio.get('/kiosk/sessions/$sessionId/photos'));
  Future<Response> retakePhoto(int sessionId, int photoId) =>
      _guard(() => _dio.post('/kiosk/sessions/$sessionId/photos/$photoId/retake'));

  // ----- Render / Output -----
  Future<Response> renderOutput(int sessionId) => _guard(() => _dio.post('/kiosk/sessions/$sessionId/render'));
  Future<Response> getOutputs(int sessionId) => _guard(() => _dio.get('/kiosk/sessions/$sessionId/outputs'));

  // ----- Print -----
  Future<Response> queuePrint(int sessionId, int outputId) =>
      _guard(() => _dio.post('/kiosk/sessions/$sessionId/print', data: {'output_id': outputId}));
  Future<Response> getPrintStatus(int printLogId) => _guard(() => _dio.get('/kiosk/print-jobs/$printLogId'));

  // ----- Share -----
  Future<Response> share(int sessionId, String channel, String recipient) =>
      _guard(() => _dio.post('/kiosk/sessions/$sessionId/share', data: {'channel': channel, 'recipient': recipient}));

  // ----- Complete -----
  Future<Response> completeSession(int sessionId) => _guard(() => _dio.post('/kiosk/sessions/$sessionId/complete'));
}
