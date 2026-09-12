import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ApiService {
  static final ApiService instance = ApiService._();
  ApiService._() {
    _dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl, connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 30)));
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (o, h) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('admin_token');
      if (token != null) o.headers['Authorization'] = 'Bearer $token';
      o.headers['Accept'] = 'application/json';
      return h.next(o);
    }));
  }
  late final Dio _dio;
  Dio get dio => _dio;

  Future<void> saveToken(String t) async => (await SharedPreferences.getInstance()).setString('admin_token', t);
  Future<void> clearToken() async => (await SharedPreferences.getInstance()).remove('admin_token');
  Future<String?> getToken() async => (await SharedPreferences.getInstance()).getString('admin_token');

  Future<Response> login(String email, String pass) => _dio.post('/admin/login', data: {'email': email, 'password': pass});
  Future<Response> me() => _dio.get('/admin/me');
  Future<Response> logout() => _dio.post('/admin/logout');

  Future<Response> getSummary({String? from, String? to}) => _dio.get('/admin/reports/summary', queryParameters: {'date_from': ?from, 'date_to': ?to});
  Future<Response> getStudios() => _dio.get('/admin/studios');
  Future<Response> createStudio(Map<String,dynamic> d) => _dio.post('/admin/studios', data: d);
  Future<Response> getFrames() => _dio.get('/admin/frames');
  Future<Response> getSessions({Map<String,dynamic>? q}) => _dio.get('/admin/sessions', queryParameters: q);
  Future<Response> getSession(int id) => _dio.get('/admin/sessions/$id');
}
