/// Will be thrown by [ScheduleWrapper.changedLessons] if the date for which the fetch is made is a holiday.
class HolidayError extends Error {
  final DateTime date;
  HolidayError(this.date);
}
