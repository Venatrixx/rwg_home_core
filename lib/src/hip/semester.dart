part of 'hip_wrapper.dart';

/// A [Semester] stores a list of [Subject] elements and additional meta data for a semester.
///
/// A [Semester] should only ever contain the data for one semester only.
class Semester {
  /// Label or name the semester is referred to. E.g. "11.2" or "8.1".
  late String label;

  /// Level of this semester.
  late int level;

  /// List of [Subject] elements stored for this semester.
  List<Subject> subjects = [];

  /// Returns `true` if at least one subject has at least one grade.
  bool get hasData => subjects.any((element) => element.hasData);

  /// Returns `true` if at least one subject has a final grade.
  bool get hasFinalGrades => subjects.any((element) => element.finalSemesterGrade != null);

  /// The date of the last update of this semester.
  DateTime? lastUpdate;

  /// If set to `true`, this semester should not be changed anymore by any means.
  ///
  /// [LockedError] is thrown if values are changed and [locked] is `true`.
  ///
  /// Defaults to `false`.
  late bool locked;

  Semester({required this.label, required this.level, required this.subjects, this.locked = false, this.lastUpdate});

  Semester.detailed(this.label, this.level, this.subjects, this.lastUpdate, this.locked);

  Semester.fromJson(dynamic json) {
    label = json['label'];
    level = json['level'];
    locked = json['locked'] ?? false;
    subjects = [for (final elem in json['subjects'] ?? []) Subject.fromJson(elem)];
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'level': level,
      'locked': locked,
      'subjects': [for (final subject in subjects) subject.toJson()],
    };
  }

  /// Creates a copy of this object.
  Semester clone() {
    return Semester.detailed(label, level, [for (final subject in subjects) subject.clone()], lastUpdate, locked);
  }

  /// Creates a copy of this object without the single grades.
  Semester cloneStructure() {
    return Semester.detailed(
      label,
      level,
      [for (final subject in subjects) subject.cloneStructure()],
      lastUpdate,
      locked,
    );
  }

  /// Calls the provided [decideIfSek2] method with [Semester.level] property of `this`.
  ///
  /// It is recommended to call this method as follows:
  /// ```dart
  /// isSek2(HipWrapper.isSek2);
  /// ```
  bool isSek2(bool Function(int) decideIfSek2) => decideIfSek2(level);

  /// Calls [Subject.setAllGradesSeen] on all elements of [subjects].
  ///
  /// **Remember** that [Subject.setAllGradesSeen] contains a delay of 3 seconds.
  ///
  /// See [setAllGradesSeenSync] to do so without a delay.
  void setAllGradesSeen() {
    for (final subject in subjects) {
      subject.setAllGradesSeen();
    }
  }

  /// Calls [Subject.setAllGradesSeenSync] on all elements of [subjects].
  void setAllGradesSeenSync() {
    for (final subject in subjects) {
      subject.setAllGradesSeenSync();
    }
  }

  /// Takes another [Semester] and adds additional data to `this`.
  ///
  /// For new grades, [Grade.seen] is set to `false`.
  ///
  /// Returns a list of [SpecialGrade] with online grades, that have changed.
  List<SpecialGrade> addDataFromSemester(Semester other, {bool keepFinalGrades = false}) {
    if (locked) return [];

    List<SpecialGrade> changedGrades = [];
    for (final subject in other.subjects) {
      if (!subjects.contains(subject)) {
        // add subject if it does not exist
        subjects.add(subject.clone());
        continue;
      }
      // add additional data to the subject
      changedGrades.addAll(
        subjects
            .firstWhere((element) => element.abbr == subject.abbr)
            .addGradesFromSubject(subject, keepFinalGrades: keepFinalGrades),
      );
    }

    lastUpdate = DateTime.now();

    return changedGrades;
  }

  /// Delete all subjects. If [keepStructure] is set to `true`, only the grades are removed.
  void clear({bool keepStructure = false}) {
    if (keepStructure) {
      subjects = [for (final subject in subjects) subject.cloneStructure()];
    } else {
      subjects.clear();
    }
  }

  /// The average of all subjects of this semester.
  ///
  /// Function **does not** round values internally.
  double getExactAvg(DataWrapper data) {
    double sum = 0;
    int index = 0;

    for (final subject in subjects) {
      if (data.aLevel.hiddenSubjects.contains(subject.abbr.toLowerCase())) continue;
      double average = subject.getTotalAvg(data.calculateExamWeight);
      if (average.isNaN) continue;
      sum += average;
      index++;
    }

    return sum / index;
  }

  /// Function rounds subjects average to the closest integer, or uses final semester grade if available, and uses this value to calculate the total average.
  double getRoundedAvg(DataWrapper data) {
    double sum = 0;
    int index = 0;

    for (final subject in subjects) {
      if (data.aLevel.hiddenSubjects.contains(subject.abbr.toLowerCase())) continue;
      double average = subject.getTotalAvg(data.calculateExamWeight);
      if (average.isNaN) continue;
      sum += average.roundToDouble();
      index++;
    }

    return sum / index;
  }

  /// Average of all grades in this semester with equal weighing for all grades.
  double getBalancedAvg(DataWrapper data) {
    double sum = 0;
    int index = 0;

    for (final subject in subjects) {
      if (data.aLevel.hiddenSubjects.contains(subject.abbr.toLowerCase())) continue;
      for (final grade in subject.onlineGrades) {
        if (!grade.isEmpty && !grade.ghost) {
          sum += grade.gradeValue!;
          index++;
        }
      }
      for (final grade in subject.customGrades) {
        if (!grade.isEmpty && !grade.ghost) {
          sum += grade.gradeValue!;
          index++;
        }
      }
    }

    return sum / index;
  }

  @override
  String toString() {
    return "Semester with label '$label' and ${subjects.length} subjects.";
  }
}
