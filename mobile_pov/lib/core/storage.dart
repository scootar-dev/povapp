import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MobileStorage {
  static const _keyBaseUrl = 'api_base_url';

  /// Default URL menyesuaikan platform:
  /// - Web: deteksi hostname dari browser URL (misal http://192.168.x.x:8000), fallback 127.0.0.1
  /// - Android emulator: 10.0.2.2 (alias ke host)
  /// - Desktop/iOS simulator: 127.0.0.1
  static String get defaultBaseUrl {
    if (kIsWeb) {
      try {
        final host = Uri.base.host;
        if (host.isNotEmpty && host != 'localhost' && host != '127.0.0.1') {
          return 'http://$host:8000';
        }
      } catch (_) {}
      return 'http://127.0.0.1:8000';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000';
      default:
        return 'http://127.0.0.1:8000';
    }
  }

  static Future<String> getBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_keyBaseUrl);
      if (saved != null && saved.trim().isNotEmpty) {
        return saved.trim();
      }
    } catch (_) {}
    return defaultBaseUrl;
  }

  static Future<void> setBaseUrl(String url) async {
    try {
      var clean = url.trim();
      if (clean.endsWith('/')) {
        clean = clean.substring(0, clean.length - 1);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyBaseUrl, clean);
    } catch (_) {}
  }

  static Future<void> resetBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyBaseUrl);
    } catch (_) {}
  }
}