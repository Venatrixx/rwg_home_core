part of 'a_level_wrapper.dart';

/// A representation for a subject, that contains its [name], [abbr], [kind] and all [finalGrades] for this subject
class AbstractSubject {
  /// The name of thi subject.
  String name;

  /// The abbreviation for this subject.
  String abbr;

  /// The kind of this subject.
  ///
  /// Can be one of three options:
  /// * `la` = languages and art
  /// * `mint` = science and math
  /// * `sc` = social studies
  String? kind;

  /// List of exactly 4 [AbstractFinalGrade] elements, representing the final grades of this subject.
  List<AbstractFinalGrade> finalGrades;

  /// `true` if any element of [finalGrades] has a [AbstractFinalGrade.value] set to a `non-null` value.
  bool get hasData =>
      finalGrades.any((element) => element.value != null) || examGrade != null;

  /// Calculated the average of this subject based on the [finalGrades] list.
  ///
  /// Returns `null` if there is no [AbstractFinalGrade] with a value that is `non-null`.
  double? get avg {
    if (!hasData) return null;
    int sum = 0, count = 0;
    for (final grade in finalGrades) {
      if (grade.value == null) continue;
      sum += grade.value!;
      count++;
    }
    return sum / count;
  }

  /// Grade for the final exam. Only relevant if this is an exam subject.
  int? examGrade;

  /// The amount of active [AbstractFinalGrade] elements.
  int get activeGradesCount =>
      finalGrades.where((element) => element.active).length;

  List<AbstractFinalGrade> get finalGradesDesc =>
      finalGrades..sort((a, b) => b.compareTo(a));

  List<AbstractFinalGrade> get finalGradesFilled => List.generate(4, (index) {
    var grade = finalGrades[index];
    return grade.copyWith(
      value: grade.value ?? avg?.round(),
      averaged: grade.value == null,
    );
  });

  AbstractSubject({
    required this.name,
    required this.abbr,
    this.kind,
    required this.finalGrades,
    this.examGrade,
  });

  factory AbstractSubject.fromSemesters(
    String name,
    String abbr,
    List<Semester> semesters,
  ) {
    List<AbstractFinalGrade> finalGrades = [];
    for (final semester in semesters.indexed) {
      final sem = semester.$2;
      final index = semester.$1;
      try {
        finalGrades.add(
          AbstractFinalGrade(
            index: index,
            value: sem.subjects
                .firstWhere(
                  (element) => element.abbr.toLowerCase() == abbr.toLowerCase(),
                )
                .finalSemesterGrade,
            active: false,
          ),
        );
      } catch (_) {
        finalGrades.add(AbstractFinalGrade.empty(index: index));
      }
    }
    if (finalGrades.length != 4) {
      throw Exception(
        "ERROR. Did not find exactly 4 matching subjects. The application may not have been initialized correctly.",
      );
    }
    finalGrades.sort((a, b) => a.index.compareTo(b.index));
    return AbstractSubject(name: name, abbr: abbr, finalGrades: finalGrades);
  }

  AbstractSubject.fromJson(dynamic json)
    : name = json['name'],
      abbr = json['abbr'],
      kind = json['kind'],
      finalGrades = [
        for (final elem in json['finalGrades'])
          AbstractFinalGrade.fromJson(elem),
      ],
      examGrade = json['examGrade'];

  dynamic toJson() => {
    'name': name,
    'abbr': abbr,
    'kind': kind,
    'finalGrades': [for (final grade in finalGrades) grade.toJson()],
    'examGrade': examGrade,
  };

  Future<bool> normalize(List rawStructure) async {
    try {
      dynamic subjectStructure = rawStructure.firstWhere(
        ((element) =>
            element['abbr'] == abbr || element['alt_abbr'].contains(abbr)),
      );

      abbr = subjectStructure['abbr'];
      kind = subjectStructure['kind'];
      name = subjectStructure['name'];
      return true;
    } catch (e) {
      try {
        submitAbstractSubject(this);
      } catch (_) {}
      return false;
    }
  }

  void update(
    List<Semester> semesters,
    double Function(int) calculateExamWeight,
  ) {
    List<AbstractFinalGrade> res = [];
    for (final semester in semesters.indexed) {
      final sem = semester.$2;
      final index = semester.$1;
      try {
        int? finalGrade = sem.subjects
            .firstWhere(
              (element) => element.abbr.toLowerCase() == abbr.toLowerCase(),
            )
            .finalSemesterGrade;
        if (finalGrade == null) {
          final average = sem.subjects
              .firstWhere(
                (element) => element.abbr.toLowerCase() == abbr.toLowerCase(),
              )
              .getTotalAvg(calculateExamWeight)
              .round();
          res.add(
            AbstractFinalGrade(index: index, value: average, active: false),
          );
        } else {
          res.add(
            AbstractFinalGrade(index: index, value: finalGrade, active: false),
          );
        }
      } catch (_) {
        res.add(AbstractFinalGrade.empty(index: index));
      }
    }
    finalGrades = res;
    finalGrades.sort((a, b) => a.index.compareTo(b.index));
  }

  int compareToByAverage(AbstractSubject other) {
    if (avg == null && other.avg != null) return -1;
    if (avg == null && other.avg == null) return 0;
    if (avg != null && other.avg == null) return 1;
    return avg!.compareTo(other.avg!);
  }
}
