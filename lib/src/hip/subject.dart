part of 'hip_wrapper.dart';

/// A [Subject] stores a list of [Grade] elements and additional meta data for a subject.
///
/// A [Subject] should only ever contain the data for one semester.
class Subject {
  /// Display name of the subject.
  ///
  /// E.g. "Math" or "English".
  late String name;

  /// Abbreviation for the subject. E.g. "ma" or "en".
  ///
  /// The abbreviation has to be **unique** as it is used to differentiate between the subjects.
  late String abbr;

  /// The final grade of this subject for a semester.
  int? finalSemesterGrade;

  /// All grades listed on Home.InfoPoint.
  List<Grade> onlineGrades = [];

  /// All grades added by the user.
  List<Grade> customGrades = [];

  /// List of all tests, online and custom.
  ///
  /// Sorted by their date.
  List<Grade> get tests =>
      [...onlineGrades, ...customGrades].where((e) => !e.isExam).toList()
        ..sort((a, b) => a.date.compareToAware(b.date));

  /// List of all exams, online and custom.
  ///
  /// Sorted by their date.
  List<Grade> get exams =>
      [...onlineGrades, ...customGrades].where((e) => e.isExam).toList()..sort((a, b) => a.date.compareToAware(b.date));

  /// List of all grade, online and custom.
  ///
  /// Sorted by their date.
  List<Grade> get allGrades => [...onlineGrades, ...customGrades]..sort((a, b) => a.date.compareToAware(b.date));

  /// Whether this subject has any grades stored.
  bool get hasData => onlineGrades.isNotEmpty || customGrades.isNotEmpty;

  /// Whether this subject has any grades, where [Grade.unSeen] is `true`.
  bool get hasUnseenGrades => tests.any((element) => element.unSeen) || exams.any((element) => element.unSeen);

  /// A [Subject] stores a list of [Grade] elements and additional meta data for a subject.
  ///
  /// A [Subject] should only ever contain the data for one semester.
  Subject({
    required this.name,
    required this.abbr,
    required this.onlineGrades,
    this.customGrades = const [],
    this.finalSemesterGrade,
  });

  Subject.detailed(this.name, this.abbr, this.onlineGrades, this.customGrades, this.finalSemesterGrade);

  /// Creates a [Subject] instance from a json map.
  ///
  /// [name] and [abbr] **must** be given.
  /// [finalSemesterGrade], [onlineGrades] and [customGrades] are optional.
  ///
  /// Doing
  /// ```dart
  /// Subject.fromJson(Subject().toJson());
  /// ```
  /// will result in the same object.
  Subject.fromJson(dynamic json) {
    name = json['name'];
    abbr = json['abbr'];
    finalSemesterGrade = json['finalSemesterGrade'];
    onlineGrades = [for (final elem in json['onlineGrades'] ?? []) Grade.fromJson(elem)];
    customGrades = [for (final elem in json['customGrades'] ?? []) Grade.fromJson(elem)];
  }

