import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  AppConfig._();

  static String _baseUrl = 'http://127.0.0.1:8000/api';
  static String _studioToken = '';
  static String _adminToken = '';
  static String _cameraSource = 'internal'; // 'internal' or 'dslr'

  static String get baseUrl => _baseUrl;
  static String get studioToken => _studioToken;
  static String get adminToken => _adminToken;
  static String get cameraSource => _cameraSource;

  // Durasi timer (detik) — configurable per studio
  static const int prepTimerSeconds = 50;
  static const int shootCountdownSeconds = 5;
  static const int thankYouResetSeconds = 8;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('api_base_url') ?? 'http://127.0.0.1:8000/api';
    _studioToken = prefs.getString('studio_token') ?? '';
    _adminToken = prefs.getString('admin_token') ?? '';
    _cameraSource = prefs.getString('camera_source') ?? 'internal';
  }

  static Future<void> saveSettings({
    String? baseUrl,
    String? studioToken,
    String? adminToken,
    String? cameraSource,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (baseUrl != null) {
      _baseUrl = baseUrl;
      await prefs.setString('api_base_url', baseUrl);
    }
    if (studioToken != null) {
      _studioToken = studioToken;
      await prefs.setString('studio_token', studioToken);
    }
    if (adminToken != null) {
      _adminToken = adminToken;
      await prefs.setString('admin_token', adminToken);
    }
    if (cameraSource != null) {
      _cameraSource = cameraSource;
      await prefs.setString('camera_source', cameraSource);
    }
  }

  static Future<void> clearAdminToken() async {
    _adminToken = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_token');
  }
}
