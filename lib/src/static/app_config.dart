import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:home_info_point_client/home_info_point_client.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rwg_home_core/rwg_home_core.dart';

/// Stores important values or settings that need to be accessed at different parts of the app.
final class AppConfig {
  /// This class is not meant to be instantiated or extended; this constructor
  /// prevents instantiation and extension.
  AppConfig._();

  /// Path to the application directory.
  static late final String documentsDir;

  /// Get the path to the app_config.json file.
  static String get configPath => "$documentsDir/app_config.json";

  static AndroidOptions get _aOptions => AndroidOptions(encryptedSharedPreferences: true);
  static IOSOptions get _iOptions => IOSOptions(accessibility: KeychainAccessibility.first_unlock);

  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage(aOptions: _aOptions, iOptions: _iOptions);

  /// If Home.InfoPoint credentials are available.
  ///
  /// **See also:**
  /// * [setCredentials] for changing the credentials,
  /// * [deleteCredentials] for deleting the credentials,
  /// * [hipUsername] for getting the current username and
  /// * [userHipConfig] for getting the current [HipConfig] for this user.
  static bool hasCredentials = false;

  /// Returns the current username saved for Home.InfoPoint or `null` if there is no username.
  static Future<String?> get hipUsername => _secureStorage.read(key: 'username');

  /// Returns a [HipConfig] instance with the current credentials.
  ///
  /// If no credentials are found, [HipConfig.username] and [HipConfig.password] are set to empty strings.
  static Future<HipConfig> get userHipConfig async => HipConfig(
    schoolCode: 'rwg-waren',
    username: (await _secureStorage.read(key: 'username') ?? ""),
    password: (await _secureStorage.read(key: 'password') ?? ""),
  );

  /// Id used to identify the user in the cloud.
  ///
  /// Should be a secure hash of the users username and password from Home.InfoPoint service.
  ///
  /// **Must** be `not null`, if [storeGradesInCloud], [storeSettingsInCloud] or [storeWizardInCloud] is set to `true`.
  ///
  /// **See also:**
  /// * [setUserId] to change the [userId] and save the config afterwards.
  static String? userId;

  /// Stores the level of the user.
  ///
  /// Usually between ``7`` and ``12``. Used to determine if the user [isSek2] or [isSek1].
  ///
  /// Defaults to ``0`` if no data from Home.InfoPoint has been imported yet.
  ///
  /// **See also:**
  /// * [setLevel] to change the [level] and save the config afterwards.
  static late int level;

  /// First level that is seen as sek 2.
  ///
  /// **See also:**
  /// * [isSek2] to check if the user is in sek 2.
  /// * [isSek1] as the inverse to [isSek2]
  static final int sek2Threshold = 11;

  /// Checks if the user is in sek 2.
  ///
  /// **See also:**
  /// * [sek2Threshold]
  static bool get isSek2 => level >= sek2Threshold;
  static bool get isSek1 => !isSek2;

  /// The class name of the user. Eg. `11A` or `8D`.
  ///
  /// Defaults to an empty string.
  ///
  /// **See also:**
  /// * [setUserClass] to change the [userClass] and save the config afterwards.
  static late String userClass;

  /// List of all lesson ids the user has selected.
  ///
  /// **See also:**
  /// * [setLessonIds] to change the [lessonIds] and save the config afterwards.
  static late List<String> lessonIds;

  /// List of those lesson ids, the user has selected and that are a part of the selected [userClass].
  ///
  /// **See also:**
  /// * [updateActiveLessonIds] to change the [activeLessonIds] and save the config afterwards.
  static late List<String> activeLessonIds;

  /// List of dates as strings that are holidays.
  ///
  /// Strings are formatted as `yyMMdd`. So `251027` would be the 27th Oct 2025.
  static List<String> holidayStrings = [];

  /// Checks if the [date] is a holiday based on [holidayStrings] property.
  static bool isHoliday(DateTime date) {
    final dateString = DateFormat('yyMMdd').format(date);
    return holidayStrings.contains(dateString);
  }

  /// Returns [holidayStrings] as a list of [Event] elements, where [Event.type] is [EventType.holiday].
  static List<Event> get holidayEvents {
    final int century = (DateTime.now().year ~/ 100) * 100;
    return [
      for (final dateString in holidayStrings)
        Event.holiday(
          DateTime(
            int.parse(dateString.substring(0, 2)) + century,
            int.parse(dateString.substring(2, 4)),
            int.parse(dateString.substring(4, 6)),
          ),
        ),
    ];
  }

  /// If grades should be uploaded to the cloud.
  ///
  /// **See also:**
  /// * [updateCloudPreferences] to change this setting and save the config afterwards.
  static late bool storeGradesInCloud;

  /// If settings should be uploaded to the cloud.
  ///
  /// **See also:**
  /// * [updateCloudPreferences] to change this setting and save the config afterwards.
  static late bool storeSettingsInCloud;

  /// If a level wizard settings should be stored in the cloud.
  ///
  /// **See also:**
  /// * [updateCloudPreferences] to change this setting and save the config afterwards.
  static late bool storeWizardInCloud;

  /// Call this method to init the class and to load the local config data.
  ///
  /// Sets the [documentsDir] property and calls [loadConfigFileSync].
  ///
  /// **Remember** to also set [userId] if you want to access the cloud.
  static Future<LoadingState> initConfig() async {
    try {
      documentsDir = (await getApplicationDocumentsDirectory()).path;
    } catch (_) {
      return LoadingState.error;
    }
    hasCredentials =
        await _secureStorage.read(key: 'username') != null && await _secureStorage.read(key: 'password') != null;
    final status = loadConfigFileSync();
    await generateUserId();
    return status;
  }

