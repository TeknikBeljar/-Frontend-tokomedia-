import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  static const String _physicalDeviceBaseUrl = 'http://10.167.42.91:3000';

  static String get baseUrl {
    final configured = _configuredBaseUrl.trim();
    if (configured.isNotEmpty) {
      return _withoutTrailingSlash(configured);
    }

    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    return _physicalDeviceBaseUrl;
  }

  static String get authBaseUrl => '$baseUrl/api/auth';

  static String _withoutTrailingSlash(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}
