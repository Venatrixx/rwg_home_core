import 'package:rwg_home_core/rwg_home_core.dart';
import 'package:rwg_home_core/src/hip/hip_lesson.dart';
import 'package:rwg_home_core/src/schedule/vp_time.dart';

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
