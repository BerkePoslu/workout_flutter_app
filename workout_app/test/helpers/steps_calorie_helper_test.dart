import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/helpers/steps_calorie_helper.dart';

void main() {
  group('StepsCalorieHelper Tests', () {
    test('calculateCaloriesBurned should return correct value', () {
      final helper = StepsCalorieHelper(weightInKg: 70.0);

      // Test with 1000 steps
      expect(helper.calculateCaloriesBurned(1000),
          equals(35.0)); // 1000 * 70 * 0.0005

      // Test with 0 steps
      expect(helper.calculateCaloriesBurned(0), equals(0.0));

      // Test with negative steps (should handle gracefully)
      expect(helper.calculateCaloriesBurned(-1000), equals(0.0));
    });

    test('calculateCaloriesBurned should handle different weights', () {
      // Test with 50kg weight
      final helper50kg = StepsCalorieHelper(weightInKg: 50.0);
      expect(helper50kg.calculateCaloriesBurned(1000),
          equals(25.0)); // 1000 * 50 * 0.0005

      // Test with 100kg weight
      final helper100kg = StepsCalorieHelper(weightInKg: 100.0);
      expect(helper100kg.calculateCaloriesBurned(1000),
          equals(50.0)); // 1000 * 100 * 0.0005
    });

    test('calculateCaloriesBurned should handle edge cases', () {
      final helper = StepsCalorieHelper(weightInKg: 70.0);

      // Test with very large number of steps
      expect(helper.calculateCaloriesBurned(100000), equals(3500.0));

      // Test with regular steps
      expect(helper.calculateCaloriesBurned(1000), equals(35.0));
    });
  });
}
