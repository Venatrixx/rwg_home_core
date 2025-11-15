import 'package:rwg_home_core/rwg_home_core.dart';

part 'validation_test.dart';

part 'catalog_2019.dart';
part 'catalog_2026.dart';

/// Used to store a set of [ValidationTest] items for checking, if an [ALevelWrapper] has valid data.
class ValidationCatalog {
  /// Used to identify this catalog. Usually the name of the law this is based on.
  String catalogName;

  /// A link to the law text.
  String catalogLink;

  /// When this instance was last updated.
  DateTime date;

  /// Description to help the user decide, if this is the correct catalog for them.
  String whenToChoose;

  /// Additional information.
  String? comment;

  /// Factor for exams used to calculate the average of a semester.
  double examWeight;

  /// List of [ValidationTest] elements that need to be met by all subjects of the [ALevelWrapper].
  List<ValidationTest> standardTests;

  /// List of [ValidationTest] elements that are exclusive conditions for the exam subjects.
  List<ValidationTest<TaskStatus>> examSubjectsTests;

  /// List of abbreviations of subjects that are allowed to be the third written exam.
  List<String> allowedWrittenExamSubjects;

  /// A function that chooses the optimal configuration for the given [ALevelWrapper].
  void Function(ALevelWrapper)? chooseOptimal;

  ValidationCatalog({
    required this.catalogName,
    required this.catalogLink,
    required this.date,
    required this.whenToChoose,
    required this.examWeight,
    required this.standardTests,
    required this.examSubjectsTests,
    required this.allowedWrittenExamSubjects,
    this.comment,
    this.chooseOptimal,
  });
}

/// All available [ValidationCatalog] objects.
List<ValidationCatalog> availableValidationCatalogs = [
  catalog2019,
  catalog2016,
];

/// The latests catalog that is also used by the core engine.
ValidationCatalog get latestCatalog =>
    availableValidationCatalogs.reduce((a, b) {
      if (a.date.isBefore(b.date)) return b;
      return a;
    });
