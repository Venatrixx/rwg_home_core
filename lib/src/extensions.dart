import 'package:intl/intl.dart';

extension StringConcat on String? {
  String add(String other) {
    return "$this$other";
  }
}

extension DateCompareAware on DateTime? {
  int compareToAware(DateTime? other) {
    if (this == null && other == null) return 0;
    if (this != null && other == null) return -1;
    if (this == null && other != null) return 1;
    return this!.compareTo(other!);
  }
}

extension DateCompare on DateTime {
  bool isSameDay(DateTime other) {
    return day == other.day && month == other.month && year == other.year;
  }
}

extension DateExtension on DateTime {
  String toVpFormat() => DateFormat('yyyyMMdd').format(this);
}

extension DurationExtension on Duration {
  int get hours => inHours % 24;
  int get minutes => inMinutes % 60;
}

extension ListSearch<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (_) {
      return null;
    }
  }
}

extension DynamicExtension on dynamic {
  /// Converts `this` into a string by calling `toString()` and trims it.
  /// Only returns the trimmed string if it's not equal to an empty string or "null". Returns `null` otherwise.
  String? toStringOrNull() {
    String trimmedString = toString().trim();
    return !["", "null"].contains(trimmedString.toLowerCase())
        ? trimmedString
        : null;
  }
}

class Range<T> {
  T? from;
  T? to;

  Range({this.from, this.to});

  /// Checks if `from` and `to` are not `null`.
  bool get hasLimits => from != null && to != null;
}

extension RangeInclude on Range<int> {
  /// Checks if:
  /// ```dart
  /// from! <= t && t <= to!
  /// ```
  /// Returns `null` if either [from] or [to] are null.
  bool? includes(int t) {
    if (hasLimits) {
      return from! <= t && t <= to!;
    } else if (from != null && to == null) {
      return t == from;
    } else if (from == null && to != null) {
      return t == to;
    }
    return null;
  }
}
