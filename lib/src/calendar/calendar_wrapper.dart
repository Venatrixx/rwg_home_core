import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:rwg_home_core/rwg_home_core.dart';

part 'event.dart';

class CalendarWrapper {
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

  /// List of global events (bulletins).
  List<Event> bulletins = [];

  /// Returns a list of [Event] elements with all [AppConfig.holidayEvents] and [bulletins].
  ///
  /// Sorts the elements by [Event.date].
  List<Event> get allCalendarEvents =>
      [...AppConfig.holidayEvents, ...bulletins]..sort((a, b) => a.date.compareTo(b.date));

  /// Returns a list of [Event] elements based on [allCalendarEvents] with all events,
  /// that happen in the upcoming amount of [days].
  List<Event> getNextXDays(int days, [DateTime? currentDate]) {
    return allCalendarEvents
        .where(
          (element) =>
              dayDifference(element.date, currentDate ?? DateTime.now()) >= 0 &&
              dayDifference(element.date, currentDate ?? DateTime.now()) <= days,
        )
        .toList();
  }

  /// Gets all [Event] elements based on [allCalendarEvents] that happen in the next `7` days, starting from today.
  ///
  /// Calls [getNextXDays] with `days = 1` and `currentDate = DateTime.now()` internally.
  List<Event> get eventsNext7Days => getNextXDays(7);

  /// Fetches all bulletins and stores them inside [bulletins] property.
  Future<void> fetchBulletins({bool rethrowErrors = false}) async {
    error = null;

    loadingState = LoadingState.loading;

    try {
      final res = await Client().get(Uri.https('www.nice-2know.de', '/rwg-home/api/bulletin'));
      if (res.statusCode >= 400) throw HttpException("Daten konnten nicht abgerufen werden.");

      final json = List.from(jsonDecode(res.body));

      bulletins = [for (final elem in json) Event.eventFromJson(elem)];

      loadingState = LoadingState.done;
      return;
    } catch (e) {
      error = e;
      loadingState = LoadingState.error;
      if (rethrowErrors) rethrow;
    }
  }

  /// Submits a bulletin to the database.
  Future<void> addBulletin(String title, String description, DateTime date, String? time) async {
    error = null;

    loadingState = LoadingState.loading;

    var data = {
      'title': title.trim(),
      'description': description.trim(),
      'date': date.millisecondsSinceEpoch.toString(),
    };
    if (time != null && time.trim() != "") data['time'] = time.trim();

    try {
      final res = await Client().post(
        Uri.https('www.nice-2know.de', '/rwg-home/api/bulletin'),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: jsonEncode(data),
      );
      if (res.statusCode >= 400) throw HttpException("Ereignis konnte nicht hochgeladen werden.\nFehler: ${res.body}");

      loadingState = LoadingState.done;
      return;
    } catch (e) {
      error = e;
      loadingState = LoadingState.error;
    }
  }
}
