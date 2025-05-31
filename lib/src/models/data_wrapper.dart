import 'dart:io';

import 'package:rwg_home_core/src/a_level/a_level_wrapper.dart';
import 'package:rwg_home_core/src/calendar/calendar_wrapper.dart';
import 'package:rwg_home_core/src/hip/hip_wrapper.dart';
import 'package:rwg_home_core/src/models/cloud_storage.dart';
import 'package:rwg_home_core/src/schedule/schedule_wrapper.dart';
import 'package:rwg_home_core/src/static/app_config.dart';
import 'package:rwg_home_core/src/static/enums.dart';

abstract mixin class DataWrapper {
  /// A function that gets called every time new data has loaded in.
  ///
  /// Could be used with notifyListeners().
  ///
  /// See [onLoadingStateChanged] if you want to respond to changes of the current loading state.
  void onDataChanged();

  /// A function that gets called every time [loadingState] changes.
  void onLoadingStateChanged(LoadingState newState, [Object? error]);

  /// Get called every time the [HipWrapper.loadingState] changes.
  ///
  /// `Object?` may be a reference to an error, if one happened.
  void onHipLoadingStateChanged(LoadingState newState, [Object? error]);

  /// Get called every time the [ScheduleWrapper.loadingState] changes.
  ///
  /// `Object?` may be a reference to an error, if one happened.
  void onScheduleLoadingStateChanged(LoadingState newState, [Object? error]);

  /// Get called every time the [CalendarWrapper.loadingState] changes.
  ///
  /// `Object?` may be a reference to an error, if one happened.
  void onCalendarLoadingStateChanged(LoadingState newState, [Object? error]);

  /// Override this function with a custom implementation that returns the appropriate exam weight for the given level and number of exams.
  ///
  /// **See also:**
  /// * [AppConfig.level] to access the level of the user
  double calculateExamWeight(int examsCount);

  /// Override this function with a custom implementation that returns the grade value for a given percentage and level.
  ///
  /// **See also:**
  /// * [AppConfig.level] to access the level of the user
  num mapPercentageToGrade(double percentage, {bool isExam = false});

  LoadingState __loadingState = LoadingState.unknown;

  /// If the wrapper is currently handling any fetches.
  LoadingState get loadingState => __loadingState;

  set _loadingState(LoadingState value) {
    __loadingState = value;
    if (value == LoadingState.done) error = null;
    onLoadingStateChanged.call(value, error);
  }

  /// Latest error thrown by a loading, saving or fetching process.
  ///
  /// Resets to `null` when a process finishes successfully.
  Object? error;

  /// Fetched data from the Home.InfoPoint service.
  ///
  /// See [HipWrapper] for more information.
  late HipWrapper hip;

  /// Path to the hip_wrapper.json file, where the data of this class is stored.
  String get hipPath => "${AppConfig.documentsDir}/hip_wrapper.json";

  /// Fetched data from the schedule of lessons.
  ///
  /// See [ScheduleWrapper] for more information.
  late ScheduleWrapper schedule;

  /// Fetched data from the online calendar.
  ///
  /// See [CalendarWrapper] for more information.
  late CalendarWrapper calendar;

  /// A-Level configuration and data.
  late ALevelWrapper aLevel;

  /// Path to the a_level_config.json file, where the data of this class is stored.
  String get aLevelPath => "${AppConfig.documentsDir}/a_level_config.json";

  /// Returns a combined list of [HipWrapper.missingHourEvents] and [CalendarWrapper.allCalendarEvents].
  ///
  /// [allEvents] contains missing hours, holidays and bulletins.
  List<Event> get allEvents =>
      [...hip.missingHourEvents, ...calendar.allCalendarEvents]..sort((a, b) => a.date.compareTo(b.date));

  /// Ensures that the data wrapper is initialized correctly.
  Future<void> ensureInitialized() async {
    if (File(hipPath).existsSync()) {
      hip = HipWrapper.fromJson(hipPath);
    } else {
      hip = HipWrapper()..saveToFile(hipPath);
    }
    hip.onLoadingStateChanged = onHipLoadingStateChanged;
    schedule = ScheduleWrapper();
    schedule.onLoadingStateChanged = onScheduleLoadingStateChanged;
    calendar = CalendarWrapper();
    calendar.onLoadingStateChanged = onCalendarLoadingStateChanged;
    if (File(aLevelPath).existsSync()) {
      aLevel = ALevelWrapper.fromJsonFile(aLevelPath);
    } else {
      aLevel = ALevelWrapper()..saveToFile(aLevelPath);
    }
    aLevel.onDataChanged = onDataChanged;
  }

  /// Loads the grades/hip data. Either from the local storage or, if [AppConfig.storeGradesInCloud] is set to `true`, fetches it from the cloud.
  ///
  /// If cloud storage fails, the method falls back to local storage and sets [loadingState] to [LoadingState.doneWithError].
  Future<void> loadData() async {
    error = null;

    _loadingState = LoadingState.loading;

    if (AppConfig.storeGradesInCloud) {
      try {
        final onlineData = await CloudStorage.downloadHipDataFromCloud();
        hip = HipWrapper.fromJson(onlineData);
      } catch (cloudError) {
        try {
          hip = HipWrapper.fromJsonFile(hipPath);
          error = cloudError;
          _loadingState = LoadingState.doneWithError;
          return;
        } catch (localError) {
          error = localError;
          _loadingState = LoadingState.error;
          return;
        }
      }
    } else {
      try {
        hip = HipWrapper.fromJsonFile(hipPath);
      } catch (e) {
        error = e;
        _loadingState = LoadingState.error;
        return;
      }
    }

    if (AppConfig.storeWizardInCloud) {
      try {
        final onlineData = await CloudStorage.downloadWizardDataFromCloud();
        aLevel = ALevelWrapper.fromJson(onlineData);
      } catch (cloudError) {
        try {
          aLevel = ALevelWrapper.fromJsonFile(aLevelPath);
          error = cloudError;
          _loadingState = LoadingState.doneWithError;
          return;
        } catch (localError) {
          error = localError;
          _loadingState = LoadingState.error;
          return;
        }
      }
    } else {
      try {
        aLevel = ALevelWrapper.fromJsonFile(aLevelPath);
      } catch (e) {
        error = e;
        _loadingState = LoadingState.error;
        return;
      }
    }

    _loadingState = LoadingState.done;
    return;
  }

  /// Internal method for loading data. **Does not** catch errors.
  Future<void> _loadData() async {
    if (AppConfig.storeGradesInCloud) {
      try {
        final onlineData = await CloudStorage.downloadHipDataFromCloud();
        hip = HipWrapper.fromJson(onlineData);
      } catch (cloudError) {
        hip = HipWrapper.fromJsonFile(hipPath);
        error = cloudError;
        _loadingState = LoadingState.doneWithError;
        return;
      }
    } else {
      hip = HipWrapper.fromJsonFile(hipPath);
    }

    if (AppConfig.storeWizardInCloud) {
      try {
        final onlineData = await CloudStorage.downloadWizardDataFromCloud();
        aLevel = ALevelWrapper.fromJson(onlineData);
      } catch (cloudError) {
        aLevel = ALevelWrapper.fromJsonFile(aLevelPath);
        error = cloudError;
        _loadingState = LoadingState.doneWithError;
        return;
      }
    } else {
      aLevel = ALevelWrapper.fromJsonFile(aLevelPath);
    }
  }

  /// Saves the grades/hip data. Either to the local storage, or the cloud if [AppConfig.storeGradesInCloud] is set to `true`.
  Future<void> saveData() async {
    error = null;

    _loadingState = LoadingState.loading;

    if (AppConfig.storeGradesInCloud) {
      try {
        await CloudStorage.uploadHipDataToCloud(hip.toJson());
      } catch (cloudError) {
        try {
          hip.saveToFile(hipPath);
          error = cloudError;
          _loadingState = LoadingState.doneWithError;
          return;
        } catch (localError) {
          error = localError;
          _loadingState = LoadingState.error;
          return;
        }
      }
    } else {
      try {
        hip.saveToFile(hipPath);
      } catch (e) {
        error = e;
        _loadingState = LoadingState.error;
        return;
      }
    }

    if (AppConfig.storeWizardInCloud) {
      try {
        await CloudStorage.uploadWizardDataToCloud(aLevel.toJson());
      } catch (cloudError) {
        try {
          aLevel.saveToFile(aLevelPath);
          error = cloudError;
          _loadingState = LoadingState.doneWithError;
          return;
        } catch (localError) {
          error = localError;
          _loadingState = LoadingState.error;
          return;
        }
      }
    } else {
      try {
        aLevel.saveToFile(aLevelPath);
      } catch (e) {
        error = e;
        _loadingState = LoadingState.error;
        return;
      }
    }

    _loadingState = LoadingState.done;
    return;
  }

  /// Internal method for saving data. **Does not** catch errors.
  Future<void> _saveData() async {
    if (AppConfig.storeGradesInCloud) {
      try {
        await CloudStorage.uploadHipDataToCloud(hip.toJson());
      } catch (cloudError) {
        hip.saveToFile(hipPath);
        error = cloudError;
        _loadingState = LoadingState.doneWithError;
        return;
      }
    } else {
      hip.saveToFile(hipPath);
    }

    if (AppConfig.storeWizardInCloud) {
      try {
        await CloudStorage.uploadWizardDataToCloud(aLevel.toJson());
      } catch (cloudError) {
        aLevel.saveToFile(aLevelPath);
        error = cloudError;
        _loadingState = LoadingState.doneWithError;
        return;
      }
    } else {
      aLevel.saveToFile(aLevelPath);
    }
  }

  /// Calls the [HipWrapper.fetchData] function and stores the data appropriately (locally and/or in the cloud).
  Future<void> fetchHipData() async {
    error = null;

    _loadingState = LoadingState.loading;

    try {
      await _loadData();
    } catch (e) {
      error = e;
      _loadingState = LoadingState.error;
      return;
    }

    try {
      await hip.fetchData(rethrowErrors: true);
    } catch (e) {
      error = e;
      try {
        await _loadData();
      } catch (_) {}
      _loadingState = LoadingState.error;
      return;
    }

    try {
      await _saveData();
    } catch (e) {
      error = e;
      _loadingState = LoadingState.error;
      return;
    }

    if (loadingState == LoadingState.doneWithError) return;

    _loadingState = LoadingState.done;
  }

  /// Fetches all new data for [hip], [schedule] and [calendar] and saves the data appropriately (locally and/or in the cloud).
  Future<void> fetchAll() async {
    error = null;

    _loadingState = LoadingState.loading;

    List<LoadingState> states = [];

    try {
      await _loadData();
    } catch (e) {
      error = e;
      _loadingState = LoadingState.error;
      return;
    }

    // hip data
    try {
      hip.fetchData(rethrowErrors: true);
      states.add(LoadingState.done);
    } catch (e) {
      states.add(LoadingState.error);
    }

    // schedule data
    try {
      schedule.fetchData(rethrowErrors: true);
      states.add(LoadingState.done);
    } catch (e) {
      states.add(LoadingState.error);
    }

    // calendar data
    try {
      calendar.fetchBulletins(rethrowErrors: true);
      states.add(LoadingState.done);
    } catch (e) {
      states.add(LoadingState.error);
    }

    if (states.any((e) => e == LoadingState.error)) {
      if (states.every((e) => e == LoadingState.error)) {
        try {
          await _loadData();
        } catch (_) {}
        _loadingState = LoadingState.error;
        return;
      } else {
        try {
          await _saveData();
        } catch (e) {
          error = e;
          _loadingState = LoadingState.error;
          return;
        }
        onDataChanged.call();
        _loadingState = LoadingState.doneWithError;
        return;
      }
    }

    try {
      await _saveData();
    } catch (e) {
      error = e;
      _loadingState = LoadingState.error;
      return;
    }

    onDataChanged.call();

    _loadingState = LoadingState.done;
    return;
  }
}
