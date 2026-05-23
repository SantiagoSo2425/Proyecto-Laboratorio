class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '/api/v1',
  );

  static const readmeApiBaseUrl = String.fromEnvironment(
    'README_API_BASE_URL',
    defaultValue: 'http://localhost:8001',
  );
}
