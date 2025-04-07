// WorkoutTemplate Model
// Author: Berke Poslu
// Date: 2024-04-03
// Version: 1.0.0

import 'exercise.dart';

class WorkoutTemplate {
  final String id;
  final String name;
  final String type;
  final List<Exercise> exercises;
  final String? notes;
  final Duration? duration;
  final DateTime createdAt;
  final DateTime lastUsed;

  WorkoutTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.exercises,
    this.notes,
    this.duration,
    DateTime? createdAt,
    DateTime? lastUsed,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastUsed = lastUsed ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'notes': notes,
      'duration': duration?.inMinutes,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed.toIso8601String(),
    };
  }

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      exercises: (json['exercises'] as List?)
              ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String?,
      duration: json['duration'] != null
          ? Duration(minutes: json['duration'] as int)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsed: DateTime.parse(json['lastUsed'] as String),
    );
  }

  WorkoutTemplate copyWith({
    String? id,
    String? name,
    String? type,
    List<Exercise>? exercises,
    String? notes,
    Duration? duration,
    DateTime? lastUsed,
  }) {
    return WorkoutTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      exercises: exercises ?? this.exercises,
      notes: notes ?? this.notes,
      duration: duration ?? this.duration,
      createdAt: createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutTemplate &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          exercises == other.exercises &&
          notes == other.notes &&
          duration == other.duration &&
          createdAt == other.createdAt &&
          lastUsed == other.lastUsed;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      exercises.hashCode ^
      notes.hashCode ^
      duration.hashCode ^
      createdAt.hashCode ^
      lastUsed.hashCode;
}
