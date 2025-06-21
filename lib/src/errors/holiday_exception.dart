/// Will be thrown by [ScheduleWrapper.changedLessons] if the date for which the fetch is made is a holiday.
class HolidayException {
  final DateTime date;
  HolidayException(this.date);
}
