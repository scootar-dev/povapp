class AppConfig {
  AppConfig._();

  /// Base URL TANPA `/api`. Default di-compute sesuai platform di
  /// `MobileStorage.defaultBaseUrl`; nilai ini hanya fallback dari dart-define.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8001',
  );

  /// Token perangkat (device_token) hasil registrasi studio di Admin Panel.
  /// Bisa diubah runtime lewat layar Pengaturan tanpa rebuild.
  static const String studioToken = String.fromEnvironment(
    'STUDIO_TOKEN',
    defaultValue: 'test-token-123',
  );
}