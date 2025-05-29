class WeeklyExercise {
  /// Date of writing this exercise.
  DateTime? date;

  /// A description of this exercise.
  String? description;

  /// Maximum possible amount of points to get.
  double max;

  /// Amount of points the user achieved.
  double achieved;

  WeeklyExercise({required this.achieved, this.max = 10, this.date, this.description});
}
