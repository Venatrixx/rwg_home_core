part of 'calendar_wrapper.dart';

class Event {
  late String title;
  String? comment;
  String? location;
  late DateTime date;
  DateTime? from;
  DateTime? to;
  List<int> curseIds;

  late EventType type;
  bool? triState;

  Event(
    this.type,
    this.title,
    this.date, {
    this.comment,
    this.location,
    this.from,
    this.to,
    this.curseIds = const [],
    this.triState,
  });
  Event.holiday(this.date, {this.comment, this.triState})
    : type = EventType.holiday,
      title = "Ferientag",
      curseIds = [];
  Event.missingDay(
    this.date,
    this.title, {
    this.location,
    this.comment,
    this.triState,
  }) : type = EventType.missingDay,
       curseIds = [];

  Event.eventFromJson(dynamic json)
    : title = json['title'] as String,
      comment = json['comment'] as String?,
      location = json['location'] as String?,
      date = DateTime.parse(json['date']),
      from = DateTime.tryParse(json['from'] ?? ''),
      to = DateTime.tryParse(json['to'] ?? ''),
      curseIds = List<int>.from(json['curseIds'] ?? []),
      type = EventType.event;

  Map<String, dynamic> toJson() => {
    'title': title,
    'comment': comment,
    'location': location,
    'date': date.toIso8601String(),
    'from': from?.toIso8601String(),
    'to': to?.toIso8601String(),
    'curse_ids': curseIds,
    'type': type.text,
  };

  bool isOn(DateTime date) {
    if (from != null && to != null) {
      return (date.isAfter(from!) || date.isSameDay(from!)) &&
          (date.isBefore(to!) || date.isSameDay(to!));
    }
    return this.date.isSameDay(date);
  }
}
