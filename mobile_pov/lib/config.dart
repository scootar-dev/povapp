class AppConfig {
  AppConfig._();

  /// Base URL TANPA `/api` (mis. http://10.0.2.2:8000).
  /// Endpoint API selalu diawali `/api/...` di dalam kode.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  /// Token perangkat (device_token) hasil registrasi studio di Admin Panel.
  /// Bisa diubah runtime lewat layar Pengaturan tanpa rebuild.
  static const String studioToken = String.fromEnvironment(
    'STUDIO_TOKEN',
    defaultValue: 'test-token-123',
  );
}