import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_template.dart';
import 'package:uuid/uuid.dart';

// workout template helper
// author: Berke Poslu
// date: 2025-04-07
// version: 1.0.0
// this helper is used to save, load, and delete workout templates
// it also has a method to generate a unique id for a workout template

class WorkoutTemplateHelper {
  static const String _templatesKey = 'workout_templates';
  static final _uuid = Uuid();

  static Future<List<WorkoutTemplate>> getAllTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = prefs.getString(_templatesKey);

      if (templatesJson == null) {
        return [];
      }

      final List<dynamic> templatesList = json.decode(templatesJson);
      return templatesList
          .map((json) => WorkoutTemplate.fromJson(json))
          .toList()
        ..sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
    } catch (e) {
      print('Error loading templates: $e');
      return [];
    }
  }

  static Future<void> saveTemplate(WorkoutTemplate template) async {
    try {
      final templates = await getAllTemplates();
      final existingIndex = templates.indexWhere((t) => t.id == template.id);

      if (existingIndex >= 0) {
        templates[existingIndex] = template;
      } else {
        templates.add(template);
      }

      final prefs = await SharedPreferences.getInstance();
      final templatesJson =
          json.encode(templates.map((t) => t.toJson()).toList());
      await prefs.setString(_templatesKey, templatesJson);
    } catch (e) {
      print('Error saving template: $e');
      throw Exception('Failed to save workout template');
    }
  }

  static Future<void> deleteTemplate(String templateId) async {
    try {
      final templates = await getAllTemplates();
      templates.removeWhere((t) => t.id == templateId);

      final prefs = await SharedPreferences.getInstance();
      final templatesJson =
          json.encode(templates.map((t) => t.toJson()).toList());
      await prefs.setString(_templatesKey, templatesJson);
    } catch (e) {
      print('Error deleting template: $e');
      throw Exception('Failed to delete workout template');
    }
  }

  static Future<void> updateTemplateLastUsed(String templateId) async {
    try {
      final templates = await getAllTemplates();
      final index = templates.indexWhere((t) => t.id == templateId);

      if (index >= 0) {
        final template = templates[index];
        final updated = template.copyWith(lastUsed: DateTime.now());
        templates[index] = updated;

        final prefs = await SharedPreferences.getInstance();
        final templatesJson =
            json.encode(templates.map((t) => t.toJson()).toList());
        await prefs.setString(_templatesKey, templatesJson);
      }
    } catch (e) {
      print('Error updating template last used: $e');
    }
  }

  static String generateId() {
    return _uuid.v4();
  }
}