  /// Converts this object into a json map.
  ///
  /// Implements [name], [abbr], [finalSemesterGrade], [onlineGrades] and [customGrades].
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'abbr': abbr,
      'finalSemesterGrade': finalSemesterGrade,
      'onlineGrades': [for (final grade in onlineGrades) grade.toJson()],
      'customGrades': [for (final grade in customGrades) grade.toJson()],
    };
  }

  /// Creates a duplicate of `this`.
  Subject clone() => Subject.detailed(name, abbr, List.from(onlineGrades), List.from(customGrades), finalSemesterGrade);

  /// Creates a duplicate of `this` without all grades.
  Subject cloneStructure() => Subject.detailed(name, abbr, [], [], null);

  /// A list of all grades as [SpecialGrade] where [Grade.unSeen] is `true`.
  List<SpecialGrade> get unseenGrades {
    List<SpecialGrade> grades = [];
    for (final grade in allGrades) {
      if (grade.unSeen) grades.add(SpecialGrade(primary: grade, parentSubject: this));
    }
    return grades;
  }

  /// A list of all grades as [SpecialGrade] that where added by the user and might have one or more duplicate grades online.
  List<SpecialGrade> get similarGrades {
    List<SpecialGrade> similarGrades = [];

    for (final customGrade in customGrades) {
      if (onlineGrades.any(
        (element) =>
            customGrade.isExam == element.isExam &&
            element.similarTo(customGrade) &&
            customGrade.date.compareToAware(element.date) <= 0,
      )) {
        similarGrades.add(
          SpecialGrade(
            primary: customGrade,
            parentSubject: this,
            similarGrades: onlineGrades
                .where(
                  (element) =>
                      customGrade.isExam == element.isExam &&
                      element.similarTo(customGrade) &&
                      customGrade.date.compareToAware(element.date) <= 0,
                )
                .toList(),
          ),
        );
      }
    }

    return similarGrades;
  }

  /// A list of all grades as [SpecialGrade] that either have [Grade.unSeen] set to `true` or have a possible duplicate.
  ///
  /// Grades where [Grade.unSeen] is `true` and that are listed as possible duplicates from another grade are omitted.
  List<SpecialGrade> get newOrSimilarGrades {
    List<SpecialGrade> grades = similarGrades;

    for (final grade in unseenGrades) {
      if (!grades.any((element) => element.similarGrades?.contains(grade.primary) ?? false)) {
        grades.add(grade);
      }
    }

    return grades;
  }

  /// Sets [Grade.seen] to `true` for all elements of [onlineGrades] and [customGrades] after a delay of 3 seconds.
  ///
  /// If you wish to set all grades to seen instantaneously, see [setAllGradesSeenSync].
  Future<void> setAllGradesSeen() async {
    await Future.delayed(const Duration(seconds: 3));
    for (final grade in onlineGrades) {
      grade.seen = true;
    }
    for (final grade in customGrades) {
      grade.seen = true;
    }
    return;
  }

  /// Sets [Grade.seen] to `true` for all elements of [onlineGrades] and [customGrades].
  void setAllGradesSeenSync() {
    for (final grade in onlineGrades) {
      grade.seen = true;
    }
    for (final grade in customGrades) {
      grade.seen = true;
    }
    return;
  }

  /// Takes another [Subject] and adds additional data to `this`.
  ///
  /// For new grades, [Grade.seen] is set to `true`.
  ///
  /// Returns a list of [SpecialGrade] with online grades, that have changed.
  /// [customGrades] are overwritten.
  List<SpecialGrade> addGradesFromSubject(Subject other, {bool keepFinalGrades = false}) {
    if (!keepFinalGrades) finalSemesterGrade = other.finalSemesterGrade;

    List<SpecialGrade> changedGrades = [];

    List<Grade> newOnlineGrades = [];

    for (final grade in other.onlineGrades) {
      // check whether the grade value has changed or not
      if (onlineGrades.contains(grade) && !grade.similarTo(onlineGrades.firstWhere((element) => element == grade))) {
        newOnlineGrades.add(grade);
        changedGrades.add(SpecialGrade(primary: grade, parentSubject: this));
      }
      // add the grade if its not already present
      else if (!onlineGrades.contains(grade)) {
        newOnlineGrades.add(grade);
      }
    }

    onlineGrades = newOnlineGrades;

    customGrades = other.customGrades;

    return changedGrades;
  }

  /// Remove grade. **Note** that only grades from [customGrades] that where created by the user can be removed.
  void removeGrade(Grade grade) {
    customGrades.removeWhere((element) => element == grade);
  }

  /// Helper method used to calculate the average of a list of [Grade] elements.
  ///
  /// Also see implementation of [getExamsAvg] and [getTestsAvg].
  ///
  /// If [additionalValues] is provided, those are taken into account as well.
  ///
  /// Grades where [Grade.ghost] is set to `true` are ignored.
  double getAvg(List<Grade> grades, [List<int>? additionalValues]) {
    int sum = 0;
    int index = 0;

    for (final grade in grades) {
      if (grade.hasData && !grade.ghost) {
        sum += grade.gradeValue!;
        index++;
      }
    }
    additionalValues?.forEach((element) {
      sum += element;
      index++;
    });
    return sum / index;
  }

  /// Returns the average of the exams. Does not round.
  double getExamsAvg() => getAvg(exams);

  /// Returns the average of the tests. Does not round.
  double getTestsAvg([List<int>? additionalValues]) => getAvg(tests, additionalValues);

  /// Returns the average of the exams. Does round the final result to two decimal places.
  double getExamsAvgRounded() => roundDecimals(getExamsAvg());

  /// Returns the average of the tests. Does round the final result to two decimal places.
  double getTestsAvgRounded() => roundDecimals(getTestsAvg());

  /// Returns the total average of this subject.
  ///
  /// It's recommended that you call the method as following:
  /// ```dart
  /// getTotalAvg(dataWrapper.calculateExamWeight);
  /// ```
  /// where `dataWrapper` is the instance of [DataWrapper] used in your application. (See [DataWrapper.calculateExamWeight]).
  ///
  /// [additionalValues] property can be ignored for the regular user, but see [getAvg] for more information.
  double getTotalAvg(double Function(int) calculateExamWeight, [List<int>? additionalValues]) {
    double testsAvg = getTestsAvg(additionalValues);
    double examAvg = getExamsAvg();

    if (testsAvg.isNaN && examAvg.isNaN) return double.nan;
    if (testsAvg.isNaN && !examAvg.isNaN) return examAvg;
    if (!testsAvg.isNaN && examAvg.isNaN) return testsAvg;

    double examsWeight = calculateExamWeight(exams.where((grade) => grade.hasData).length);
    double testsWeight = 1 - examsWeight;

    return (examAvg * examsWeight) + (testsAvg * testsWeight);
  }

  /// Returns the total average of this subject. Does round the final result to two decimal places.
  ///
  /// **See also:** [getTotalAvg]
  double getTotalAvgRounded(double Function(int) getExamWeight) {
    return roundDecimals(getTotalAvg(getExamWeight));
  }

  /// Returns a list of tuples with a grade and a "Doability" percentage that the user would need to add to get in order to increase his subject average.
  ///
  /// The length of the list is equal to [gradesCount]. [gradesCount] defaults to `1`. Has to be greater than or equal to 1.
  ///
  /// If [keepAvg] is set to `true`, the worst grade the user can get without effecting his subject average is calculated. In this case, [gradesCount] is always `1`.
  ///
  /// It is recommended to call the method as follows:
  /// ```dart
  /// gradesToImprove(HipWrapper.calculateExamWeight);
  /// ```
  List<(List<int>, double)> gradesToImprove(
    double Function(int) calculateExamWeight, {
    bool keepAvg = false,
    int? gradesCount,
  }) {
    double? totalAvg = getTotalAvg(calculateExamWeight);
    if ((AppConfig.isSek2 && totalAvg.round() >= 15 && !keepAvg) ||
        (AppConfig.isSek1 && totalAvg.round() <= 1 && !keepAvg)) {
      return [];
    }

    List<(List<int>, double)> r = [];

    double targetAvg;
    if (keepAvg) {
      if (AppConfig.isSek2) {
        targetAvg = totalAvg.round() - .5;
      } else {
        targetAvg = totalAvg.round() + .49;
      }
    } else {
      targetAvg = getTargetAvg(calculateExamWeight)!;
    }

    (int, int) _tests, _exams;

    int sum = 0, count = 0;
    for (final elem in tests) {
      if (elem.ghost || !elem.hasData) continue;
      sum += elem.gradeValue!;
      count++;
    }
    _tests = (sum, count);

    sum = 0;
    count = 0;
    for (final elem in exams) {
      if (elem.ghost || !elem.hasData) continue;
      sum += elem.gradeValue!;
      count++;
    }
    _exams = (sum, count);

    double examsWeight;
    double testsWeight;

    if (exams.every((exam) => !exam.hasData)) {
      examsWeight = 0;
    } else {
      examsWeight = calculateExamWeight(exams.where((grade) => grade.hasData).length);
    }

    testsWeight = 1 - examsWeight;

    /// amount sets the amount of additional grades (only tests, no exams) with which the [targetAvg] shall be reached
    double getRemainingPoints(int amount) {
      double examsAvg = _exams.$1 / _exams.$2;
      double examsAvgWeighted = examsAvg.isNaN ? 0 : examsAvg * examsWeight;
      return (targetAvg - examsAvgWeighted) * (_tests.$2 + amount) / testsWeight - _tests.$1;
    }

    /// evenly distributes the total amount of points over a set count of grades
    List<int> distributePoints(double total, int count) {
      List<int> values = [];

      for (int i = 0; i < count; i++) {
        if (AppConfig.isSek2 && total <= 0) {
          values.add(0);
          continue;
        } else if (AppConfig.isSek1 && total >= 6 * count) {
          values.add(6);
          continue;
        }

        double reducedTotal = total;
        for (final val in values) {
          reducedTotal -= val;
        }
        if (AppConfig.isSek2) {
          values.add((reducedTotal / (count - i)).ceil());
        } else {
          values.add((reducedTotal / (count - i)).floor());
        }
      }
      return values;
    }

    double getDoability(List<int> values) {
      double sum = 0;
      for (final val in values) {
        double delta = (totalAvg - val).abs();
        double max = keepAvg ? (AppConfig.isSek2 ? 0 : 6) : (AppConfig.isSek2 ? 15 : 1);
        double deltaMax = (max - totalAvg).abs();
        sum += (deltaMax - delta) / deltaMax;
      }
      return sum / values.length;
    }

    for (int i = 1; i <= (gradesCount ?? 1); i++) {
      double remainingPoints = getRemainingPoints(i);
      if ((AppConfig.isSek2 && remainingPoints > i * 15) || (AppConfig.isSek2 && remainingPoints < i)) continue;
      var distributedPoints = distributePoints(remainingPoints, i);
      r.add((
        distributedPoints..sort((a, b) => b.compareTo(a)),
        roundDecimals(getDoability(distributedPoints), decimals: 3) * 100,
      ));
      if (getDoability(distributedPoints) >= .8) break;
    }

    //r.sort((a, b) => b.$2.compareTo(a.$2));
    return r;
  }

  /// Internal helper method used by [gradesToImprove] method.
  double? getTargetAvg(double Function(int) calculateExamWeight) {
    double? totalAvg = getTotalAvg(calculateExamWeight);
    if (AppConfig.isSek2 && totalAvg.round() < 5) {
      return 4.5;
    } else if (AppConfig.isSek1 && totalAvg.round() > 4) {
      return 4.49;
    } else if (AppConfig.isSek2) {
      return totalAvg.round() + .5;
    } else {
      return totalAvg.round() - .51;
    }
  }
}
