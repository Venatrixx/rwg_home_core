import 'dart:convert';
import 'dart:io';

import 'package:home_info_point_client/home_info_point_client.dart';
import 'package:intl/intl.dart';
import 'package:rwg_home_core/rwg_home_core.dart';
import 'package:rwg_home_core/src/hip/weekly_exercise.dart';

part 'missing_hours.dart';
part 'semester.dart';
part 'subject.dart';
part 'grade.dart';
part 'special_grade.dart';

/// Contains all important data found on Home.InfoPoint.
class HipWrapper {
  void Function(LoadingState, [Object?])? onLoadingStateChanged;

  LoadingState _loadingState = LoadingState.unknown;

  LoadingState get loadingState => _loadingState;
  set loadingState(LoadingState value) {
    _loadingState = value;
    onLoadingStateChanged?.call(value, error);
  }

  Object? error;

  int? totalMissingDays;
  int? totalUnexcusedMissingDays;

  int? totalMissingHours;
  int? totalUnexcusedMissingHours;

  List<MissingHour>? missingHourData;

  List<Event> get missingHourEvents {
    if (missingHourData == null) return [];
    List<Event> response = [];
    for (final element in missingHourData!) {
      if (element.date == null) continue;
      response.add(
        Event.missingDay(element.date!, time: element.lessons, comment: element.comment, triState: element.excused),
      );
    }
    return response;
  }

  bool get hasUnexcused => (totalUnexcusedMissingDays ?? 0) > 0 || (totalUnexcusedMissingHours ?? 0) > 0;

  List<Semester> semesters = [];

  bool get hasUnseenGrades => semesters.any((element) => element.subjects.any((subject) => subject.hasUnseenGrades));

  /// Returns the index of the last element of [semesters] where [Semester.hasData] is `true`.
  int get currentSemesterIndex {
    int index = semesters
        .where((element) => element.level == AppConfig.level)
        .toList()
        .lastIndexWhere((semester) => semester.hasData);
    if (index < 0) return 0;
    return index;
  }

  /// List of [SpecialGrade] elements of those grades, that have changed since the last import.
  List<SpecialGrade>? changedGrades;

  List<SpecialGrade> get newOrSimilarGrades {
    List<SpecialGrade> grades = [];
    for (final semester in semesters) {
      for (final subject in semester.subjects) {
        grades.addAll(subject.newOrSimilarGrades..forEach((element) => element.parentSemester = semester));
      }
    }
    return grades;
  }

  List<SpecialGrade> get gradesWithAttention => [...?changedGrades, ...newOrSimilarGrades];

  HipWrapper({
    this.semesters = const [],
    this.totalMissingDays,
    this.totalUnexcusedMissingDays,
    this.totalMissingHours,
    this.totalUnexcusedMissingHours,
    this.missingHourData,
  });

