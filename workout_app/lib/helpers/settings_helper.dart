import 'package:shared_preferences/shared_preferences.dart';

// Settings Helper class
// Author: Berke Poslu
// Date: 2025-04-07
// Description: Helper class for settings, got the idea from stackoverflow

class SettingsHelper {
  static const String _weightKey = 'user_weight';
  static const String _heightKey = 'user_height';
  static const String _darkModeKey = 'dark_mode';
  static const double _defaultWeight = 70.0;
  static const double _defaultHeight = 170.0;
  static const bool _defaultDarkMode = false;

  static Future<double> getWeight() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_weightKey) ?? _defaultWeight;
    } catch (e) {
      return _defaultWeight;
    }
  }

  static Future<void> setWeight(double weight) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_weightKey, weight);
    } catch (e) {
      rethrow;
    }
  }

  static Future<double> getHeight() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_heightKey) ?? _defaultHeight;
    } catch (e) {
      return _defaultHeight;
    }
  }

  static Future<void> setHeight(double height) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_heightKey, height);
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> getDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_darkModeKey) ?? _defaultDarkMode;
    } catch (e) {
      return _defaultDarkMode;
    }
  }

  static Future<void> setDarkMode(bool isDarkMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, isDarkMode);
    } catch (e) {
      rethrow;
    }
  }
}
