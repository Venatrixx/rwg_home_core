part of 'calendar_wrapper.dart';

class Event {
  late DateTime date;

  late EventType type;

  String? comment;

  bool? triState;

  late String title;

  String? time;

  Event(this.date, this.type, this.title, {this.time, this.comment, this.triState});
  Event.holiday(this.date, {this.time, this.comment, this.triState}) : type = EventType.holiday, title = "Ferientag";
  Event.missingDay(this.date, this.title, {this.time, this.comment, this.triState}) : type = EventType.missingDay;

  Event.eventFromJson(dynamic json) {
    title = json['title'];
    type = EventType.event;
    date = DateTime.fromMillisecondsSinceEpoch(int.parse(json['date']));
    time = json['time'];
    comment = json['description'];
  }
}
