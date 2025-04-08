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
      // AI generated - Handle negative steps by returning 0
      if (steps < 0) return 0.0;

      // precalculated factor for better performance got the idea from stackoverflow
      return double.parse((steps * _calorieFactor).toStringAsFixed(1));
    } catch (e) {
      return 0;
    }
  }
}
