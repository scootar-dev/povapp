import 'package:flutter/foundation.dart';

class MobileStorage {
  /// Default URL menyesuaikan platform:
  /// - Android emulator: 10.0.2.2 (alias ke host)
  /// - Web/Desktop/iOS simulator: 127.0.0.1
  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000';
      default:
        return 'http://127.0.0.1:8000';
    }
  }

  static Future<String> getBaseUrl() async => defaultBaseUrl;
}