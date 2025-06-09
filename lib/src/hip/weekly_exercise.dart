part of 'hip_wrapper.dart';

class WeeklyExercise {
  /// Key of this object.
  late String key;

  /// Date of writing this exercise.
  DateTime? date;

  /// A description of this exercise.
  String? description;

  /// Maximum possible amount of points to get.
  late double max;

  /// Amount of points the user achieved.
  late double achieved;

  WeeklyExercise({required this.key, required this.achieved, this.max = 10, this.date, this.description});

  WeeklyExercise.fromJson(dynamic json) {
    key = json['key'];
    if (json['date'] is int) date = DateTime.fromMillisecondsSinceEpoch(json['date']);
    description = json['description'];
    max = json['max'];
    achieved = json['achieved'];
  }

  Map toJson() => {
    'key': key,
    'date': date?.millisecondsSinceEpoch,
    'description': description,
    'max': max,
    'achieved': achieved,
  };

  @override
  bool operator ==(covariant WeeklyExercise other) {
    return key == other.key;
  }
}
