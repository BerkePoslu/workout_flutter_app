import 'dart:math';
import '../models/daily_steps.dart';

class SampleDataGenerator {
  // Generate a single day of step data for admin user
  static DailySteps generateAdminDailySteps(
      {String userId = 'adminuser', DateTime? date}) {
    final random = Random();
    return DailySteps(
      id: 'step_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      steps:
          random.nextInt(15000) + 2000, // Random steps between 2000 and 17000
      date: date ?? DateTime.now(),
    );
  }

  // Generate multiple days of step data for admin user
  static List<DailySteps> generateAdminWeeklySteps(
      {String userId = 'adminuser', DateTime? startDate}) {
    final start = startDate ?? DateTime.now().subtract(Duration(days: 6));
    final List<DailySteps> weeklySteps = [];

    for (int i = 0; i < 7; i++) {
      final date = start.add(Duration(days: i));
      weeklySteps.add(generateAdminDailySteps(userId: userId, date: date));
    }

    return weeklySteps;
  }

  // Convert data to JSON format for Postman/backend use
  static Map<String, dynamic> dailyStepsToJson(DailySteps steps) {
    return steps.toJson();
  }

  // Convert list of data to JSON format for Postman/backend use
  static List<Map<String, dynamic>> weeklyStepsToJson(List<DailySteps> steps) {
    return steps.map((step) => step.toJson()).toList();
  }

  // Print sample JSON for copying to Postman
  static void printSampleDataForPostman(
      {String userId = 'adminuser', bool weekly = false}) {
    if (weekly) {
      final weeklyData = generateAdminWeeklySteps(userId: userId);
      final jsonData = weeklyStepsToJson(weeklyData);
      print('=== WEEKLY STEPS SAMPLE DATA FOR POSTMAN ===');
      print(jsonData);
    } else {
      final dailyData = generateAdminDailySteps(userId: userId);
      final jsonData = dailyStepsToJson(dailyData);
      print('=== DAILY STEPS SAMPLE DATA FOR POSTMAN ===');
      print(jsonData);
    }
  }
}
