import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  String? _token;
  String? _error;
  bool _isLoading = false;

  String? get token => _token;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('token');
    if (saved != null && !isTokenExpired(saved)) {
      _token = saved;
    } else {
      _token = null;
      await prefs.remove('token');
    }
    notifyListeners();
  }

  Future<bool> login({required String username, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _service.login(username: username, password: password);
      if (isTokenExpired(token)) {
        _error = 'Token expired';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      _token = token;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (err) {
      _error = 'Login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  bool isTokenExpired(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      return true;
    }

    final payload = _decodeBase64(parts[1]);
    if (payload == null) {
      return true;
    }

    final data = jsonDecode(payload) as Map<String, dynamic>;
    final exp = data['exp'];
    if (exp is! int) {
      return true;
    }

    final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expiry);
  }

  String? _decodeBase64(String input) {
    try {
      final normalized = base64Url.normalize(input);
      return utf8.decode(base64Url.decode(normalized));
    } catch (_) {
      return null;
    }
  }
}
