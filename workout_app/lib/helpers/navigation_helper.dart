import 'package:flutter/material.dart';
import '../pages/workout_week.dart';
import '../pages/Homescreen.dart';
import '../pages/Workout_Template.dart';
import '../models/workout_template.dart';
import '../models/week.dart';

// Navigation Helper class
// Author: Berke Poslu
// Date: 2025-04-07
// Description: Helper class for navigation functionality

class NavigationHelper {
  static Future<T?> push<T>(
    BuildContext context,
    String routeName, {
    VoidCallback? toggleTheme,
    bool? isDarkMode,
    WorkoutTemplate? initialTemplate,
    bool isSelectionMode = false,
    Function(WorkoutTemplate)? onTemplateSelected,
  }) async {
    MaterialPageRoute<T>? route;

    // switch case for the route name instead of if statements
    switch (routeName) {
      case 'workout_week':
        route = MaterialPageRoute<T>(builder: (context) => const WorkoutWeek());
        break;
      case 'homescreen':
        if (toggleTheme != null && isDarkMode != null) {
          route = MaterialPageRoute<T>(
            builder: (context) => HomeScreen(
              toggleTheme: toggleTheme,
              isDarkMode: isDarkMode,
            ),
          );
        }
        break;
      case 'workout_template':
        if (initialTemplate != null) {
          route = MaterialPageRoute<T>(
            builder: (context) => WorkoutTemplateScreen(
              initialTemplate: initialTemplate,
              isSelectionMode: isSelectionMode,
              onTemplateSelected: onTemplateSelected,
            ),
          );
        }
        break;
    }

    if (route != null) {
      return Navigator.push(context, route);
    }
    return Navigator.push(
        context,
        MaterialPageRoute<T>(
            builder: (context) => HomeScreen(
                toggleTheme: toggleTheme ?? () {},
                isDarkMode: isDarkMode ?? false)));
  }
}
