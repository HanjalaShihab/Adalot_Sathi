/// Central app configuration.
class AppConfig {
  AppConfig._();

  /// Base URL of the Adalot Sathi API.
  ///
  /// Use `10.0.2.2` when running on the Android emulator (host loopback).
  /// Use the machine LAN IP when running on a physical device.
  /// Use the production URL when deploying.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  static const String appName = 'Adalot Sathi';
  static const String appNameBn = 'আদালত সাথী';
}