  /// Load the current app_config.json file.
  ///
  /// Returns [LoadingState.done] if the file was loaded successfully.
  ///
  /// Returns [LoadingState.doneWithError] if no file was found and a new config was created.
  ///
  /// Returns [LoadingState.unknown] if an unknown error occurred. The user **should not** use the app in this state as important methods will throw errors.
  static LoadingState loadConfigFileSync() {
    try {
      final configFile = File(configPath);

      bool hasError = false;

      if (!configFile.existsSync()) {
        recreateDefaultConfig();
        hasError = true;
      }

      final data = jsonDecode(configFile.readAsStringSync());

      userId = data['userId'];

      level = data['level'];
      userClass = data['userClass'];

      lessonIds = data['lessonIds'] ?? [];
      activeLessonIds = data['activeLessonIds'] ?? [];

      storeGradesInCloud = data['storeGradesInCloud'];
      storeSettingsInCloud = data['storeSettingsInCloud'];
      storeWizardInCloud = data['storeWizardInCloud'];

      holidayStrings = data['holidayStrings'] ?? [];

      if (hasError) return LoadingState.doneWithError;
      return LoadingState.done;
    } catch (e) {
      return LoadingState.unknown;
    }
  }

  /// Saves the current static variables to the app_config.json file.
  static void saveConfigFileSync() {
    final configFile = File(configPath);

    final data = {
      'userId': userId,
      'level': level,
      'userClass': userClass,
      'lessonIds': lessonIds,
      'activeLessonIds': activeLessonIds,
      'storeGradesInCloud': storeGradesInCloud,
      'storeSettingsInCloud': storeSettingsInCloud,
      'storeWizardInCloud': storeWizardInCloud,
      'holidayStrings': holidayStrings,
    };

    configFile.writeAsStringSync(jsonEncode(data));
  }

  /// This method **deletes** the current config file and creates a new one with default values.
  static void recreateDefaultConfig() {
    final configFile = File(configPath);

    if (configFile.existsSync()) configFile.deleteSync();

    level = 0;
    userClass = '';

    lessonIds = [];
    activeLessonIds = [];

    storeGradesInCloud = false;
    storeSettingsInCloud = false;
    storeWizardInCloud = false;

    holidayStrings = [];

    saveConfigFileSync();
  }

  /// Updates the credentials for Home.InfoPoint.
  ///
  /// If [username] or [password] is `null`, the stored value remains untouched.
  static Future<void> setCredentials({String? username, String? password}) async {
    if (username != null) {
      await _secureStorage.write(key: 'username', value: username);
      hasCredentials = true;
    }

    if (password != null) {
      await _secureStorage.write(key: 'password', value: password);
      hasCredentials = true;
    }
  }

  /// Deletes the credentials for Home.InfoPoint.
  static Future<void> deleteCredentials() async {
    await _secureStorage.deleteAll();
    hasCredentials = false;
  }

  static Future<bool> verifyCredentials() async {
    final client = HipClient(await userHipConfig);
    return await client.verify().timeout(shortTimeoutDuration);
  }

  /// Changes the [userId] and saves the config file.
  static void setUserId(String? id) {
    userId = id;
    saveConfigFileSync();
  }

  /// Use this method to generate a user id from the Home.InfoPoint credentials.
  ///
  /// If [hasCredentials] is `false`, this method does nothing.
  static Future<void> generateUserId() async {
    if (!hasCredentials) return;
    final config = await userHipConfig;
    final rawString = "${config.username}${config.password}";
    final hash = sha256.convert(utf8.encode(rawString)).toString();
    userId = hash;
    saveConfigFileSync();
  }

  /// Changes the [level] and saves the config file.
  static void setLevel(int value) {
    level = value;
    saveConfigFileSync();
  }

  /// Changes the [userClass] and saves the config file.
  ///
  /// It's recommended you call [updateActiveLessonIds] afterwards.
  static void setUserClass(String value) {
    userClass = value.trim();
    saveConfigFileSync();
  }

  /// Changes the [lessonIds] and saves the config file.
  ///
  /// It's recommended you call [updateActiveLessonIds] afterwards.
  static void setLessonIds(List<String> values) {
    lessonIds = values;
    saveConfigFileSync();
  }

  /// Sets the active lesson ids as those ids, that are a.) present in [lessonIds]
  /// and b.) are registered for the stored [userClass] as a valid lesson id.
  static void updateActiveLessonIds(VPWrapper vpData) {
    // get valid ids for stored userClass
    var classIds = [
      for (final subject in vpData.classes.firstWhere((element) => element.name == userClass).subjects)
        subject.id.toString(),
    ];

    activeLessonIds = [for (final id in lessonIds.where((id) => classIds.contains(id.toString()))) id];

    saveConfigFileSync();
  }

  /// Updates the cloud preferences with the given values. If `null` is provided, the setting remains untouched.
  ///
  /// Saves the config afterwards.
  static void updateCloudPreferences({bool? grades, bool? settings, bool? wizard}) {
    if (grades != null) storeGradesInCloud = grades;
    if (settings != null) storeSettingsInCloud = settings;
    if (wizard != null) storeWizardInCloud = wizard;
    saveConfigFileSync();
  }
}
