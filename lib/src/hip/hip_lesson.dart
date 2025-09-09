import 'package:intl/intl.dart';
import 'package:rwg_home_core/rwg_home_core.dart';

class HipLesson {
  DateTime date;

  Range<int>? lesson;

  String? subject;

  String? topic;

  String? homework;

  String? type;

  String? comment;

  HipLesson({required this.date, this.lesson, this.subject, this.topic, this.homework, this.type, this.comment});

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

    return HipLesson(
      date: date,
      lesson: lesson,
      subject: (json['subject'] as String?).toStringOrNull(),
      topic: (json['topic'] as String?).toStringOrNull(),
      homework: (json['homework'] as String?).toStringOrNull(),
      type: (json['type'] as String?).toStringOrNull(),
      comment: (json['comment'] as String?).toStringOrNull(),
    );
  }

  HipLesson.fromJson(dynamic json)
    : date = DateTime.parse(json['date']),
      lesson = Range<int>(from: json['lessonFrom'], to: json['lessonTo']),
      subject = json['subject'],
      topic = json['topic'],
      homework = json['homework'],
      type = json['type'],
      comment = json['comment'];

  Map toJson() => {
    'date': date.toIso8601String(),
    'lessonFrom': lesson?.from,
    'lessonTo': lesson?.to,
    'subject': subject,
    'topic': topic,
    'homework': homework,
    'type': type,
    'comment': comment,
  };
}
