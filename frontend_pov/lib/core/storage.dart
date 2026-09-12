import 'package:shared_preferences/shared_preferences.dart';
import 'app_config.dart';

class KioskStorage {
  static const _kBaseUrl = 'kiosk_base_url';
  static const _kToken = 'kiosk_studio_token';
  static const _kLastFrameId = 'kiosk_last_frame_id';

  static Future<String> getBaseUrl() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kBaseUrl) ?? AppConfig.baseUrl;
  }

  static Future<String> getToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kToken) ?? AppConfig.studioToken;
  }

  static Future<void> saveBaseUrl(String v) async =>
      (await SharedPreferences.getInstance()).setString(_kBaseUrl, v);

  static Future<void> saveToken(String v) async =>
      (await SharedPreferences.getInstance()).setString(_kToken, v);

  static Future<void> saveLastFrame(int id) async =>
      (await SharedPreferences.getInstance()).setInt(_kLastFrameId, id);

  static Future<int?> getLastFrame() async =>
      (await SharedPreferences.getInstance()).getInt(_kLastFrameId);

  static Future<void> clearSessionCache() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kLastFrameId);
  }
}
