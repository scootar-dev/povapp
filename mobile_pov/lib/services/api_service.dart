import 'package:dio/dio.dart';
import '../config.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl, connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 30), headers: {'Accept': 'application/json'}));
  // kiosk token dari env atau bisa diisi via settings (untuk demo pakai hardcode fallback)
  String get _token => const String.fromEnvironment('STUDIO_TOKEN', defaultValue: 'kiosk-token-123');

  Dio get withAuth {
    _dio.options.headers['Authorization'] = 'Bearer $_token';
    return _dio;
  }

  Future<Response> getFrames() => withAuth.get('/api/kiosk/frames');
  Future<Response> createSession({required int frameId}) => withAuth.post('/api/kiosk/sessions', data: {'frame_id': frameId});
  Future<Response> updateStatus(int id, String s) => withAuth.patch('/api/kiosk/sessions/$id/status', data: {'status': s});
  Future<Response> uploadPhoto(int sid, int slot, String path) async {
    final fd = FormData.fromMap({'slot_index': slot, 'photo': await MultipartFile.fromFile(path)});
    return withAuth.post('/api/kiosk/sessions/$sid/photos', data: fd);
  }
  Future<Response> renderOutput(int sid) => withAuth.post('/api/kiosk/sessions/$sid/render');
  Future<Response> getOutputs(int sid) => withAuth.get('/api/kiosk/sessions/$sid/outputs');
  Future<Response> complete(int sid) => withAuth.post('/api/kiosk/sessions/$sid/complete');

  // public
  Future<Response> fetchDownload(String code) => Dio(BaseOptions(baseUrl: AppConfig.baseUrl)).get('/api/download/$code');
}
