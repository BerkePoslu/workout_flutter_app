// Exercise Model
// Author: Berke Poslu
// Date: 2024-04-03
// Version: 1.0.0

class Exercise {
  final String name;
  final int sets;
  final int reps;
  final double weight;
  final String? notes;
  final Duration? restBetweenSets;

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    this.notes,
    this.restBetweenSets,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'notes': notes,
      'restBetweenSets': restBetweenSets?.inSeconds,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      weight: json['weight'] as double,
      notes: json['notes'] as String?,
      restBetweenSets: json['restBetweenSets'] != null
          ? Duration(seconds: json['restBetweenSets'] as int)
          : null,
    );
  }

  Exercise copyWith({
    String? name,
    int? sets,
    int? reps,
    double? weight,
    String? notes,
    Duration? restBetweenSets,
  }) {
    return Exercise(
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
      restBetweenSets: restBetweenSets ?? this.restBetweenSets,
    );
  }
}
