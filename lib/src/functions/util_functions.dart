import 'dart:math';

import 'package:rwg_home_core/rwg_home_core.dart';

double roundDecimals(double value, {int decimals = 2}) {
  if (value.isNaN) return value;

  value = (value * pow(10, decimals)).roundToDouble() * pow(10, -decimals);

  String stringValue = value.toString();
  String stringDecimals = stringValue.substring(stringValue.indexOf('.') + 1, stringValue.length);

  if (stringDecimals.length > decimals) {
    return double.parse(value.toString().substring(0, value.toString().indexOf('.') + decimals + 1));
  } else {
    return value;
  }
}

/// Returns the difference in days of subtracting [date2] from [date1].
int dayDifference(DateTime date1, DateTime date2) {
  return DateTime(date1.year, date1.month, date1.day).difference(DateTime(date2.year, date2.month, date2.day)).inDays;
}

/// Internal method that adds one day to [other] and skips weekends.
DateTime _addSkip(DateTime other, {bool remove = false}) {
  if (remove) {
    if (other.weekday == 1) {
      return other.subtract(const Duration(days: 3));
    }
    return other.subtract(const Duration(days: 1));
  }

  // skip to the next school day
  if (other.weekday >= 5) {
    // skip to next Monday if Friday or weekend
    return other.add(Duration(days: 8 - other.weekday));
  }
  // skip to next weekday
  return other.add(const Duration(days: 1));
}

/// Returns the next school day.
///
/// Returns [DateTime.now] if today is a school day and it's before 3 pm.
/// Returns the next school day if it's past 3 pm.
///
/// **See also:**
/// * [AppConfig.holidayStrings] which is used to determine which days are school days and which are holidays.
DateTime getNextDate({int? skipToNextDayHour, int? skipToNextDayMinute}) {
  skipToNextDayHour ??= 15;
  skipToNextDayMinute ??= 0;

  final now = DateTime.now();

  if (now.weekday <= 5 &&
      !(now.hour >= skipToNextDayHour && now.minute >= skipToNextDayMinute) &&
      !AppConfig.isHoliday(now)) {
    return now;
  }

  DateTime newDate = _addSkip(now);

  while (AppConfig.isHoliday(newDate)) {
    newDate = _addSkip(newDate);
  }
  return newDate;
}

/// Returns the next school day.
///
/// **See also:**
/// * [AppConfig.isHoliday] to determine which days are school days
DateTime nextSchoolDay(DateTime currentDate, {bool remove = false}) {
  DateTime res = _addSkip(currentDate, remove: remove);
  while (AppConfig.isHoliday(res)) {
    res = _addSkip(res, remove: remove);
  }
  return res;
}
