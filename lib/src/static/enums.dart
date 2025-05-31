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
  custom(),

  holiday("Feiertag"),

  missingDay("Fehltag"),

  parMissingDay("Fehltag"),

  test("Test"),

  exam("Klausur"),

  event("Veranstaltung");

  const EventType([this.text]);
  final String? text;
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
