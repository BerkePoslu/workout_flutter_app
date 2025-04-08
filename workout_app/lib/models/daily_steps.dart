class DailySteps {
  final String id;
  final String userId;
  final int steps;
  final DateTime date;

  DailySteps({
    required this.id,
    required this.userId,
    required this.steps,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'steps': steps,
        'date': date.toIso8601String(),
      };

  factory DailySteps.fromJson(Map<String, dynamic> json) {
    // AI generated - Handle null values with defaults
    final id = json['id']?.toString() ??
        'step_${DateTime.now().millisecondsSinceEpoch}';
    final userId = json['userId']?.toString() ?? 'unknown_user';
    final steps = json['steps'] is int
        ? json['steps']
        : int.tryParse(json['steps']?.toString() ?? '0') ?? 0;
    final date = json['date'] != null
        ? DateTime.parse(json['date'].toString())
        : DateTime.now();

    return DailySteps(
      id: id,
      userId: userId,
      steps: steps,
      date: date,
    );
  }
}
