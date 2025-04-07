import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/daily_steps.dart';

class StepsPersistenceHelper {
  static const String _stepsKey = 'current_steps';
  static const String _lastSavedDateKey = 'last_saved_date';

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
    try {
      final response = await http.post(
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
    } catch (e) {
      print('Error saving steps to database: $e');
    }
  }

  static Future<List<DailySteps>> getWeeklySteps(String userId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://workout-app-backend-delta.vercel.app/api/steps/weekly?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => DailySteps.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching weekly steps: $e');
      return [];
    }
  }
}
