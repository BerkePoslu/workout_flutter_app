import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/daily_steps.dart';

class StepsPersistenceHelper {
  static const String _stepsKey = 'current_steps';
  static const String _lastSavedDateKey = 'last_saved_date';
  static http.Client? _client;

  static set httpClient(http.Client client) {
    _client = client;
  }

  static http.Client get _httpClient => _client ?? http.Client();

  static Future<void> saveCurrentSteps(int steps) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_stepsKey, steps);
  }

  static Future<int> getCurrentSteps() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_stepsKey) ?? 0;
  }

  static Future<bool> shouldSaveToDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSavedDate = prefs.getString(_lastSavedDateKey);
    if (lastSavedDate == null) return true;

    final lastDate = DateTime.parse(lastSavedDate);
    final now = DateTime.now();
    return now.day != lastDate.day;
  }

  static Future<void> saveToDatabase(String userId, int steps) async {
    final response = await _httpClient.post(
      Uri.parse('https://workout-app-backend-delta.vercel.app/api/steps'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'userId': userId,
        'steps': steps,
        'date': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _lastSavedDateKey, DateTime.now().toIso8601String());
      await prefs.setInt(_stepsKey, 0); // Reset steps after saving
    }
  }

  static Future<List<DailySteps>> getWeeklySteps(String userId) async {
    final token = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('token'));

    final response = await _httpClient.get(
      Uri.parse(
          'https://workout-app-backend-delta.vercel.app/api/steps/weekly'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => DailySteps.fromJson(json)).toList();
    }

    return [];
  }
}
