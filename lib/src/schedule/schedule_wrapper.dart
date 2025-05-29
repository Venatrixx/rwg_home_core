import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:rwg_home_core/rwg_home_core.dart';
import 'package:rwg_home_core/src/schedule/vp_wrapper.dart';
import 'package:xml/xml.dart';

/// Contains data for the school schedule.
class ScheduleWrapper {
  void Function(LoadingState, [Object?])? onLoadingStateChanged;

  LoadingState _loadingState = LoadingState.unknown;

  LoadingState get loadingState => _loadingState;
  set loadingState(LoadingState value) {
    _loadingState = value;
    onLoadingStateChanged?.call(value, error);
  }

  /// Stores a reference to an error if the latest fetch process returns an error.
  ///
  /// Resets to `null` when a fetch was successful.
  Object? error;

  /// Contains a reference to the schedule data of the next day. Use this to decrease loading time for widgets.
  VPWrapper? vpDataToday;

  /// If the last fetch has raised an error.
  bool get hasError => error != null;

  /// Fetches the newest schedule data.
  ///
  /// If [dateToFetch] is `null`, [getNextDate] will be called to determine the next date.
  Future<VPWrapper> fetchData({DateTime? dateToFetch, bool rethrowErrors = false}) async {
    loadingState = LoadingState.loading;

    error = null;

    if (vpDataToday != null && (dateToFetch == null || dateToFetch.isSameDay(vpDataToday!.date))) {
      return vpDataToday!;
    }

    DateTime date = dateToFetch ?? getNextDate();

    await initializeDateFormatting('de_DE');

    Response res;

    try {
      res = await Client()
          .get(
            Uri.https(
              'www.rwg-waren.de',
              '/stundenplan/vplan/mobdaten/PlanKl${DateFormat('yyyyMMdd').format(date)}.xml',
            ),
          )
          .timeout(Duration(seconds: 5));
    } catch (e) {
      error = e;
      loadingState = LoadingState.error;
      if (rethrowErrors) rethrow;
      return VPWrapper.empty();
    }

    if (res.statusCode != 200) {
      error = HttpException("(${res.statusCode}) ${res.body}");
      loadingState = LoadingState.error;
      if (rethrowErrors) throw error!;
      return VPWrapper.empty();
    }

    // convert response to xml. throws error if vp not available and cancels task
    final xml = XmlDocument.parse(utf8.decode(res.bodyBytes));

    AppConfig.holidayStrings = [for (final entry in xml.findAllElements('ft')) entry.text.trim()];

    final vpData = VPWrapper.fromXML(utf8.decode(res.bodyBytes));

    AppConfig.updateActiveLessonIds(vpData);

    if (dateToFetch == null) vpDataToday = vpData;

    return vpData;
  }

  /// Returns a list of [VPLesson] elements that happen on the given [date] and have changes.
  ///
  /// If [date] is `null`, [getNextDate] is used to determine the next date to fetch.
  ///
  /// Will throw [HolidayError] if [date] is not `null` and [date] is a holiday.
  ///
  /// **See also:**
  /// * [AppConfig.holidayStrings] which is used to determine which days are holidays.
  Future<List<VPLesson>> changedLessons([DateTime? date]) async {
    VPWrapper data;

    if (date == null && vpDataToday != null) {
      data = vpDataToday!;
    } else {
      date ??= getNextDate();
      if (AppConfig.isHoliday(date)) {
        throw HolidayError(date);
      }

      data = await fetchData(dateToFetch: date);
    }

    return data.classes
        .firstWhere((cl) => cl.name == AppConfig.userClass)
        .lessons
        .where((lesson) => AppConfig.lessonIds.contains(lesson.id.toString()) && lesson.hasAnyChange)
        .toList();
  }
}
