part of 'schedule_day.dart';

class ScheduleLesson {
  int lesson;

  VPTime? time;

  List<HipLesson> teacherEntry;

  List<HipLesson> forgottenHomework;

  List<VPLesson> vpLessons;

  List<MissingHour> missingData;

  bool noData;

  ScheduleLesson({
    required this.lesson,
    this.time,
    this.teacherEntry = const [],
    this.forgottenHomework = const [],
    this.vpLessons = const [],
    this.noData = false,
    this.missingData = const [],
  }) {
    vpLessons.sort((a, b) {
      bool aContains = AppConfig.activeLessonIds.contains(a.id.toString());
      bool bContains = AppConfig.activeLessonIds.contains(b.id.toString());

      if (aContains && !bContains) return -1;
      if (!aContains && bContains) return 1;
      return 0;
    });
  }

  bool get hasData =>
      teacherEntry.isNotEmpty ||
      forgottenHomework.isNotEmpty ||
      vpLessons.isNotEmpty ||
      missingData.isNotEmpty;
}
