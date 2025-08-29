part of 'hip_wrapper.dart';

/// Saves the data for one subject for one whole year.
///
/// **See also:**
/// * [AbstractYear]
class AbstractYearSubject {
  /// Name of this subject.
  String name;

  /// Abbreviation of this subject.
  String abbr;

  /// A final grade by the teacher.
  int? finalGrade;

  /// List of exam grades as [AbstractFinalGrade]s for the first semester of the year.
  List<AbstractFinalGrade> exams1;

  /// List of exam grades as [AbstractFinalGrade]s for the second semester of the year.
  List<AbstractFinalGrade> exams2;

  /// List of all exam grades.
  List<AbstractFinalGrade> get allExams => [...exams1, ...exams2];

  /// Returns the average of all exams.
  ///
  /// Returns `null` if [allExams] is empty.
  double? get examsAverage {
    if (allExams.isEmpty) return null;
    int sum = 0, count = 0;
    for (final grade in allExams) {
      if (grade.value == null) continue;
      sum += grade.value!;
      count++;
    }
    return (sum / count);
  }

  /// List of test grades as [AbstractFinalGrade]s for the first semester of the year.
  List<AbstractFinalGrade> tests1;

  /// List of test grades as [AbstractFinalGrade]s for the second semester of the year.
  List<AbstractFinalGrade> tests2;

  /// List of all test grades.
  List<AbstractFinalGrade> get allTests => [...tests1, ...tests2];

  /// Returns the average of all tests.
  ///
  /// Returns `null` if [allTests] is empty.
  double? get testsAverage {
    if (allTests.isEmpty) return null;
    int sum = 0, count = 0;
    for (final grade in allTests) {
      if (grade.value == null) continue;
      sum += grade.value!;
      count++;
    }
    return (sum / count);
  }

  /// If there is any grade with valid data.
  bool get hasData => [...allExams, ...allTests].any((element) => element.value != null);

  /// Returns the total weighted average for this subject.
  ///
  /// Returns `null` if [allExams] and [allTests] are empty.
  double? getTotalAverage(double Function(int) getExamWeight) {
    if (allExams.isEmpty && allTests.isEmpty) return null;
    if (allExams.isEmpty) return testsAverage;
    if (allTests.isEmpty) return examsAverage;

    final examsWeight = getExamWeight(allExams.where((element) => element.value != null).length);
    final testsWeight = 1 - examsWeight;

    return (examsAverage! * examsWeight) + (testsAverage! * testsWeight);
  }

  double getSpecificExamWeight(double Function(int) getExamWeight) {
    return getExamWeight(allExams.where((element) => element.value != null).length);
  }

  AbstractYearSubject({
    required this.name,
    required this.abbr,
    this.exams1 = const [],
    this.exams2 = const [],
    this.tests1 = const [],
    this.tests2 = const [],
    this.finalGrade,
  });

  factory AbstractYearSubject.fromSemesters(Subject refSubject, List<Semester> semesters) {
    semesters = [for (final sem in semesters) sem.clone()];
    refSubject = refSubject.clone();

    List<AbstractFinalGrade> exams1 = [];
    List<AbstractFinalGrade> exams2 = [];
    List<AbstractFinalGrade> tests1 = [];
    List<AbstractFinalGrade> tests2 = [];

    int? finalGrade;

    for (int i = 0; i < semesters.length; i++) {
      if (i > 1) break;

      final semester = semesters[i];

      if (!(semester.subjects.any((element) => element == refSubject))) continue;
      final subject = semester.subjects.firstWhere((element) => element == refSubject);

      List<AbstractFinalGrade> exams = [
        for (final grade in subject.onlineGrades.where((element) => element.isExam))
          AbstractFinalGrade.fromValue(grade.gradeValue),

        for (final grade in subject.customGrades.where((element) => element.isExam))
          AbstractFinalGrade.fromValue(grade.gradeValue),
      ];

      List<AbstractFinalGrade> tests = [
        for (final grade in subject.onlineGrades.where((element) => !element.isExam))
          AbstractFinalGrade.fromValue(grade.gradeValue),

        for (final grade in subject.customGrades.where((element) => !element.isExam))
          AbstractFinalGrade.fromValue(grade.gradeValue),
      ];

      if (i == 0) {
        exams1.addAll(exams);
        tests1.addAll(tests);
      } else if (i == 1) {
        exams2.addAll(exams);
        tests2.addAll(tests);
      }

      if (i == 1 || semesters.length == 1) {
        finalGrade = subject.finalSemesterGrade;
      }
    }

    return AbstractYearSubject(
      name: refSubject.name,
      abbr: refSubject.abbr,
      finalGrade: finalGrade,
      exams1: exams1,
      exams2: exams2,
      tests1: tests1,
      tests2: tests2,
    );
  }
}
