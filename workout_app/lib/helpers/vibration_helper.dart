import 'package:flutter/services.dart';

// Vibration Helper class
// Author: Berke Poslu
// Date: 2025-04-07
// Description: Helper class for vibration functionality

class VibrationHelper {
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }
}
