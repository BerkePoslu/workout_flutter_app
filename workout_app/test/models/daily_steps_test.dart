import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/models/daily_steps.dart';

void main() {
  group('DailySteps Model Tests', () {
    test('fromJson should parse valid JSON correctly', () {
      final json = {
        'id': 'step_123',
        'userId': 'user_123',
        'steps': 5000,
        'date': '2024-04-08T12:00:00.000Z',
      };

      final dailySteps = DailySteps.fromJson(json);

      expect(dailySteps.id, 'step_123');
      expect(dailySteps.userId, 'user_123');
      expect(dailySteps.steps, 5000);
      expect(dailySteps.date, DateTime.parse('2024-04-08T12:00:00.000Z'));
    });

    test('fromJson should handle null values with defaults', () {
      final json = {
        'id': null,
        'userId': null,
        'steps': null,
        'date': null,
      };

      final dailySteps = DailySteps.fromJson(json);

      expect(dailySteps.id, isNotNull);
      expect(dailySteps.userId, 'unknown_user');
      expect(dailySteps.steps, 0);
      expect(dailySteps.date, isNotNull);
    });

    test('toJson should convert model to JSON correctly', () {
      final dailySteps = DailySteps(
        id: 'step_123',
        userId: 'user_123',
        steps: 5000,
        date: DateTime.parse('2024-04-08T12:00:00.000Z'),
      );

      final json = dailySteps.toJson();

      expect(json['id'], 'step_123');
      expect(json['userId'], 'user_123');
      expect(json['steps'], 5000);
      expect(json['date'], '2024-04-08T12:00:00.000Z');
    });
  });
}
