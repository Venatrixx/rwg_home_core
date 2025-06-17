part of 'a_level_wrapper.dart';

/// A representation of a final grade used by the [ALevelWrapper].
class AbstractFinalGrade {
  /// The index of the semester `this` is the final grade of.
  int index;

  /// The actual value of the final grade.
  int? value;

  /// If this grade shall be included in calculations.
  bool active;

  /// If this final grade is a calculated average or an actual grade.
  bool averaged;

  AbstractFinalGrade({required this.index, required this.value, required this.active, this.averaged = false});

  AbstractFinalGrade.fromValue(this.value)
    : index = DateTime.now().millisecondsSinceEpoch,
      active = true,
      averaged = false;

  AbstractFinalGrade.empty({required this.index}) : value = null, active = false, averaged = false;

  AbstractFinalGrade.fromJson(dynamic json)
    : index = json['index'],
      value = json['value'],
      active = json['active'],
      averaged = json['averaged'];

  Map toJson() => {'index': index, 'value': value, 'active': active, 'averaged': averaged};

  AbstractFinalGrade copyWith({int? index, int? value, bool? active, bool? averaged}) => AbstractFinalGrade(
    index: index ?? this.index,
    value: value ?? this.value,
    active: active ?? this.active,
    averaged: averaged ?? this.averaged,
  );

  int compareTo(AbstractFinalGrade other) {
    if (value == null && other.value != null) return -1;
    if (value == null && other.value == null) return 0;
    if (value != null && other.value == null) return 1;
    return value!.compareTo(other.value!);
  }

  int compareToWithAveraged(AbstractFinalGrade other) {
    if (averaged && !other.averaged) return 1;
    if (!averaged && other.averaged) return -1;
    return 0;
  }
}
