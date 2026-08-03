import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Central app configuration.
class AppConfig {
  AppConfig._();

  /// Override at build/run time:
  ///
  /// flutter run --dart-define=API_BASE_URL=http://192.168.1.109:8000/api/v1
  ///
  /// or in production:
  ///
  /// flutter build apk \
  ///   --dart-define=API_BASE_URL=https://api.adalotsathi.com/api/v1
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
  );

  static String get apiBaseUrl {
    // Highest priority: value passed with --dart-define
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _apiBaseUrlOverride;
    }

    // Web (if you ever run Flutter Web)
    if (kIsWeb) {
      return 'http://localhost:8000/api/v1';
    }

    // Android
    if (Platform.isAndroid) {
      // Emulator
      const bool isUsingEmulator = false;

      if (isUsingEmulator) {
        return 'http://10.0.2.2:8000/api/v1';
      }

      // Physical Android phone
      return 'http://192.168.1.109:8000/api/v1';
    }

    // iOS / macOS / Windows / Linux
    return 'http://127.0.0.1:8000/api/v1';
  }

  static const String appName = 'Adalot Sathi';
  static const String appNameBn = 'আদালত সাথী';
}