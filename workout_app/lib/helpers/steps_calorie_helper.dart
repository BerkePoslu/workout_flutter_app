class StepsCalorieHelper {
  final double weightInKg;
  final double _calorieFactor;

  // Steps Calorie Helper class
  // Author: Berke Poslu
  // Date: 2025-04-07
  // Description: Helper class for steps calorie calculation

  StepsCalorieHelper({required this.weightInKg})
      : _calorieFactor = weightInKg * 0.0005;

  double calculateCaloriesBurned(int steps) {
    try {
      // precalculated factor for better performance got the idea from stackoverflow
      return steps * _calorieFactor;
    } catch (e) {
      print('Error calculating calories: $e');
      return 0.0; // Return 0 if calculation fails
    }
  }
}
