import 'package:intl/intl.dart';
import 'package:rwg_home_core/rwg_home_core.dart';

class HipLesson {
  DateTime date;

  Range<int>? lesson;

  String? subject;

  String? topic;

  String? homework;

  String? typeString;
  HipLessonType type = HipLessonType.unknown;

  String? comment;

  HipLesson({
    required this.date,
    this.lesson,
    this.subject,
    this.topic,
    this.homework,
    this.typeString,
    this.type = HipLessonType.unknown,
    this.comment,
  });

  factory HipLesson.fromHipJson(dynamic json) {
    DateTime date = DateFormat('dd.MM.yyyy').parse(json['date']);

    Range<int>? lesson = Range();
    if (json['lesson'] is String) {
      try {
        int? firstLesson = int.tryParse(json['lesson']);

        if (firstLesson is! int) throw 1;

        lesson.from = firstLesson;
      } catch (_) {
        lesson = null;
      }
    } else {
      lesson = null;
    }

    HipLessonType mapTypeToEventType(String? type) {
      if (type == null) return HipLessonType.unknown;
      if (type.contains('Unterricht')) {
        return HipLessonType.lesson;
      }

      if (type.contains('Hausaufgabe')) {
        return HipLessonType.homework;
      }
      if (["Prüfung", "Test"].any((element) => type.contains(element))) {
        return HipLessonType.test;
      }
      return HipLessonType.unknown;
    }

    return HipLesson(
      date: date,
      lesson: lesson,
      subject: (json['subject'] as String?).toStringOrNull(),
      topic: (json['topic'] as String?).toStringOrNull(),
      homework: (json['homework'] as String?).toStringOrNull(),
      typeString: (json['type'] as String?).toStringOrNull(),
      type: mapTypeToEventType(json['type'] as String?),
      comment: (json['comment'] as String?).toStringOrNull(),
    );
  }

  HipLesson.fromJson(dynamic json)
    : date = DateTime.parse(json['date']),
      lesson = Range<int>(from: json['lessonFrom'], to: json['lessonTo']),
      subject = json['subject'],
      topic = json['topic'],
      homework = json['homework'],
      typeString = json['typeString'],
      type =
          HipLessonType.values.firstWhereOrNull(
            (element) => element.label == json['type'],
          ) ??
          HipLessonType.unknown,
      comment = json['comment'];

  Map toJson() => {
    'date': date.toIso8601String(),
    'lessonFrom': lesson?.from,
    'lessonTo': lesson?.to,
    'subject': subject,
    'topic': topic,
    'homework': homework,
    'typeString': typeString,
    'type': type.label,
    'comment': comment,
  };
}
