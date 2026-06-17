import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/auth/otp_challenge_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }
}

class AuthApiService {
  final String baseUrl = ApiConfig.authBaseUrl;
  final TokenStorageService _tokenStorage = TokenStorageService();
  
  static bool isTestMode = false;

  Future<OtpChallengeModel> requestRegisterOtp(String identifier, String channel) async {
    return _requestOtp('/register/request-otp', identifier, channel);
  }

  Future<OtpChallengeModel> requestLoginOtp(String identifier, String channel) async {
    return _requestOtp('/login/request-otp', identifier, channel);
  }

  Future<OtpChallengeModel> _requestOtp(String endpoint, String identifier, String channel) async {
    if (isTestMode) {
      return OtpChallengeModel(success: true, message: 'Mock OTP Sent', challengeId: 'test-challenge');
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': identifier,
          'channel': channel,
        }),
      );
      
      final data = jsonDecode(response.body);
      return OtpChallengeModel.fromJson(data);
    } catch (e) {
      return OtpChallengeModel(success: false, message: 'Koneksi gagal: $e');
    }
  }

  Future<AuthResponseModel> verifyRegisterOtp(String challengeId, String otp, {String? fullName}) async {
    if (isTestMode) {
      return AuthResponseModel(success: true, message: 'Mock Verify');
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'challenge_id': challengeId,
          'otp': otp,
          if (fullName != null) 'full_name': fullName,
        }),
      );

      final data = jsonDecode(response.body);
      final res = AuthResponseModel.fromJson(data);
      if (res.success && res.data != null) {
        await _tokenStorage.saveTokens(res.data!['access_token'], res.data!['refresh_token']);
      }
      return res;
    } catch (e) {
      return AuthResponseModel(success: false, message: 'Verifikasi gagal: $e');
    }
  }

  Future<AuthResponseModel> verifyLoginOtp(String challengeId, String otp) async {
    if (isTestMode) {
      return AuthResponseModel(success: true, message: 'Mock Verify');
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'challenge_id': challengeId,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);
      final res = AuthResponseModel.fromJson(data);
      if (res.success && res.data != null) {
        await _tokenStorage.saveTokens(res.data!['access_token'], res.data!['refresh_token']);
      }
      return res;
    } catch (e) {
      return AuthResponseModel(success: false, message: 'Verifikasi gagal: $e');
    }
  }

  Future<OtpChallengeModel> resendOtp(String challengeId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/otp/resend'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'challenge_id': challengeId,
        }),
      );
      
      final data = jsonDecode(response.body);
      return OtpChallengeModel.fromJson(data);
    } catch (e) {
      return OtpChallengeModel(success: false, message: 'Koneksi gagal: $e');
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearTokens();
  }
}
