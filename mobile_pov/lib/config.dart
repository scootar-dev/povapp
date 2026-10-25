class AppConfig {
  AppConfig._();

  /// Base URL TANPA `/api`. Hardcoded ke povstudio_admin port 8000.
  /// Default di-compute sesuai platform di `MobileStorage.defaultBaseUrl`.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );
}