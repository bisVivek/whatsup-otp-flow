import 'package:flutter/foundation.dart';

/// Runtime configuration.
///
/// Override the API with `--dart-define=API_BASE_URL=https://api.example.com`.
abstract final class Env {
  static const _override = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_override.isNotEmpty) return _override;
    // The Android emulator reaches the host machine through 10.0.2.2.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    return 'http://127.0.0.1:8000/api/v1';
  }

  static const deviceName = 'app_login';

  /// Added to 10-digit WhatsApp numbers typed without one.
  /// Keep in step with `OTP_DEFAULT_COUNTRY_CODE` on the server.
  static const defaultCountryCode = String.fromEnvironment(
    'DEFAULT_COUNTRY_CODE',
    defaultValue: '91',
  );
}
