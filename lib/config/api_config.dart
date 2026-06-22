import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  static const String _physicalDeviceBaseUrl = 'http://10.169.90.195:3000';

  static String get baseUrl {
    final configured = _configuredBaseUrl.trim();
    if (configured.isNotEmpty) {
      return _withoutTrailingSlash(configured);
    }

    if (kIsWeb) {
      // In web, default to the current domain (origin) so it works automatically when hosted
      // Note: In development (localhost), this will point to localhost:xxxx (the flutter dev server)
      // If you are running backend on 3000 during dev, you might want to explicitly set API_BASE_URL
      // But for production, Uri.base.origin is perfect.
      final origin = Uri.base.origin;
      // If running flutter run -d chrome, origin is localhost:random_port, but backend is on 3000
      // So we fallback to localhost:3000 if it's localhost
      if (origin.contains('localhost')) {
        return 'http://localhost:3000';
      }
      return origin;
    }

    return _physicalDeviceBaseUrl;
  }

  static String get authBaseUrl => '$baseUrl/api/auth';

  static String _withoutTrailingSlash(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}
