part of 'hip_wrapper.dart';

class Grade {
  /// If this grade was **imported** from Home.InfoPoint, set the [key] to the index of the row of the table from Home.InfoPoint,
  /// that corresponds to this grade.
  ///
  /// If this grade was **manually** added by the user, it is recommended to set this key to `DateTime.now().millisecondsSinceEpoch.toString()`.
  late String key;

  /// Date on which the grade was uploaded to Home.InfoPoint.
  DateTime? uploadDate;

  /// Date on which e.g. the test was written.
  ///
  /// Can only be set by the user.
  DateTime? dateOfWriting;

  /// Implementation:
  /// ```dart
  /// DateTime? get date => dateOfWriting ?? uploadDate;
  /// ```
  DateTime? get date => dateOfWriting ?? uploadDate;

  /// Whether or not this grade is an exam.
  late bool isExam;

  /// Whether or not the user has seen this grade.
  bool seen = false;
  bool get unSeen => !seen;

  int? _value;

  /// Value of the grade from 1 to 6.
  int? get value => _value;

  /// Use this setter to safely update the grade value if the input value is between 1 and 6 and might have an appendage like '+' or '-'.
  set decimalValue(String value) {
    if (value == "") {
      _value = null;
      points = null;
      return;
    }

    if (!allowedGradeValuesSek1.contains(value.trim())) {
      throw UnsupportedError("FormatError: $value cannot be converted to a grade value.");
    }

    if (value.length == 2) {
      appendage = value.substring(1);
    }
    _value = int.parse(value.substring(0, 1));

    if (_value == 6) {
      points = 0;
    } else {
      points = 17 - (3 * _value!);

      if (appendage == "+") {
        points = points! + 1;
      } else if (appendage == "-") {
        points = points! - 1;
      }
    }
  }

  /// Either "+" or "-". If set to null, the grade value has no appendage.
  String? appendage;

  /// Value of the grade from 15 to 00.
  int? points;

  /// Use this setter to safely set the grade value if the input value is between 0 and 15. Can handle either a String or an integer representative.
  set pointsValue(dynamic value) {
    if (value is String && value.trim() == "") {
      _value = null;
      points = null;
      return;
    }

    if (value is int? || value is int) {
      if (!allowedGradeValuesSek2.contains(value.toString())) {
        points = null;
        return;
      }
      points = value;
    } else if (value is String) {
      if (!allowedGradeValuesSek2.contains(value)) {
        points = null;
        return;
      }
      points = int.parse(value);
    } else {
      throw UnsupportedError("Cannot convert object of type ${value.runtimeType} to a grade value.");
    }

    if (points == 0) {
      _value = 6;
    } else {
      switch (points! % 3) {
        case 0:
          appendage = "+";
          break;
        case 1:
          appendage = "-";
          break;
      }
      _value = ((17 - points!) / 3).round();
    }
  }

  /// If [AppConfig.isSek1] is set to `true`, checks if [value] is equal to `null`.
  ///
  /// If [AppConfig.isSek2] is set to `true`, checks if [points] is qual to `null`.
  bool get isEmpty => AppConfig.isSek2 ? points == null : value == null;

  /// Opposite of [isEmpty].
  bool get hasData => !isEmpty;

  /// List of [WeeklyExercise] elements for storing the results of weekly exercises.
  List<WeeklyExercise>? weeklyExercises;

  /// If this grade has weekly exercises stored.
  bool get hasWeeklyExercises => weeklyExercises?.isNotEmpty ?? false;

  /// A description provided by the teacher on Home.InfoPoint.
  ///
  /// See [userDescription] to set a custom description.
  String? description;

  /// A custom description set by the user.
  String? userDescription;

  /// If the grade shall be excluded from calculations.
  bool ghost = false;

  Grade(this.key) : description = null;