  /// Internal constructor used by the [HipWrapper.fetchData] method.
  ///
  /// Converts the json data from Home.InfoPoint into a [HipWrapper] instance.
  factory HipWrapper.fromHipJson(dynamic json) {
    // extract subjects
    List<Subject> subjectsSem1 = [];
    List<Subject> subjectsSem2 = [];

    for (final jsonSubject in json['subjects']! as List) {
      List<Grade> gradesSem1 = [];
      List<Grade> gradesSem2 = [];

      for (final jsonGrade in (jsonSubject['grades']! as List).indexed) {
        Grade grade;
        if (AppConfig.isSek1) {
          grade = Grade.fromStringValue(
            value: jsonGrade.$2['value'],
            key: jsonGrade.$1.toString(),
            isExam: jsonGrade.$2['isExam'],
            description: jsonGrade.$2['comment'],
            uploadDate: DateFormat('dd.MM.yyyy').parse(jsonGrade.$2['date']),
          );
        } else {
          grade = Grade.fromPoints(
            pointValue: jsonGrade.$2['value'],
            key: jsonGrade.$1.toString(),
            isExam: jsonGrade.$2['isExam'],
            description: jsonGrade.$2['comment'],
            uploadDate: DateFormat('dd.MM.yyyy').parse(jsonGrade.$2['date']),
          );
        }

        if (jsonGrade.$2['semester'] == 1) {
          gradesSem1.add(grade);
          continue;
        } else if (jsonGrade.$2['semester'] == 2) {
          gradesSem2.add(grade);
          continue;
        } else {
          throw FormatException('Cannot read semester "${jsonGrade.$2['semester']}".');
        }
      }

      subjectsSem1.add(
        Subject(
          name: jsonSubject['name'],
          abbr: jsonSubject['abbr'],
          onlineGrades: List.from(gradesSem1),
          finalSemesterGrade: int.tryParse(jsonSubject['finalGradeSem1']),
        ),
      );

      subjectsSem2.add(
        Subject(
          name: jsonSubject['name'],
          abbr: jsonSubject['abbr'],
          onlineGrades: List.from(gradesSem2),
          finalSemesterGrade: int.tryParse(jsonSubject['finalGradeSem2']),
        ),
      );
    }

    Semester sem1 = Semester(label: "${json['level']!}.1", level: json['level'], subjects: List.from(subjectsSem1));
    Semester sem2 = Semester(label: "${json['level']!}.2", level: json['level'], subjects: List.from(subjectsSem2));

    return HipWrapper(
      semesters: [sem1, sem2],
      totalMissingDays: json['totalMissingDays'],
      totalUnexcusedMissingDays: json['totalUnexcusedMissingDays'],
      totalMissingHours: json['totalMissingHours'],
      totalUnexcusedMissingHours: json['totalUnexcusedMissingHours'],
      missingHourData: [
        for (final day in json['missingDays'] ?? []) MissingHour.dayFromJson(day),
        for (final hour in json['missingHours'] ?? []) MissingHour.hourFromJson(hour),
      ],
    );
  }

  /// Reads the json file at the given path and constructs a [HipWrapper] instance.
  factory HipWrapper.fromJsonFile(String path) {
    final json = jsonDecode(File(path).readAsStringSync());

    return HipWrapper.fromJson(json);
  }

  HipWrapper.fromJson(dynamic json)
    : totalMissingDays = json['totalMissingDays'],
      totalUnexcusedMissingDays = json['totalUnexcusedMissingDays'],
      totalMissingHours = json['totalUnexcusedMissingHours'],
      totalUnexcusedMissingHours = json['totalUnexcusedMissingHours'],
      semesters = [for (final semester in json['semesters']) Semester.fromJson(semester)];

  Map<String, dynamic> toJson() {
    return {
      'totalMissingDays': totalMissingDays,
      'totalUnexcusedMissingDays': totalUnexcusedMissingDays,
      'totalMissingHours': totalMissingHours,
      'totalUnexcusedMissingHours': totalUnexcusedMissingHours,
      'semesters': [for (final semester in semesters) semester.toJson()],
    };
  }

  /// Writes the content of this [HipWrapper] object to the file at the given path.
  void saveToFile(String path) {
    final file = File(path);

    file.writeAsStringSync(jsonEncode(toJson()));

    return;
  }

  /// Returns a list of all subject abbreviations.
  List<String> get getSubjectAbbr {
    if (semesters.isEmpty) return [];
    List<String> r = [];
    for (final sem in semesters) {
      for (final sub in sem.subjects) {
        r.add(sub.abbr.toLowerCase());
      }
    }
    r = [
      ...{...r},
    ];
    if (r.isEmpty) return [];
    return r;
  }

  /// Initializes the semesters based on the current [AppConfig.level].
  Future<void> initializeSemesters() async {
    error = null;

    _loadingState = LoadingState.loading;

    final client = HipClient(await AppConfig.userHipConfig);

    try {
      await client.fetch();
    } catch (e) {
      error = e;
      _loadingState = LoadingState.error;
      rethrow;
    }

    final rawData = await client.asJson();

    AppConfig.setLevel(rawData['level']);
    AppConfig.setUserClass(rawData['class']);

    final newData = HipWrapper.fromHipJson(rawData);

    final subjects = [...?newData.semesters.firstOrNull?.cloneStructure().subjects];

    if (AppConfig.isSek1) {
      semesters = [
        Semester(label: "${AppConfig.level}.1", level: AppConfig.level, subjects: subjects),
        Semester(label: "${AppConfig.level}.2", level: AppConfig.level, subjects: subjects),
      ];
    } else {
      semesters = [
        Semester(label: "11.1", level: 11, subjects: subjects),
        Semester(label: "11.2", level: 11, subjects: subjects),
        Semester(label: "12.1", level: 12, subjects: subjects),
        Semester(label: "12.2", level: 12, subjects: subjects),
      ];
    }

    _loadingState = LoadingState.done;
  }

