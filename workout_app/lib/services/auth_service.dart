import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

// Auth service class
// author: Berke Poslu
// date: 2025-04-07
// This class is used to manage the authentication state of the user

class AuthService extends ChangeNotifier {
  String? _token;
  String? _userId;
  String? _username;
  bool _isLoading = false;

  String? get token => _token;
  String? get userId => _userId;
  String? get username => _username;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  AuthService() {
    loadAuthData();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(AppConfig.getFullUrl('login')),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveAuthData(
          token: data['token'],
          userId: data['user']['id'],
          username: data['user']['name'],
        );
      } else if (response.statusCode == 401) {
        throw Exception('Invalid credentials');
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      await _clearAuthData();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String username) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(AppConfig.getFullUrl('register')),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'name': username,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        await _saveAuthData(
          token: data['token'],
          userId: data['user']['id'],
          username: data['user']['name'],
        );
      } else {
        throw Exception('Registration failed');
      }
    } catch (e) {
      _clearAuthData();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _clearAuthData();
  }

// AI generated
  Future<void> saveAuthData({
    required String token,
    required String userId,
    required String username,
  }) async {
    await _saveAuthData(
      token: token,
      userId: userId,
      username: username,
    );
  }

// AI generated
  Future<void> _saveAuthData({
    required String token,
    required String userId,
    required String username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userId', userId);
    await prefs.setString('username', username);

    _token = token;
    _userId = userId;
    _username = username;
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('username');

    _token = null;
    _userId = null;
    _username = null;
  }

  Future<void> loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    _username = prefs.getString('username');
    notifyListeners();
  }
}
