part of 'schedule_day.dart';

class ScheduleLesson {
  int lesson;

  VPTime? time;

  List<HipLesson> teacherEntry;

  List<HipLesson> forgottenHomework;

  List<VPLesson> vpLessons;

  bool noData;

  ScheduleLesson({
    required this.lesson,
    this.time,
    this.teacherEntry = const [],
    this.forgottenHomework = const [],
    this.vpLessons = const [],
    this.noData = false,
  });

  bool get hasData => teacherEntry.isNotEmpty || forgottenHomework.isNotEmpty || vpLessons.isNotEmpty;
}
