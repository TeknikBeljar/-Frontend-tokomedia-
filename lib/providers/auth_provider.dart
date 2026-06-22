import 'package:flutter/material.dart';
import '../services/auth_api_service.dart';

class AuthProvider extends ChangeNotifier {
  final TokenStorageService _tokenStorage = TokenStorageService();
  bool _isAuthenticated = false;
  bool _isLoading = true;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _checkInitialAuth();
  }

  Future<void> _checkInitialAuth() async {
    final token = await _tokenStorage.getAccessToken();
    _isAuthenticated = token != null && token.isNotEmpty;
    _isLoading = false;
    notifyListeners();
  }

  void login() {
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _tokenStorage.clearTokens();
    _isAuthenticated = false;
    notifyListeners();
  }
}
