import 'dart:convert';
import 'dart:io';

import 'package:rwg_home_core/rwg_home_core.dart';
import 'package:rwg_home_core/src/functions/subjects_fetch.dart';

part 'abstract_subject.dart';
part 'abstract_final_grade.dart';

class ALevelWrapper {
  ALevelWrapper({
    this.advancedSubjects = const [],
    this.writtenExamSubject,
    this.oralExamSubjects = const [],
    this.hiddenSubjects = const [],
    this.subjects = const [],
    this.unknownSubjects = const [],
  });

  factory ALevelWrapper.fromJsonFile(String path) {
    final json = jsonDecode(File(path).readAsStringSync());
    return ALevelWrapper.fromJson(json);
  }

  ALevelWrapper.fromJson(dynamic json)
    : advancedSubjects = List<String>.from(json['advancedSubjects'] ?? []),
      writtenExamSubject = json['writtenExamSubject'],
      oralExamSubjects = List<String>.from(json['oralExamSubjects'] ?? []),
      hiddenSubjects = List<String>.from(json['hiddenSubjects'] ?? []),
      subjects = [for (final elem in json['subjects']) AbstractSubject.fromJson(elem)],
      unknownSubjects = [for (final elem in json['unknownSubjects']) AbstractSubject.fromJson(elem)];

  Map toJson() => {
    'advancedSubjects': advancedSubjects,
    'writtenExamSubject': writtenExamSubject,
    'oralExamSubjects': oralExamSubjects,
    'hiddenSubjects': hiddenSubjects,
    'subjects': [for (final subject in subjects) subject.toJson()],
    'unknownSubjects': [for (final subject in unknownSubjects) subject.toJson()],
  };

  void saveToFile(String path) {
    File(path).writeAsStringSync(jsonEncode(toJson()));
  }

  void Function()? onDataChanged;

  /// List of abbreviations, eg. `en` or `ma`, for the two advanced subjects.
  late List<String> advancedSubjects;

  /// List of the actual names of the [advancedSubjects].
  List<String> get advancedSubjectsNames {
    if (advancedSubjects.isEmpty) return [];
    var advancedAbstractSubjects = subjects.where((s) => advancedSubjects.contains(s.abbr)).toList();
    return List.generate(advancedAbstractSubjects.length, (index) => advancedAbstractSubjects[index].name);
  }

  /// Abbreviation for the third written exam subject.
  String? writtenExamSubject;

  /// List of abbreviations, eg. `en` or `ma`, for the two oral exam subjects.
  late List<String> oralExamSubjects;

  /// List of abbreviations, eg. `en` or `ma`, that should be excluded from any calculations and not shown in the ui.
  late List<String> hiddenSubjects;

  /// List of the actual [AbstractSubject] elements.
  ///
  /// These subjects have passed verification.
  late List<AbstractSubject> subjects;

  /// List of the abbreviations from all [subjects].
  List<String> get subjectsStrings {
    return List.generate(subjects.length, (index) => subjects[index].abbr);
  }

  /// List of [AbstractSubject] elements that did not pass verification.
  late List<AbstractSubject> unknownSubjects;

  /// List of the actual names of the [unknownSubjects].
  List<String> get unknownSubjectsStrings {
    if (unknownSubjects.isEmpty) return [];
    return List.generate(
      unknownSubjects.length,
      (index) => "${unknownSubjects[index].name} (${unknownSubjects[index].abbr})",
    );
  }

  /// If [latestCatalog.chooseOptimalSemesters] should be called, when [updateSubjects] is called.
  bool chooseOptimal = false;

  /// Getter for counting the amount of overall active grades.
  int get activeGradesCount {
    int count = 0;
    for (final elem in subjects) {
      count += elem.activeGradesCount * ((advancedSubjects.contains(elem.abbr) ? 2 : 1));
    }
    return count;
  }