  /// Takes a string representation of the grade in decimal grade system. Can handle appendages (either "+" or "-").
  Grade.fromStringValue({
    required String value,
    String? description,
    this.uploadDate,
    this.dateOfWriting,
    required this.key,
    required this.isExam,
  }) {
    value = value.trim().replaceAll(RegExp(r'^0+(?=.)'), '');
    if (allowedGradeValuesSek1.contains(value)) {
      decimalValue = value;
    } else {
      this.description = '"$value"';
    }

    if (this.description == null) {
      this.description = description == "" ? null : description;
    } else if (description != null) {
      this.description = this.description.add(": $description");
    }
  }

  /// Takes a string representation of the grade from 0 to 15.
  Grade.fromPoints({
    required String? pointValue,
    String? description,
    this.uploadDate,
    this.dateOfWriting,
    required this.key,
    required this.isExam,
  }) {
    pointValue = pointValue?.trim().replaceAll(RegExp(r'^0+(?=.)'), '');
    if (allowedGradeValuesSek2.contains(pointValue) || pointValue == null) {
      pointsValue = pointValue;
    } else {
      this.description = '"$pointValue"';
    }

    if (this.description == null) {
      this.description = description == "" ? null : description;
    } else if (description != null) {
      this.description = this.description.add(": $description");
    }
  }

  Grade.empty({this.description, this.uploadDate, this.dateOfWriting, this.key = 'key', this.isExam = false});

  Grade.detailed(
    this._value,
    this.appendage,
    this.points,
    this.description,
    this.userDescription,
    this.dateOfWriting,
    this.uploadDate,
    this.seen,
    this.ghost,
    this.key,
    this.isExam,
  );

  Grade.fromJson(dynamic json) {
    key = json['key'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    pointsValue = json['points'];
    description = json['description'];
    userDescription = json['userDescription'];
    if (json['uploadDate'] != null) uploadDate = DateTime.fromMillisecondsSinceEpoch(json['date']);
    ghost = json['ghost'];
    seen = json['seen'];
    isExam = json['isExam'];
  }

  Grade clone() => Grade.detailed(
    value,
    appendage,
    points,
    description,
    userDescription,
    dateOfWriting,
    uploadDate,
    seen,
    ghost,
    key,
    isExam,
  );

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'points': points,
      'description': description,
      'userDescription': userDescription,
      'uploadDate': uploadDate?.millisecondsSinceEpoch,
      'ghost': ghost,
      'seen': seen,
      'isExam': isExam,
    };
  }

  /// Returns a string representation of the grade value depending on [AppConfig.isSek2].
  String get stringValue {
    if (points == null) return "?";
    return AppConfig.isSek2 ? points.toString() : "$value${appendage ?? ""}";
  }

  /// Returns the value of the grade in the correct grade format.
  ///
  /// Does not contain appendages for sek 1.
  int? get gradeValue => AppConfig.isSek2 ? points : value;

  /// Returns the grade as a percentage of all [weeklyExercises] elements.
  ///
  /// Returns [double.nan] if [weeklyExercises] is empty (or `null`).
  ///
  /// **See also:**
  /// * [DataWrapper.mapPercentageToGrade] to convert the percentage into a grade.
  double get weeklyExercisesPercentage {
    if (!hasWeeklyExercises) return double.nan;
    double count = 0;
    double sum = 0;
    for (final exercise in weeklyExercises!) {
      count += exercise.achieved;
      sum += exercise.max;
    }
    return count / sum;
  }

  /// Compares this grade to [other] by their [points] value and [isExam] property.
  ///
  /// Also returns `true` if `this.points` or `other.points` is qual to `null`.
  ///
  /// [isExam] always has to be qual; `false` is returned if not.
  bool similarTo(Grade other) =>
      isExam == other.isExam && (points == other.points || points == null || other.points == null);

  @override
  bool operator ==(covariant Grade other) {
    return key == other.key && isExam == other.isExam;
  }

  // Use this operator to override all variables (except the key) from this grade.
  void operator <<(Grade other) {
    dateOfWriting = other.dateOfWriting;
    uploadDate = other.uploadDate ?? uploadDate;
    pointsValue = other.points ?? points;
    description = other.description ?? description;
    userDescription = other.userDescription;
    ghost = other.ghost;
  }
}
