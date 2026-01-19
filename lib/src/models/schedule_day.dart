import 'package:rwg_home_core/rwg_home_core.dart';

part 'schedule_lesson.dart';

class ScheduleDay {
  late DateTime date;

  late List<ScheduleLesson> lessons;

  late DateTime? vpTimestamp;

  Object? error;
  bool get hasError => error != null;

  late bool hasVPData;
  late bool hasComment;
  late bool hasHomework;
  late bool hasMissingHour;

  ScheduleDay({
    required this.date,
    this.lessons = const [],
    this.vpTimestamp,
    this.error,
    this.hasVPData = false,
    this.hasComment = false,
    this.hasHomework = false,
    this.hasMissingHour = false,
  });

  factory ScheduleDay.fromWrappers({
    required DateTime date,
    required ScheduleWrapper scheduleData,
    required HipWrapper hipData,
    required VPWrapper? vpData,
    Object? error,
  }) {
    final scheduleEntries = hipData.lastLessons
        .where((element) => element.date.isSameDay(date))
        .toList();
    final forgottenHomework = hipData.forgottenHomework
        .where((element) => element.date.isSameDay(date))
        .toList();
    final vpLessons = vpData?.classes
        .firstWhereOrNull((element) => element.name == AppConfig.userClass)
        ?.lessons
        .where(
          (element) => [
            ...AppConfig.activeLessonIds,
            '-1',
          ].contains(element.id.toString()),
        );
    final missingHours = hipData.missingHourData?.where(
      (element) => element.date?.isSameDay(date) ?? false,
    );

    List<ScheduleLesson> lessons = [];

    bool noData = true;

    for (int i = 8; i > 0; i--) {
      final lesson = ScheduleLesson(
        lesson: i,
        time: AppConfig.scheduleHours[i],
        teacherEntry: scheduleEntries
            .where((element) => element.lesson?.includes(i) ?? false)
            .toList(),
        forgottenHomework: forgottenHomework
            .where((element) => element.lesson?.includes(i) ?? false)
            .toList(),
        vpLessons:
            vpLessons?.where((element) => element.hour == i).toList() ?? [],
        missingData:
            missingHours
                ?.where(
                  (element) => element.lessons?.contains(i.toString()) ?? false,
                )
                .toList() ??
            [],
      );

      if (noData && lesson.hasData) noData = false;

      lesson.noData = noData;

      lessons.add(lesson);
    }

    return ScheduleDay(
      date: date,
      lessons: lessons.reversed.toList(),
      vpTimestamp: vpData?.lastUpdate,
      error: error,
      hasVPData: vpLessons != null,
      hasComment: lessons.any((element) => element.teacherEntry.isNotEmpty),
      hasHomework: lessons.any(
        (element) => element.forgottenHomework.isNotEmpty,
      ),
      hasMissingHour: lessons.any((element) => element.missingData.isNotEmpty),
    );
  }
}
