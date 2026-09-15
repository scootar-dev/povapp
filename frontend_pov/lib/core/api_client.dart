import 'package:dio/dio.dart';
import 'app_config.dart';

/// Wrapper di atas Dio untuk Kiosk API dan Admin API.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Dynamic base URL update if changed
          options.baseUrl = AppConfig.baseUrl;

          // Admin routes use Sanctum Bearer admin token
          if (options.path.startsWith('/admin')) {
            if (AppConfig.adminToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer ${AppConfig.adminToken}';
            }
          } else if (options.path.startsWith('/kiosk')) {
            // Kiosk routes use studio token
            if (AppConfig.studioToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer ${AppConfig.studioToken}';
            }
          }
          return handler.next(options);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio _dio;

  Dio get dio => _dio;

  // ================= ADMIN API =================
  Future<Response> loginAdmin(String email, String password) => _dio.post(
        '/admin/login',
        data: {'email': email, 'password': password},
      );

  Future<Response> getAdminMe() => _dio.get('/admin/me');

  Future<Response> logoutAdmin() => _dio.post('/admin/logout');

  Future<Response> getStudiosAdmin() => _dio.get('/admin/studios');

  Future<Response> createStudioAdmin({
    required String name,
    String? location,
    required String cameraSource,
    String? printerDriver,
  }) =>
      _dio.post(
        '/admin/studios',
        data: {
          'name': name,
          'location': location,
          'camera_source': cameraSource,
          'printer_driver': printerDriver,
        },
      );

  Future<Response> getFramesAdmin() => _dio.get('/admin/frames');

  Future<Response> createFrameAdmin(Map<String, dynamic> frameData) =>
      _dio.post('/admin/frames', data: frameData);

  Future<Response> getReportsSummaryAdmin({String? dateFrom, String? dateTo}) =>
      _dio.get('/admin/reports/summary', queryParameters: {
        if (dateFrom != null) 'date_from': dateFrom,
        if (dateTo != null) 'date_to': dateTo,
      });

  // ================= KIOSK API =================
  Future<Response> getFrames() => _dio.get('/kiosk/frames');

  Future<Response> getFrameDetail(int frameId) => _dio.get('/kiosk/frames/$frameId');

  Future<Response> createSession({int? frameId, int? retakeQuota}) => _dio.post(
        '/kiosk/sessions',
        data: {
          if (frameId != null) 'frame_id': frameId,
          if (retakeQuota != null) 'retake_quota': retakeQuota,
        },
      );

  Future<Response> updateSessionStatus(int sessionId, String status) => _dio.patch(
        '/kiosk/sessions/$sessionId/status',
        data: {'status': status},
      );

  Future<Response> applyFilter(int sessionId, String filter) => _dio.post(
        '/kiosk/sessions/$sessionId/apply-filter',
        data: {'filter': filter},
      );

  Future<Response> uploadPhoto(int sessionId, int slotIndex, String filePath) async {
    final formData = FormData.fromMap({
      'slot_index': slotIndex,
      'photo': await MultipartFile.fromFile(filePath),
    });
    return _dio.post('/kiosk/sessions/$sessionId/photos', data: formData);
  }

  Future<Response> getPhotos(int sessionId) => _dio.get('/kiosk/sessions/$sessionId/photos');

  Future<Response> retakePhoto(int sessionId, int photoId) =>
      _dio.post('/kiosk/sessions/$sessionId/photos/$photoId/retake');

  Future<Response> renderOutput(int sessionId) => _dio.post('/kiosk/sessions/$sessionId/render');

  Future<Response> getOutputs(int sessionId) => _dio.get('/kiosk/sessions/$sessionId/outputs');

  Future<Response> queuePrint(int sessionId, int outputId) => _dio.post(
        '/kiosk/sessions/$sessionId/print',
        data: {'output_id': outputId},
      );

  Future<Response> getPrintStatus(int printLogId) => _dio.get('/kiosk/print-jobs/$printLogId');

  Future<Response> share(int sessionId, String channel, String recipient) => _dio.post(
        '/kiosk/sessions/$sessionId/share',
        data: {'channel': channel, 'recipient': recipient},
      );

  Future<Response> completeSession(int sessionId) =>
      _dio.post('/kiosk/sessions/$sessionId/complete');
}
