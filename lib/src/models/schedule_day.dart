import 'package:rwg_home_core/rwg_home_core.dart';
import 'package:rwg_home_core/src/models/schedule_lesson.dart';

class ScheduleDay {
  late DateTime date;

  late List<ScheduleLesson> lessons;

  late DateTime? vpTimestamp;

  Object? error;
  bool get hasError => error != null;

  ScheduleDay({required this.date, this.lessons = const [], this.vpTimestamp, this.error});

  factory ScheduleDay.fromWrappers({
    required DateTime date,
    required ScheduleWrapper scheduleData,
    required HipWrapper hipData,
    VPWrapper? vpData,
  }) {
    final scheduleEntries = hipData.lastLessons.where((element) => element.date.isSameDay(date)).toList();
    final forgottenHomework = hipData.forgottenHomework.where((element) => element.date.isSameDay(date)).toList();
    vpData ??= scheduleData.getCachedData(date);
    final vpLessons = vpData?.classes
        .firstWhereOrNull((element) => element.name == AppConfig.userClass)
        ?.lessons
        .where((element) => [...AppConfig.activeLessonIds, -1].contains(element.id.toString()));

    List<ScheduleLesson> lessons = [];

    bool noData = true;

    for (int i = 8; i > 0; i--) {
      final lesson = ScheduleLesson(
        lesson: i,
        time: AppConfig.scheduleHours[i],
        teacherEntry: scheduleEntries.where((element) => element.lesson?.includes(i) ?? false).toList(),
        forgottenHomework: forgottenHomework.where((element) => element.lesson?.includes(i) ?? false).toList(),
        vpLessons: vpLessons?.where((element) => element.hour == i).toList() ?? [],
      );

      if (noData && lesson.hasData) noData = false;

      lesson.noData = noData;

      lessons.add(lesson);
    }

    return ScheduleDay(date: date, lessons: lessons, vpTimestamp: vpData?.lastUpdate);
  }
}