  /// Call this function to fetch new data from Home.InfoPoint.
  ///
  /// It is **important** to call this function via [DataWrapper.fetchHipData],
  /// as this will ensure that the data is stored properly.
  ///
  /// Calls [onLoadingStateChanged] if provided.
  Future<void> fetchData({bool hardImport = false, bool rethrowErrors = false}) async {
    loadingState = LoadingState.loading;

    try {
      final client = HipClient(await AppConfig.userHipConfig);

      await client.fetch();

      final rawData = await client.asJson();

      AppConfig.setLevel(rawData['level']);
      AppConfig.setUserClass(rawData['class']);

      final newData = HipWrapper.fromHipJson(rawData);

      if (hardImport) {
        semesters.removeWhere((element) => element.level = rawData['level']);
        semesters.addAll(newData.semesters);
        semesters.sort((a, b) => a.label.compareTo(b.label));
      } else {
        if (semesters.isEmpty) await initializeSemesters();
        addDataFromWrapper(newData);
      }
    } catch (e) {
      error = e;
      loadingState = LoadingState.error;
      if (rethrowErrors) rethrow;
      return;
    }

    loadingState = LoadingState.done;
  }

  /// Takes another [wrapper] and adds additional data to `this`.
  ///
  /// For new grades, [Grade.seen] is set to `false`.
  ///
  /// Changed grades are stored inside [changedGrades] property of `this`.
  ///
  /// **See also:**
  /// * [fetchData] for importing the newest data.
  void addDataFromWrapper(HipWrapper wrapper) {
    totalMissingDays = wrapper.totalMissingDays;
    totalUnexcusedMissingDays = wrapper.totalUnexcusedMissingDays;
    totalMissingHours = wrapper.totalMissingHours;
    totalUnexcusedMissingHours = wrapper.totalUnexcusedMissingHours;

    missingHourData = wrapper.missingHourData;

    List<SpecialGrade> changedGrades = [];

    for (final newSemester in wrapper.semesters) {
      try {
        Semester refSemester = semesters.firstWhere((element) => element.label == newSemester.label);
        final changed = refSemester.addDataFromSemester(newSemester);
        changedGrades.addAll(changed);
      } on StateError {
        // do nothing
      }
    }

    this.changedGrades = changedGrades;

    onLoadingStateChanged?.call(LoadingState.done);
  }

  /// Creates empty subject structures for all semesters with no structure.
  ///
  /// Throws [StateError] if there is no semester with an existing structure.
  void updateSubjectsStructure() {
    Semester refSemester = semesters[currentSemesterIndex].cloneStructure();

    for (var semester in semesters) {
      semester.addDataFromSemester(refSemester, keepFinalGrades: true);
    }

    onLoadingStateChanged?.call(LoadingState.done);
  }

  /// Add a [Grade] to the given [Subject].
  ///
  /// Calls [onLoadingStateChanged] if given.
  void addGrade(Grade grade, Subject subject) {
    subject.customGrades.add(grade);
    onLoadingStateChanged?.call(LoadingState.done);
  }

  /// Delete [Grade] from the given [Subject].
  ///
  /// Only deletes from [Subject.customGrades].
  void deleteGrade(Grade grade, Subject subject) {
    subject.removeGrade(grade);
    onLoadingStateChanged?.call(LoadingState.done);
  }

  /// Sets all grades seen for all [semesters] after a delays of 3 seconds.
  Future<void> setAllGradesSeen() async {
    await Future.delayed(const Duration(seconds: 3));
    for (final semester in semesters) {
      semester.setAllGradesSeenSync();
    }
    onLoadingStateChanged?.call(LoadingState.done);
  }

  /// Sets all grades seen for all [semesters] instantly.
  void setAllGradesSeenSync() {
    for (final semester in semesters) {
      semester.setAllGradesSeenSync();
    }
    onLoadingStateChanged?.call(LoadingState.done);
  }
}
