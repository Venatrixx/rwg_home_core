part of 'calendar_wrapper.dart';

class Event {
  late String title;
  String? comment;
  String? location;
  late DateTime date;
  DateTime? from;
  DateTime? to;
  List<int> curseIds;
  int? fromLesson;
  int? toLesson;
  late bool isAllDay;
  late bool useLessonTimes;

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
    this.fromLesson,
    this.toLesson,
    this.curseIds = const [],
    this.triState,
    this.isAllDay = true,
    this.useLessonTimes = false,
  });
  Event.holiday(this.date, {this.comment, this.triState})
    : type = EventType.holiday,
      title = "Ferientag",
      curseIds = [],
      isAllDay = true,
      useLessonTimes = false;
  Event.missingDay(
    this.date,
    this.title, {
    this.location,
    this.comment,
    this.triState,
  }) : type = EventType.missingDay,
       curseIds = [],
       isAllDay = true,
       useLessonTimes = false;

  Event.eventFromJson(dynamic json)
    : title = json['title'] as String,
      comment = json['comment'] as String?,
      location = json['location'] as String?,
      date = DateTime.parse(json['date']),
      from = DateTime.tryParse(json['from'] ?? ''),
      to = DateTime.tryParse(json['to'] ?? ''),
      curseIds = List<int>.from(json['curse_ids'] ?? []),
      type =
          EventType.values.firstWhereOrNull(
            (element) => element.text == json['type'],
          ) ??
          EventType.custom,
      fromLesson = int.tryParse(json['from_lesson'].toString()),
      toLesson = int.tryParse(json['to_lesson'].toString()),
      isAllDay = json['is_all_day'] ?? true,
      useLessonTimes = json['use_lesson_times'] ?? false;

  Map<String, dynamic> toJson() => {
    'title': title,
    'comment': comment,
    'location': location,
    'date': date.toIso8601String(),
    'from': from?.toIso8601String(),
    'to': to?.toIso8601String(),
    'curse_ids': curseIds,
    'type': type.text,
    'from_lesson': fromLesson,
    'to_lesson': toLesson,
    'is_all_day': isAllDay,
    'use_lesson_times': useLessonTimes,
  };

  bool isOn(DateTime date) {
    if (!isAllDay && from != null && to != null) {
      return (date.isAfter(from!) || date.isSameDay(from!)) &&
          (date.isBefore(to!) || date.isSameDay(to!));
    }
    return this.date.isSameDay(date);
  }

  bool isDuring(int lesson) {
    if (useLessonTimes) {
      return (fromLesson == null || fromLesson! <= lesson) &&
          (toLesson == null || toLesson! >= lesson);
    }
    return true;
  }

  void operator <<(Event other) {
    title = other.title;
    comment = other.comment;
    location = other.location;
    date = other.date;
    from = other.from;
    to = other.to;
    curseIds = other.curseIds;
    type = other.type;
    fromLesson = other.fromLesson;
    toLesson = other.toLesson;
    isAllDay = other.isAllDay;
    useLessonTimes = other.useLessonTimes;
  }
}
