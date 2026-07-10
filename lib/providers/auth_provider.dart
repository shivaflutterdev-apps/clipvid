import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  
  UserModel? _currentUser;
  bool _isLoading = true;

  AuthProvider(this._apiClient) {
    _initAuth();
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;

  Future<void> _initAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final userData = prefs.getString('jwt_user_data');
    
    if (token != null) {
      _apiClient.setToken(token);
      
      // Load user details immediately if we have them cached
      if (userData != null) {
        try {
          _currentUser = UserModel.fromJson(jsonDecode(userData));
          _isLoading = false;
          notifyListeners(); // Takes user to home screen instantly
        } catch (_) {}
      }

      // Verify token and update user details in the background
      try {
        final data = await _apiClient.getCurrentUser();
        _currentUser = UserModel.fromJson(data['user']);
        await prefs.setString('jwt_user_data', jsonEncode(data['user']));
        if (_isLoading) {
          _isLoading = false;
        }
        notifyListeners();
      } catch (e) {
        if (e is ApiException && e.statusCode == 401) {
          // Token invalid or expired
          await prefs.remove('jwt_token');
          await prefs.remove('jwt_user_data');
          _apiClient.clearToken();
          _currentUser = null;
          notifyListeners();
        } else {
          // Network error, we keep the cached user data
          debugPrint('Could not verify token: $e');
        }
      }
    }
    
    if (_isLoading) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    final result = await _apiClient.login(email, password);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', result['token']);
    await prefs.setString('jwt_user_data', jsonEncode(result['user']));
    _apiClient.setToken(result['token']);
    _currentUser = UserModel.fromJson(result['user']);
    notifyListeners();
  }

  Future<void> register(String email, String password, String name) async {
    final result = await _apiClient.register(email, password, name);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', result['token']);
    await prefs.setString('jwt_user_data', jsonEncode(result['user']));
    _apiClient.setToken(result['token']);
    _currentUser = UserModel.fromJson(result['user']);
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('jwt_user_data');
    _apiClient.clearToken();
    _currentUser = null;
    try {
      await _apiClient.logout(); // Inform server (optional for stateless JWT)
    } catch (_) {}
    notifyListeners();
  }
}
