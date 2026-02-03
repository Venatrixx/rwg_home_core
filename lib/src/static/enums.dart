import 'package:rwg_home_core/rwg_home_core.dart';

enum LoadingState {
  /// The current state is unknown. Default case, if no process is running.
  unknown(false),

  /// A process is currently active.
  loading(false),

  /// The process could not finish because of an error.
  error(false),

  /// The process has finished, however, an error has occurred during the process.
  doneWithError(true),

  /// The process has finished successfully.
  done(true);

  const LoadingState(this.canContinue);

  /// If the loading state should allow the underlying process to continue.
  final bool canContinue;
}

enum EventType {
  custom("Sonstige"),

  holiday("Ferien"),

  missingDay("Fehltag"),

  parMissingDay("Fehlstunde"),

  test("Test"),

  exam("Klausur"),

  event("Veranstaltung"),

  excursion("Exkursion"),

  trip("Klassenfahrt"),

  hikingDay("Wandertag");

  const EventType(this.text);
  final String text;

  factory EventType.parse(String? text) {
    return values.firstWhere((element) => element.text == text);
  }
}

enum EventSource {
  custom("Benutzerdefiniert"),

  hip("NotenOnline"),

  teacherPortal("Lehrerportal");

  const EventSource(this.text);
  final String text;

  factory EventSource.parse(String text) {
    return values.firstWhere((element) => element.text == text);
  }

  static EventSource? tryParse(String? text) {
    return values.firstWhereOrNull((element) => element.text == text);
  }
}

enum TaskStatus {
  unknown(false),
  error(false, false),
  completeWithError(true, true),
  complete(true, true);

  const TaskStatus(this.allowContinue, [this.successful]);
  final bool allowContinue;
  final bool? successful;
}

enum HipLessonType {
  lesson("Unterricht"),
  homework('Hausaufgabe'),
  test('Test/Prüfung'),
  unknown('Unbekannt');

  const HipLessonType(this.label);
  final String label;
}
