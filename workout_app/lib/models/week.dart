// Week Model
// Author: Berke Poslu
// Date: 2024-04-03
// Version: 1.0.0

import 'exercise.dart';

class Week {
  final String? id; // ID to link with template
  final String name;
  final String type;
  final String day;
  final List<Exercise>? exercises;
  final String? notes;
  final Duration? duration;

  Week({
    this.id,
    required this.name,
    required this.type,
    required this.day,
    this.exercises,
    this.notes,
    this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'day': day,
      'exercises': exercises?.map((e) => e.toJson()).toList(),
    };
  }

  factory Week.fromMap(Map<String, dynamic> map) {
    return Week(
      name: map['name'],
      type: map['type'],
      day: map['day'],
      exercises: map['exercises'] != null
          ? (map['exercises'] as List)
              .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'day': day,
      'exercises': exercises?.map((e) => e.toJson()).toList(),
      'notes': notes,
      'duration': duration?.inMinutes,
    };
  }

  factory Week.fromJson(Map<String, dynamic> json) {
    return Week(
      id: json['id'] as String?,
      name: json['name'] as String,
      type: json['type'] as String,
      day: json['day'] as String,
      exercises: json['exercises'] != null
          ? (json['exercises'] as List)
              .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      notes: json['notes'] as String?,
      duration: json['duration'] != null
          ? Duration(minutes: json['duration'] as int)
          : null,
    );
  }
}
