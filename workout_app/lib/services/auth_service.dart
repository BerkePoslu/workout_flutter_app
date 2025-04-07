import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  String? _userId;
  String? _username;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get userId => _userId;
  String? get username => _username;

  AuthService() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    _username = prefs.getString('username');
    _isAuthenticated = _token != null;
    notifyListeners();
  }

  Future<void> login(
      {required String token,
      required String userId,
      required String username}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userId', userId);
    await prefs.setString('username', username);
    _token = token;
    _userId = userId;
    _username = username;
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('username');
    _token = null;
    _userId = null;
    _username = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
