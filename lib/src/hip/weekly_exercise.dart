part of 'hip_wrapper.dart';

class WeeklyExercise {
  /// Key of this object.
  String key;

  /// Date of writing this exercise.
  DateTime? date;

  /// A description of this exercise.
  String? description;

  /// Maximum possible amount of points to get.
  double max;

  /// Amount of points the user achieved.
  double achieved;

  WeeklyExercise({required this.key, required this.achieved, this.max = 10, this.date, this.description});

  @override
  bool operator ==(covariant WeeklyExercise other) {
    return key == other.key;
  }
}
