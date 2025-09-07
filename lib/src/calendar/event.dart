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
  Event.missingDay(this.date, this.title, {this.location, this.comment, this.triState})
    : type = EventType.missingDay,
      curseIds = [];

  Event.eventFromJson(dynamic json)
    : title = json['title'] as String,
      comment = json['comment'] as String?,
      location = json['location'] as String?,
      date = DateTime.parse(json['date']),
      from = DateTime.tryParse(json['from'] ?? ''),
      to = DateTime.tryParse(json['to'] ?? ''),
      curseIds = List<int>.from(json['curseIds'] ?? []);
}