  /// A getter for all abbreviations of exam subjects.
  ///
  /// Combines [advancedSubjects], [writtenExamSubject] and [oralExamSubjects] in one list.
  List<String> get allExamSubjects =>
      [...advancedSubjects, ?writtenExamSubject, ...oralExamSubjects]..forEach((element) => element.toLowerCase());

  /// A getter for all subjects (as abbreviations) that are either exam subjects or hidden subjects.
  ///
  /// Comines [allExamSubjects] and [hiddenSubjects].
  List<String> get excludedSubjects =>
      [...allExamSubjects, ...hiddenSubjects]..forEach((element) => element.toLowerCase());

  /// All [AbstractSubject] elements from [subjects] where [AbstractSubject.kind] is set to `la` (language and art).
  List<AbstractSubject> get laSubjects => subjects.where((s) => s.kind == "la").toList();

  /// All [AbstractSubject] elements from [subjects] where [AbstractSubject.kind] is set to `sc` (social studies).
  List<AbstractSubject> get scSubjects => subjects.where((s) => s.kind == "sc").toList();

  /// All [AbstractSubject] elements from [subjects] where [AbstractSubject.kind] is set to `mint` (science and math).
  List<AbstractSubject> get mintSubjects => subjects.where((s) => s.kind == "mint").toList();

  /// List of the abbreviations of the [mintSubjects].
  List<String> get mintSubjectsAbbr => List<String>.generate(mintSubjects.length, (index) => mintSubjects[index].abbr);

  bool get isValid => errors.isEmpty;
  bool get isNotValid => !isValid;

  /// Number of points for the first block.
  int? get finalResult1 {
    int sum = 0, count = 0;
    for (final subject in subjects) {
      for (final grade in subject.finalGrades) {
        if (grade.active && grade.value != null) {
          if (advancedSubjects.contains(subject.abbr)) {
            sum += grade.value! * 2;
            count += 2;
          } else {
            sum += grade.value!;
            count++;
          }
        }
      }
    }
    if (count == 0) return null;
    return ((sum * 40) / count).round();
  }

  /// Number of points for the second block.
  int? get finalResult2 {
    if (allExamSubjects.length != 5) return null;
    List<AbstractSubject> examSubjects = subjects.where((s) => allExamSubjects.contains(s.abbr)).toList();
    int sum = 0;
    for (final subject in examSubjects) {
      if (!subject.hasData) continue;
      sum += (subject.examGrade ?? subject.avg!.round()) * 4;
    }
    if (sum == 0) return null;
    return sum;
  }

  /// The sum of [finalResult1] and [finalResult2].
  int? get finalResult {
    if (finalResult1 == null || finalResult2 == null) return null;
    return finalResult1! + finalResult2!;
  }

  /// The [finalResult] as a decimal grade.
  double? get finalResultNC {
    if (finalResult == null) return null;
    double grade = (17 / 3) - (finalResult! / 180);
    String gradeString = grade.toString();
    if (gradeString.length <= 3) return grade;
    return double.parse(gradeString.substring(0, 3));
  }

  List<String> get errors {
    List<String> r = [];
    for (final test in latestCatalog.standardTests) {
      try {
        r.addAll(test.test(this) ?? []);
      } catch (_) {
        r.add("Fehler während der Prüfung von: ${test.description}");
      }
    }
    return r;
  }

  TaskStatus get verificationStatus {
    if (subjects.isEmpty && unknownSubjects.isNotEmpty) {
      return TaskStatus.error;
    } else if (subjects.isNotEmpty && unknownSubjects.isNotEmpty) {
      return TaskStatus.completeWithError;
    } else if (subjects.isNotEmpty && unknownSubjects.isEmpty) {
      return TaskStatus.complete;
    }
    return TaskStatus.unknown;
  }

