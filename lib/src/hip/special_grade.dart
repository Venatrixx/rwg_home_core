part of 'hip_wrapper.dart';

/// A [SpecialGrade] holds a reference to a [Grade] that has a special property.
///
/// This grade is stored under [primary].
/// "Special properties" may include:
/// * unseen grades,
/// * grades that have been changed or
/// * grades with possible duplicates, where the duplicates are stored under [similarGrades].
class SpecialGrade {
  /// Holds a reference to the "special" grade.
  Grade primary;

  /// List of all other grades, that might be similar to the [primary] grade.
  List<Grade>? similarGrades;

  Grade get grade {
    if (similarGrades?.isNotEmpty ?? false) return similarGrades!.first;
    return primary;
  }

  /// The parent [Subject] of the grades.
  Subject parentSubject;

  /// The parent [Semester] of the [parentSubject].
  Semester? parentSemester;

  /// Creates an instance of [SpecialGrade].
  SpecialGrade({required this.primary, this.similarGrades, required this.parentSubject, this.parentSemester});
}
