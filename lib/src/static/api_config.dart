import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;
import 'package:rwg_home_core/rwg_home_core.dart';

final class ApiConfig {
  ApiConfig._();

  static String? firebaseAppCheckToken;
  static Map<String, String> get defaultHeaders => {
    if (firebaseAppCheckToken is String) 'X-Firebase-AppCheck': firebaseAppCheckToken!,
  };

  /// Path to the application directory.
  static late final String documentsDir;

  /// Get the path to the app_config.json file.
  static String get configPath => "$documentsDir/api_config.json";

  static Map<String, dynamic> _data = {};

  static String? get marqueeText => _data['marqueeText'];

  static LoadingState _apiState = LoadingState.unknown;
  static LoadingState get apiState => _apiState;
  static bool get isAvailable => _apiState == LoadingState.done;

  /// Call this method to init the class and to load the local config data.
  ///
  /// Sets the [documentsDir] property and calls [loadConfigFileSync].
  static Future<LoadingState> initConfig({required String appCheckToken}) async {
    try {
      documentsDir = (await getApplicationDocumentsDirectory()).path;
    } catch (_) {
      return LoadingState.error;
    }
    firebaseAppCheckToken = appCheckToken;
    final status = loadConfigFileSync();
    return status;
  }

  /// Deletes the config file and the Home.InfoPoint credentials.
  ///
  /// The method calls [recreateDefaultConfig] afterwards.
  static Future<void> deleteConfig() async {
    try {
      File(configPath).deleteSync();
    } catch (_) {}
    recreateDefaultConfig();
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

      _data = data['data'] ?? {};

      if (hasError) return LoadingState.doneWithError;
      return LoadingState.done;
    } catch (e) {
      return LoadingState.unknown;
    }
  }

  /// Saves the current static variables to the app_config.json file.
  static void saveConfigFileSync() {
    final configFile = File(configPath);

    final data = {'data': _data};

    configFile.writeAsStringSync(jsonEncode(data));
  }

  /// This method **deletes** the current config file and creates a new one with default values.
  static void recreateDefaultConfig() {
    final configFile = File(configPath);

    if (configFile.existsSync()) {
      try {
        configFile.deleteSync();
      } catch (_) {}
    }

    _data = {};

    saveConfigFileSync();
  }

  static Future<LoadingState> fetchData() async {
    _apiState = LoadingState.loading;
    try {
      final res = await Client().get(Uri.https('rwg.nice-2know.de', '/api'), headers: defaultHeaders);

      if (res.statusCode != 503) {
        _apiState = LoadingState.doneWithError;
        return LoadingState.doneWithError;
      }

      if (res.statusCode != 200) {
        _apiState = LoadingState.error;
        return LoadingState.error;
      }

      _data = jsonDecode(res.body);

      _apiState = LoadingState.done;
      return LoadingState.done;
    } catch (e) {
      _apiState = LoadingState.unknown;
      return LoadingState.error;
    }
  }
}
