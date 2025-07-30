import 'package:rwg_home_core/rwg_home_core.dart';
import 'package:rwg_home_core/src/hip/hip_lesson.dart';

class ScheduleDay {
  late List<HipLesson> scheduleEntries;

  late List<HipLesson> forgottenHomework;

  late VPWrapper? vpData;

  ScheduleDay({this.scheduleEntries = const [], this.forgottenHomework = const [], this.vpData});

  ScheduleDay.fromWrappers({
    required DateTime date,
    required ScheduleWrapper scheduleData,
    required HipWrapper hipData,
  }) {
    scheduleEntries = hipData.lastLessons.where((element) => element.date.isSameDay(date)).toList();
    forgottenHomework = hipData.forgottenHomework.where((element) => element.date.isSameDay(date)).toList();
    vpData = scheduleData.getCachedData(date);
  }
}
