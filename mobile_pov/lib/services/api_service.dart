import 'package:dio/dio.dart';
import '../config.dart';

class OutputItem {
  final String type;
  final String url;
  OutputItem({required this.type, required this.url});
  factory OutputItem.fromJson(Map<String, dynamic> j) =>
      OutputItem(type: j['type'], url: j['url']);
}

class SessionResult {
  final String sessionCode;
  final List<OutputItem> outputs;
  SessionResult({required this.sessionCode, required this.outputs});
}

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));

  Future<SessionResult> fetchDownload(String sessionCode) async {
    final res = await _dio.get('/api/download/$sessionCode');
    final data = res.data['data'];
    final outs = (data['outputs'] as List).map((o) => OutputItem.fromJson(o)).toList();
    return SessionResult(sessionCode: data['session_code'], outputs: outs);
  }

  Future<String> downloadFile(String url, String savePath) async {
    await _dio.download(url, savePath);
    return savePath;
  }
}
