import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  Future<bool> login(String phone, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.login(phone: phone, password: password);

      if (response['user'] != null) {
        _setUser(User.fromJson(response['user']));
        return true;
      } else {
        _setError(response['error'] ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      if (response['user'] != null) {
        _setUser(User.fromJson(response['user']));
        return true;
      } else {
        _setError(response['error'] ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await ApiService.clearToken();
    _setUser(null);
    _setError(null);
  }

  Future<void> clearStoredToken() async {
    await ApiService.clearToken();
    _setUser(null);
    _setError(null);
  }

  void clearError() {
    _setError(null);
  }

  void setUserFromJson(Map<String, dynamic> userJson) {
    _setUser(User.fromJson(userJson));
  }
}
