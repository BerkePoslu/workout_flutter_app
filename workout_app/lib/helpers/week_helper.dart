import 'package:shared_preferences/shared_preferences.dart';
import '../models/week.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

// Workout Helper
// Author: Berke Poslu
// Date: 2025-04-03
// Version: 1.0.0
// This class is used to get the workouts for the week

class WeekHelper {
  static const String _weekKey = 'week_schedule';
  static final Map<String, Week?> _defaultWeek = {
    'Monday': null,
    'Tuesday': null,
    'Wednesday': null,
    'Thursday': null,
    'Friday': null,
    'Saturday': null,
    'Sunday': null,
  };

  static Future<Map<String, Week?>> getWeekSchedule() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final weekJson = prefs.getString(_weekKey);

      if (weekJson == null) {
        return _defaultWeek;
      }

      final Map<String, dynamic> weekMap = json.decode(weekJson);
      return weekMap.map((key, value) => MapEntry(
            key,
            value == null ? null : Week.fromJson(value as Map<String, dynamic>),
          ));
    } catch (e) {
      print('Error loading week schedule: $e');
      return _defaultWeek;
    }
  }

  static Future<void> updateWeekSchedule(Map<String, Week?> week) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final weekJson = json.encode(
        week.map((key, value) => MapEntry(
              key,
              value?.toJson(),
            )),
      );
      await prefs.setString(_weekKey, weekJson);
    } catch (e) {
      print('Error saving week schedule: $e');
    }
  }

  static Future<Week?> getTodaysWorkout() async {
    final week = await getWeekSchedule();
    final today = DateTime.now();
    final dayName = _getDayName(today.weekday);
    return week[dayName];
  }

  static String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return 'Monday';
    }
  }

  static Future<void> updateTodaysWorkout(Week workout) async {
    try {
      final schedule = await getWeekSchedule();
      final today = DateFormat('EEEE').format(DateTime.now());
      schedule[today] = workout;
      await updateWeekSchedule(schedule);
    } catch (e) {
      print('Error updating today\'s workout: $e');
      throw Exception('Failed to update today\'s workout');
    }
  }
}