  TaskStatus get advancedSubjectsStatus {
    if (advancedSubjects.isNotEmpty &&
        !advancedSubjects.any((s) => ['ma', 'de', 'en', 'span', 'franz', 'la', 'bio', 'ch', 'ph'].contains(s))) {
      return TaskStatus.error;
    } else if (advancedSubjects.isNotEmpty && advancedSubjects.length < 2) {
      return TaskStatus.completeWithError;
    } else if (advancedSubjects.length == 2) {
      return TaskStatus.complete;
    }
    return TaskStatus.unknown;
  }

  TaskStatus get otherExamSubjectsStatus {
    if (latestCatalog.examSubjectsTests.every((cond) => cond.test(this) == TaskStatus.error)) return TaskStatus.error;
    if (latestCatalog.examSubjectsTests.any((cond) => cond.test(this) == TaskStatus.error)) {
      return TaskStatus.completeWithError;
    }
    if (latestCatalog.examSubjectsTests.every((cond) => cond.test(this) == TaskStatus.complete)) {
      return TaskStatus.complete;
    }

    return TaskStatus.unknown;
  }

  TaskStatus get configStatus {
    if (verificationStatus != TaskStatus.complete ||
        advancedSubjectsStatus != TaskStatus.complete ||
        otherExamSubjectsStatus != TaskStatus.complete) {
      return TaskStatus.completeWithError;
    }
    return TaskStatus.complete;
  }

  /// Call this method once to initialize the subjects.
  Future<void> initializeSubjects(List<Semester> semesters) async {
    final refSemester = semesters.firstWhere((element) => element.hasData || element.hasFinalGrades);

    unknownSubjects = [
      for (final sub in refSemester.subjects)
        AbstractSubject.fromSemesters(sub.name, sub.abbr.toLowerCase(), semesters),
    ];
    subjects = [];

    await verifySubjects();
    return;
  }

  /// Returns a list of [AbstractSubject] objects that could not been verified.
  Future<void> verifySubjects() async {
    List<AbstractSubject> unknownSubjects = [...this.subjects, ...this.unknownSubjects];
    List<AbstractSubject> subjects = [];
    unknownSubjects.removeWhere((s) => hiddenSubjects.contains(s.abbr.toLowerCase()));

    final rawStructure = await fetchAbstractSubjects();

    for (final sub in unknownSubjects) {
      if (await sub.normalize(rawStructure)) {
        subjects.add(sub);
      }
    }

    for (final sub in subjects) {
      unknownSubjects.removeWhere((element) => element == sub);
    }

    this.unknownSubjects = List.from(unknownSubjects);
    this.subjects = List.from(subjects);
    return;
  }

  /// Tries to verify all subjects, if [unknownSubjects] is not empty.
  ///
  /// Returns the amount of newly verified subjects.
  Future<int?> tryVerify() async {
    if (unknownSubjects.isEmpty) return null;
    int oldCount = unknownSubjects.length;
    await verifySubjects();
    if (unknownSubjects.length < oldCount) {
      int dif = oldCount - unknownSubjects.length;
      return dif;
    }
    return null;
  }

  /// Updates all [subjects] based on the [semesters] provided.
  void updateSubjects(List<Semester> semesters, double Function(int) calculateExamWeight, {bool? sort}) {
    for (final sub in subjects) {
      sub.update(semesters, calculateExamWeight);
    }
    if (oralExamSubjects.length > 2) {
      oralExamSubjects.removeRange(2, oralExamSubjects.length);
    }
    if (chooseOptimal == true) latestCatalog.chooseOptimal?.call(this);
    if (sort == true) this.sort();
  }

  /// Sorts the [subjects] by their [AbstractSubject.activeGradesCount] property.
  void sort() {
    subjects.sort((a, b) => a.activeGradesCount.compareTo(b.activeGradesCount));
    subjects = subjects.reversed.toList();
    for (final abbr in allExamSubjects.reversed.toList()) {
      try {
        var subject = subjects.removeAt(subjects.indexOf(subjects.firstWhere((e) => e.abbr == abbr)));
        subjects.insert(0, subject);
      } catch (_) {}
    }
  }
}
