import 'package:flutter_test/flutter_test.dart';
import 'package:tokomedia/config/api_config.dart';

void main() {
  test('API configuration exposes one shared backend origin', () {
    expect(ApiConfig.baseUrl, isNotEmpty);
    expect(ApiConfig.baseUrl, isNot(endsWith('/')));
    expect(ApiConfig.authBaseUrl, '${ApiConfig.baseUrl}/api/auth');
  });
}
