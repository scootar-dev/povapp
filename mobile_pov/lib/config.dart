class AppConfig {
  AppConfig._();
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
  // baseUrl tanpa /api, karena endpoint public di /download/{code}
  // tapi API kiosk ada di /api/kiosk/...
}
