part of 'hip_wrapper.dart';

/// Summarizes the subjects and their grades from a whole year, not just one semester.
class AbstractYear {
  AbstractYear({required this.level, this.subjects = const []});

  /// The level of this year.
  int level;

  /// List of all subjects as [AbstractYearSubject] objects.
  List<AbstractYearSubject> subjects;

  factory AbstractYear.fromSemesters(int level, List<Semester> semesters) {
    semesters = [for (final sem in semesters.where((element) => element.level == level)) sem.clone()];
    List<AbstractYearSubject> subjects = [];

    if (semesters.isNotEmpty) {
      for (final subject in semesters.first.subjects) {
        subjects.add(AbstractYearSubject.fromSemesters(subject, semesters));
      }
    }

    return AbstractYear(level: level, subjects: subjects);
  }
}
