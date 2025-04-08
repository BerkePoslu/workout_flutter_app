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
    print('Parsing DailySteps from JSON: $json'); // Debug print

    // Validate required fields
    if (json['id'] == null) {
      print('Warning: id is null, using generated ID');
      json['id'] = 'step_${DateTime.now().millisecondsSinceEpoch}';
    }

    if (json['userId'] == null) {
      print('Warning: userId is null, using default');
      json['userId'] = 'unknown_user';
    }

    if (json['steps'] == null) {
      print('Warning: steps is null, defaulting to 0');
      json['steps'] = 0;
    }

    if (json['date'] == null) {
      print('Warning: date is null, using current date');
      json['date'] = DateTime.now().toIso8601String();
    }

    return DailySteps(
      id: json['id'].toString(),
      userId: json['userId'].toString(),
      steps: json['steps'] is int
          ? json['steps']
          : int.parse(json['steps'].toString()),
      date: DateTime.parse(json['date']),
    );
  }
}
