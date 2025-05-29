/// A [LockedError] is thrown when the user tries to change a value of a [Semester] where [Semester.locked] is set to `true`.
class LockedError extends Error {}
