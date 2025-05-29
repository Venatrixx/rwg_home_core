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
