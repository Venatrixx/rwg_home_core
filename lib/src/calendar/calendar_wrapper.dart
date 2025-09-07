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

  CalendarWrapper({this.events = const []});

  /// Stores a reference to an error if the latest fetch process returns an error.
  ///
  /// Resets to `null` when a fetch was successful.
  Object? error;

  /// List of global events.
  List<Event> events = [];

  /// Returns a list of [Event] elements with all [AppConfig.holidayEvents] and [events].
  ///
  /// Sorts the elements by [Event.date].
  List<Event> get allCalendarEvents =>
      [...AppConfig.holidayEvents, ...events]..sort((a, b) => a.date.compareTo(b.date));

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

  /// Fetches all bulletins and stores them inside [events] property.
  Future<void> fetchEvents({bool rethrowErrors = false}) async {
    error = null;

    loadingState = LoadingState.loading;

    try {
      final res = await Client().get(Uri.https('rwg.nice-2know.de', '/api/events'));
      if (res.statusCode >= 400) throw HttpException("Daten konnten nicht abgerufen werden.");

      final json = List.from(jsonDecode(res.body));

      events = [for (final elem in json) Event.eventFromJson(elem)];

      loadingState = LoadingState.done;
      return;
    } catch (e) {
      error = e;
      loadingState = LoadingState.error;
      if (rethrowErrors) rethrow;
    }
  }

  /// Submits a bulletin to the database.
  Future<void> addEvent({
    required String title,
    required DateTime date,
    String? comment,
    String? location,
    DateTime? from,
    DateTime? to,
    List<int>? curseIds,
  }) async {
    error = null;

    loadingState = LoadingState.loading;

    var data = {
      'title': title.trim(),
      'date': date.toIso8601String(),
      'comment': comment?.trim(),
      'location': location?.trim(),
      'from': from?.toIso8601String(),
      'to': to?.toIso8601String(),
      'curseIds': curseIds,
    };

    try {
      final res = await Client().post(
        Uri.https('rwg.nice-2know.de', '/api/events'),
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
