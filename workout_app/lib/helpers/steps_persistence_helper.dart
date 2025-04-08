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
    try {
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
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<DailySteps>> getWeeklySteps(String userId) async {
    print('1. Starting getWeeklySteps with userId: $userId');
    try {
      print('2. Getting token from SharedPreferences');
      final token = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token'));
      print('3. Token retrieved: ${token != null ? 'exists' : 'null'}');

      print('4. Making HTTP request to weekly steps endpoint');
      final response = await _httpClient.get(
        Uri.parse(
            'https://workout-app-backend-delta.vercel.app/api/steps/weekly'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      print('5. Response status code: ${response.statusCode}');
      print('6. Raw response body: ${response.body}');

      if (response.statusCode == 200) {
        print('7. Parsing response data');
        final List<dynamic> data = json.decode(response.body);
        print('8. Parsed data length: ${data.length}');

        // Print each item's structure
        for (var i = 0; i < data.length; i++) {
          print('Item $i: ${data[i]}');
        }

        return data.map((json) {
          try {
            return DailySteps.fromJson(json);
          } catch (e) {
            print('Error parsing item: $json');
            print('Error details: $e');
            rethrow;
          }
        }).toList();
      }
      print(
          '9. Failed to get weekly steps. Status code: ${response.statusCode}');
      return [];
    } catch (e, stackTrace) {
      print('10. Error in getWeeklySteps: $e');
      print('11. Stack trace: $stackTrace');
      return [];
    }
  }
}
