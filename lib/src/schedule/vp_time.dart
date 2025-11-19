import 'package:xml/xml.dart';

class VPTime {
  late int lesson;

  late int? startHour;
  late int? startMinute;

  bool get hasStartTime => startHour != null && startMinute != null;

  late int? endHour;
  late int? endMinute;

  bool get hasEndTime => endHour != null && endMinute != null;

  VPTime({
    required this.lesson,
    this.startHour,
    this.startMinute,
    this.endHour,
    this.endMinute,
  });

  VPTime.fromXML(XmlElement xmlObject) {
    lesson = int.tryParse(xmlObject.text) ?? -1;

    String? startTime = xmlObject.getAttribute('ZeitVon');
    if (startTime != null && startTime.contains(':')) {
      final times = startTime.split(':');
      startHour = int.tryParse(times[0]);
      startMinute = int.tryParse(times[1]);
    }

    String? endTime = xmlObject.getAttribute('ZeitBis');
    if (endTime != null && endTime.contains(':')) {
      final times = endTime.split(':');
      endHour = int.tryParse(times[0]);
      endMinute = int.tryParse(times[1]);
    }
  }

  VPTime.fromJson(dynamic json)
    : lesson = int.tryParse(json['lesson'].toString()) ?? -1,
      startHour = int.tryParse(json['startHour'].toString()),
      startMinute = int.tryParse(json['startMinute'].toString()),
      endHour = int.tryParse(json['endHour'].toString()),
      endMinute = int.tryParse(json['endMinute'].toString());

  dynamic toJson() => {
    'lesson': lesson,
    'startHour': startHour,
    'startMinute': startMinute,
    'endHour': endHour,
    'endMinute': endMinute,
  };

  String prettyStart() =>
      "${startHour != null && startHour! < 10 ? '0' : ''}$startHour:${startMinute != null && startMinute! < 10 ? '0' : ''}$startMinute";

  String prettyEnd() =>
      "${endHour != null && endHour! < 10 ? '0' : ''}$endHour:${endMinute != null && endMinute! < 10 ? '0' : ''}$endMinute";
}
