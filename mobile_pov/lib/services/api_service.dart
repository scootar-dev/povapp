import 'package:dio/dio.dart';

import '../core/storage.dart';

/// Wrapper Dio untuk endpoint /api/kiosk/* pada app customer (mobile_pov).
/// Base URL dibaca dari [MobileStorage] setiap request.
/// Tidak ada auth token karena API povstudio_admin bersifat public.
class ApiService {
  ApiService()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Accept': 'application/json'},
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (o, h) async {
        o.baseUrl = await MobileStorage.getBaseUrl();
        return h.next(o);
      },
      onError: (e, h) async {
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
  }

  final Dio _dio;

  String _msg(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi timeout — cek jaringan / IP server.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak bisa terhubung ke server.';
    }
    final code = e.response?.statusCode;
    final body = e.response?.data;
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

  Future<Response> getFrames() => _guard(() => _dio.get('/api/kiosk/frames'));
  Future<Response> getFrameDetail(int id) => _guard(() => _dio.get('/api/kiosk/frames/$id'));
  Future<Response> getStickers() => _guard(() => _dio.get('/api/kiosk/stickers'));

  Future<Response> createSession({required int frameId}) =>
      _guard(() => _dio.post('/api/kiosk/sessions', data: {'frame_id': frameId}));
  Future<Response> updateStatus(int id, String s) =>
      _guard(() => _dio.patch('/api/kiosk/sessions/$id/status', data: {'status': s}));
  Future<Response> uploadPhoto(int sid, int slot, String path) async {
    try {
      final fd = FormData.fromMap({
        'slot_index': slot,
        'photo': await MultipartFile.fromFile(path),
      });
      return await _dio.post('/api/kiosk/sessions/$sid/photos', data: fd);
    } on DioException catch (e) {
      throw Exception(_msg(e));
    }
  }
  Future<Response> renderOutput(int sid) => _guard(() => _dio.post('/api/kiosk/sessions/$sid/render'));
  Future<Response> getOutputs(int sid) => _guard(() => _dio.get('/api/kiosk/sessions/$sid/outputs'));
  Future<Response> complete(int sid) => _guard(() => _dio.post('/api/kiosk/sessions/$sid/complete'));

  Future<Response> fetchDownload(String code) async {
    final base = await MobileStorage.getBaseUrl();
    return _guard(() => Dio(BaseOptions(baseUrl: base)).get('/api/download/$code'));
  }
}

/// Fallback kompatibilitas: ekspor konstanta config untuk UI.
String get kDefaultBaseUrl => MobileStorage.defaultBaseUrl;