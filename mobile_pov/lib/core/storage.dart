import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class MobileStorage {
  static const _kBaseUrl = 'mobile_base_url';
  static const _kToken = 'mobile_studio_token';

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
}