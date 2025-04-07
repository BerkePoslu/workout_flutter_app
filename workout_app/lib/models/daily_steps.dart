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

  factory DailySteps.fromJson(Map<String, dynamic> json) => DailySteps(
        id: json['id'],
        userId: json['userId'],
        steps: json['steps'],
        date: DateTime.parse(json['date']),
      );
}
