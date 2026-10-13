import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class MobileStorage {
  static const _kBaseUrl = 'mobile_base_url';
  static const _kToken = 'mobile_studio_token';

  /// Default URL menyesuaikan platform:
  /// - Android emulator: 10.0.2.2 (alias ke host)
  /// - Web/Desktop/iOS simulator: 127.0.0.1
  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8001';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8001';
      default:
        return 'http://127.0.0.1:8001';
    }
  }

  static Future<String> getBaseUrl() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kBaseUrl) ?? defaultBaseUrl;
  }

  static Future<String> getToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kToken) ?? AppConfig.studioToken;
  }

  static Future<void> saveBaseUrl(String v) async =>
      (await SharedPreferences.getInstance()).setString(_kBaseUrl, v);

  static Future<void> saveToken(String v) async =>
      (await SharedPreferences.getInstance()).setString(_kToken, v);

  static Future<void> resetBaseUrl() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kBaseUrl);
  }

  static Future<void> resetToken() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kToken);
  }
}