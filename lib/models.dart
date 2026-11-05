import 'dart:convert';

class Exercise {
  final String id;
  final String name;
  final String description;

  Exercise({required this.id, required this.name, required this.description});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
  };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    id: json['id'],
    name: json['name'],
    description: json['description'],
  );
}

class WorkoutSet {
  final Exercise exercise;
  int targetReps;
  double weightKg;
  int actualReps;
  List<String> repFeedbacks;

  WorkoutSet({
    required this.exercise,
    this.targetReps = 10,
    this.weightKg = 0.0,
    this.actualReps = 0,
    List<String>? repFeedbacks,
  }) : repFeedbacks = repFeedbacks ?? [];

  Map<String, dynamic> toJson() => {
    'exercise': exercise.toJson(),
    'targetReps': targetReps,
    'weightKg': weightKg,
    'actualReps': actualReps,
    'repFeedbacks': repFeedbacks,
  };

  factory WorkoutSet.fromJson(Map<String, dynamic> json) => WorkoutSet(
    exercise: Exercise.fromJson(json['exercise']),
    targetReps: json['targetReps'],
    weightKg: json['weightKg'],
    actualReps: json['actualReps'],
    repFeedbacks: List<String>.from(json['repFeedbacks'] ?? []),
  );
}

class WorkoutSession {
  final DateTime date;
  final List<WorkoutSet> sets;

  WorkoutSession({required this.date, required this.sets});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'sets': sets.map((s) => s.toJson()).toList(),
  };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
    date: DateTime.parse(json['date']),
    sets: (json['sets'] as List).map((s) => WorkoutSet.fromJson(s)).toList(),
  );
}