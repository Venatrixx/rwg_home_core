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
        String lessonString = json['lesson'];
        String firstLessonString = lessonString.substring(
          lessonString.indexOf(RegExp(r'[0-9]'), lessonString.indexOf(RegExp(r'[^0-9]'))),
        );
        int? firstLesson = int.tryParse(firstLessonString);

        if (firstLesson is! int) throw 1;

        lesson.from = firstLesson;

        try {
          lessonString = lessonString.substring(lessonString.indexOf(firstLessonString) + firstLessonString.length);
          String secondLessonString = lessonString.substring(
            lessonString.indexOf(RegExp(r'[0-9]'), lessonString.indexOf(RegExp(r'[^0-9]'))),
          );
          int? secondLesson = int.tryParse(secondLessonString);
          if (secondLesson is int) lesson.to = secondLesson;
        } catch (_) {}
      } catch (_) {
        lesson = null;
      }
    } else {
      lesson = null;
    }

    return HipLesson(
      date: date,
      lesson: lesson,
      subject: json['subject'].toStringOrNull(),
      topic: json['topic'].toStringOrNull(),
      homework: json['homework'].toStringOrNull(),
      type: json['type'].toStringOrNull(),
      comment: json['comment'].toStringOrNull(),
    );
  }

  HipLesson.fromJson(dynamic json)
    : date = DateTime.fromMillisecondsSinceEpoch(json['date']),
      lesson = Range<int>(from: int.tryParse(json['lessonFrom']), to: int.tryParse(json['lessonTo'])),
      subject = json['subject'],
      topic = json['topic'],
      homework = json['homework'],
      type = json['type'],
      comment = json['comment'];

  Map toJson() => {
    'date': date.millisecondsSinceEpoch,
    'lessonFrom': lesson?.from,
    'lessonTo': lesson?.to,
    'subject': subject,
    'topic': topic,
    'homework': homework,
    'type': type,
    'comment': comment,
  };
}
