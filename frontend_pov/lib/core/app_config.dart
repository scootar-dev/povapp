/// Konfigurasi statis aplikasi. Untuk multi-kios, sebaiknya nilai-nilai ini
/// dibaca dari file konfigurasi lokal (mis. shared_preferences atau file .env
/// di device) supaya tiap kios bisa diarahkan ke studio_id & token berbeda
/// tanpa perlu rebuild aplikasi.
class AppConfig {
  AppConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://pov-studio.example.com/api',
  );

  /// Token perangkat (device_token) hasil registrasi studio di Admin Panel.
  /// Untuk produksi, simpan lewat flutter_secure_storage, bukan hardcode.
  static const String studioToken = String.fromEnvironment(
    'STUDIO_TOKEN',
    defaultValue: 'REPLACE_WITH_DEVICE_TOKEN',
  );

  // Durasi timer (detik) — sesuai spesifikasi, bisa dibuat configurable per studio.
  static const int prepTimerSeconds = 50;
  static const int shootCountdownSeconds = 5;
  static const int thankYouResetSeconds = 8;
}
