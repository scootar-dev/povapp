import 'package:dio/dio.dart';

import 'app_config.dart';

/// Wrapper tipis di atas Dio, khusus endpoint /kiosk/*.
/// Semua request otomatis membawa Authorization: Bearer <studioToken>.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Authorization': 'Bearer ${AppConfig.studioToken}',
          'Accept': 'application/json',
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio _dio;

  Dio get dio => _dio;

  // ----- Frames -----
  Future<Response> getFrames() => _dio.get('/kiosk/frames');
  Future<Response> getFrameDetail(int frameId) => _dio.get('/kiosk/frames/$frameId');

  // ----- Sessions -----
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

  // ----- Photos -----
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

  // ----- Render / Output -----
  Future<Response> renderOutput(int sessionId) => _dio.post('/kiosk/sessions/$sessionId/render');
  Future<Response> getOutputs(int sessionId) => _dio.get('/kiosk/sessions/$sessionId/outputs');

  // ----- Print -----
  Future<Response> queuePrint(int sessionId, int outputId) => _dio.post(
        '/kiosk/sessions/$sessionId/print',
        data: {'output_id': outputId},
      );
  Future<Response> getPrintStatus(int printLogId) => _dio.get('/kiosk/print-jobs/$printLogId');

  // ----- Share -----
  Future<Response> share(int sessionId, String channel, String recipient) => _dio.post(
        '/kiosk/sessions/$sessionId/share',
        data: {'channel': channel, 'recipient': recipient},
      );

  // ----- Complete -----
  Future<Response> completeSession(int sessionId) =>
      _dio.post('/kiosk/sessions/$sessionId/complete');
}
