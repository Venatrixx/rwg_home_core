import 'dart:convert';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:http/http.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rwg_home_core/rwg_home_core.dart';
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

  ScheduleWrapper({this.vpCache = const {}});

  /// Reads the json file at the given path and constructs a [ScheduleWrapper] instance.
  factory ScheduleWrapper.fromJsonFile(String path) {
    final json = jsonDecode(File(path).readAsStringSync());
    return ScheduleWrapper.fromJson(json);
  }

  ScheduleWrapper.fromJson(dynamic json)
    : vpCache = {
        for (final entry in ((json['vpCache'] as Map?) ?? {}).entries)
          entry.key: VPWrapper.fromJson(entry.value),
      };

  dynamic toJson() => {
    for (final entry in vpCache.entries) entry.key: entry.value.toJson(),
  };

  /// Writes the content of this [ScheduleWrapper] object to the file at the given path.
  void saveToFile(String path) {
    final file = File(path);
    file.writeAsStringSync(jsonEncode(toJson()));
    return;
  }

  /// Stores a reference to an error if the latest fetch process returns an error.
  ///
  /// Resets to `null` when a fetch was successful.
  Object? error;

  /// If the last fetch has raised an error.
  bool get hasError => error != null;

  /// Past vp data. Only stores data from last 30 days and for the users class as defined in [AppConfig.userClass].
  ///
  /// Keys represent the date in `yyyyMMdd` format and values are [VPWrapper] objects for the corresponding date.
  ///
  /// **See also:**
  /// * [getCachedData]
  /// * [garbageCollectCache]
  Map<String, VPWrapper> vpCache = {};

  /// Returns the vp data for the next school day as determined by [getNextDate] method.
  ///
  /// Calls [getCachedData] internally. Only implemented for backwards compatibility.
  VPWrapper? get vpDataToday => getCachedData();

  /// Returns the cached vp data for the given date.
  ///
  /// Accepts [DateTime] objects, Strings formatted as `yyyyMMdd` and `null` (which is equal to calling the method with [getNextDate] and therefor the default behavior).
  /// Returns `null` if no data is cached.
  VPWrapper? getCachedData([dynamic date]) {
    if (![DateTime, String, Null].contains(date.runtimeType)) throw TypeError();
    String dateString;
    if (date == null) {
      dateString = getNextDate(lastLessonEndingTime()).toVpFormat();
    } else if (date is DateTime) {
      dateString = date.toVpFormat();
    } else {
      dateString = date;
    }

    return vpCache[dateString];
  }

  /// Removes data from [vpCache] that is older than 30 days.
  void garbageCollectCache() {
    vpCache.removeWhere((key, _) {
      final difference = DateTime.now().difference(
        FixedDateTimeFormatter('YYYYMMDD').decode(key),
      );
      return difference.inDays > 35;
    });
  }

  /// Returns a [Duration] object where `hour` is set the hour (and `minute` to the minute) at which the last lesson of [date] has ended.
  ///
  /// [date] defaults to today.
  ///
  /// If [subtractQuarter] is set to `true` (default), the method subtracts 15 minutes from the result. Setting the property to `false` returns the exact time.
  ///
  /// Returns a duration of `15 hours` if:
  /// * [ScheduleWrapper.vpCache] does not contain data for [date]
  /// * there is no end time for the last lesson in [AppConfig.scheduleHours]
  Duration lastLessonEndingTime({DateTime? date, bool subtractQuarter = true}) {
    final defaultDuration = Duration(hours: 15);

    date ??= DateTime.now();

    final cachedData = getCachedData(date);

    if (cachedData == null) return defaultDuration;

    final classInstance = cachedData.classes.firstWhereOrNull(
      (element) => element.name == AppConfig.userClass,
    );

    if (classInstance == null) return defaultDuration;

    final lessons = classInstance.lessons
        .where(
          (element) =>
              AppConfig.activeLessonIds.contains(element.id.toString()),
        )
        .toList();

    if (lessons.isEmpty) return defaultDuration;

    try {
      final time = AppConfig.scheduleHours[lessons.last.hour]!;
      return Duration(hours: time.endHour!, minutes: time.endMinute!) -
          Duration(minutes: 15);
    } catch (_) {
      return defaultDuration;
    }
  }

  /// Fetches the newest schedule data.
  ///
  /// If [dateToFetch] is `null`, [getNextDate] will be called to determine the next date.
  ///
  /// Returns cached data for dates that are at least one day ago if possible. This behavior can be overridden by setting [forceFetch] to `true`.
  Future<VPWrapper> fetchData({
    DateTime? dateToFetch,
    bool forceFetch = false,
    bool rethrowErrors = false,
  }) async {
    loadingState = LoadingState.loading;

    error = null;

    garbageCollectCache();

    if (vpDataToday != null &&
        !forceFetch &&
        (dateToFetch == null ||
            dateToFetch.isSameDay(getNextDate(lastLessonEndingTime())))) {
      loadingState = LoadingState.done;
      return vpDataToday!;
    }

    if (dateToFetch != null &&
        !forceFetch &&
        DateTime.now().difference(dateToFetch).inDays > 1 &&
        getCachedData(dateToFetch) != null) {
      loadingState = LoadingState.done;
      return getCachedData(dateToFetch)!;
    }

    DateTime date = dateToFetch ?? getNextDate(lastLessonEndingTime());

    if (AppConfig.isHoliday(date)) {
      loadingState = .done;
      return VPWrapper.empty();
    }

    await initializeDateFormatting('de_DE');

    Response res;

    try {
      res = await Client()
          .get(
            Uri.https(
              'www.rwg-waren.de',
              '/stundenplan/vplan/mobdaten/PlanKl${date.toVpFormat()}.xml',
            ),
          )
          .timeout(shortTimeoutDuration);
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

    AppConfig.holidayStrings = [
      for (final entry in xml.findAllElements('ft')) entry.text.trim(),
    ];

    final vpData = VPWrapper.fromXML(utf8.decode(res.bodyBytes));

    AppConfig.updateActiveLessonIds(vpData);

    final userVpClass = vpData.classes.firstWhereOrNull(
      (element) => element.name == AppConfig.userClass,
    );
    if (userVpClass != null) {
      AppConfig.updateScheduleHours(userVpClass.times);
    }

    vpCache[date.toVpFormat()] = vpData.filterClasses(AppConfig.userClass)
      ..cached = true;

    loadingState = LoadingState.done;

    return VPWrapper.fromXML(utf8.decode(res.bodyBytes));
  }

  /// Returns a list of [VPLesson] elements that happen on the given [date] and have changes.
  ///
  /// If [date] is `null`, [getNextDate] is used to determine the next date to fetch.
  ///
  /// Will throw [HolidayException] if [date] is not `null` and [date] is a holiday.
  ///
  /// **See also:**
  /// * [AppConfig.holidayStrings] which is used to determine which days are holidays.
  Future<List<VPLesson>> changedLessons([DateTime? date]) async {
    VPWrapper data;

    if (date == null && getCachedData() != null) {
      data = getCachedData()!;
    } else {
      date ??= getNextDate(lastLessonEndingTime());
      if (AppConfig.isHoliday(date)) {
        throw HolidayException(date);
      }

      data = await fetchData(dateToFetch: date);
    }

    return data.classes
        .firstWhere((cl) => cl.name == AppConfig.userClass)
        .lessons
        .where(
          (lesson) =>
              ["-1", ...AppConfig.lessonIds].contains(lesson.id.toString()) &&
              lesson.hasAnyChange,
        )
        .toList();
  }
}
