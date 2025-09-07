import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:home_info_point_client/home_info_point_client.dart' show HipConfig;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:rwg_home_core/src/constants.dart';
import 'package:rwg_home_core/src/errors/cloud_exception.dart';
import 'package:rwg_home_core/src/static/app_config.dart';

final class CloudStorage {
  static void _checkUserIdAvailable() {
    if (AppConfig.userId == null) throw CloudException('Benutzer-ID nicht verfügbar.');
    return;
  }

  /// Use this function to check the cloud status of the current user.
  ///
  /// Returns a tuple with a ``bool`` value that indicates if data is available and a user friendly formatted string.
  ///
  /// Possible responses:
  /// * (204) when there's no data
  /// * (200) when there is data
  static Future<(bool, String?)> getCloudStatus() async {
    _checkUserIdAvailable();
    final res = await Client()
        .get(Uri.https('rwg.nice-2know.de', '/api/cloud/users/${AppConfig.userId!}'))
        .timeout(shortTimeoutDuration);

    switch (res.statusCode) {
      case 200:
        final date = DateTime.parse(jsonDecode(res.body)['first_used']).add(Duration(days: 3 * 365));
        return (true, "(200) Daten verfügbar bis ${DateFormat('dd.MM.yyyy').format(date)}.");
      case 204:
        return (false, "(204) Keine Daten für diesen Nutzer vorhanden.");
      default:
        return (false, "Fehler. Der Status konnte nicht bestimmt werden.");
    }
  }

  /// Registers a new user in the cloud.
  ///
  /// Only needs to be called once for a user to register his id.
  static Future<void> registerCloudUser() async {
    _checkUserIdAvailable();

    final isRegistered = (await getCloudStatus()).$1;

    if (isRegistered) return;

    final res = await Client()
        .post(Uri.https('rwg.nice-2know.de', '/api/cloud/users/${AppConfig.userId!}'))
        .timeout(shortTimeoutDuration);

    if (res.statusCode != 200) throw CloudException.fromHttp(res);

    return;
  }

  /// Deletes all data from the cloud.
  static Future<void> deleteAllDataFromCloud() async {
    _checkUserIdAvailable();

    final res = await Client()
        .delete(Uri.https('rwg.nice-2know.de', '/api/cloud/users/${AppConfig.userId!}'))
        .timeout(shortTimeoutDuration);

    if (res.statusCode != 200) throw CloudException.fromHttp(res);

    return;
  }

  /// Internal helper method to encrypt json data.
  static String _encryptData(dynamic data, HipConfig config) {
    final plainData = json.encode(data);
    final hash = sha256.convert(utf8.encode(config.password)).toString();
    final key = encrypt.Key.fromUtf8(hash.substring(0, 32));
    final iv = encrypt.IV.fromLength(16);

    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = "${iv.base16}:${encrypter.encrypt(plainData, iv: iv).base64}";

    return encrypted;
  }

  /// Internal helper method to decrypt http response string.
  static dynamic _decryptData(String data, HipConfig config) {
    final encryptedData = data.substring((data.indexOf(':') + 1));
    final iv = encrypt.IV.fromBase16(data.substring(0, data.indexOf(':')));
    final hash = sha256.convert(utf8.encode(config.password)).toString();
    final key = encrypt.Key.fromUtf8(hash.substring(0, 32));

    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decrypted = encrypter.decrypt(encrypt.Encrypted.fromBase64(encryptedData), iv: iv);

    return jsonDecode(decrypted);
  }

  /// Internal helper method to fetch data.
  static Future<Map> _fetchCloudData() async {
    final res = await Client()
        .get(Uri.https('rwg.nice-2know.de', '/api/cloud/data/${AppConfig.userId!}'))
        .timeout(shortTimeoutDuration);

    if (res.statusCode != 200) throw CloudException.fromHttp(res);

    final responseData = Map<String, dynamic>.from(jsonDecode(res.body));

    Map<String, dynamic> fetchedData = {};

    final config = await AppConfig.userHipConfig;

    for (var entry in responseData.entries) {
      if (entry.value is String) {
        fetchedData[entry.key] = _decryptData(entry.value, config);
      } else {
        fetchedData[entry.key] = null;
      }
    }

    return fetchedData;
  }

  /// Internal helper method to upload data.
  static Future<void> _uploadDataToCloud({dynamic hip, dynamic wizard, dynamic calendar}) async {
    final data = {};
    final config = await AppConfig.userHipConfig;

    if (hip != null) data['grades_data'] = _encryptData(hip, config);

    if (wizard != null) data['wizard_data'] = _encryptData(wizard, config);

    if (calendar != null) data['calendar_data'] = _encryptData(calendar, config);

    if (data.isEmpty) return;

    final res = await Client()
        .post(
          Uri.https('rwg.nice-2know.de', '/api/cloud/data/${AppConfig.userId!}'),
          headers: {'content-type': 'application/json'},
          body: jsonEncode(data),
        )
        .timeout(shortTimeoutDuration);

    if (res.statusCode != 200) throw CloudException.fromHttp(res);

    return;
  }

  static Future<void> uploadHipDataToCloud(dynamic data) async {
    if (AppConfig.storeGradesInCloud) await _uploadDataToCloud(hip: data);
  }

  static Future<dynamic> downloadHipDataFromCloud() async {
    return (await _fetchCloudData())['grades_data'];
  }

  static Future<void> uploadWizardDataToCloud(dynamic data) async {
    if (AppConfig.storeWizardInCloud) await _uploadDataToCloud(wizard: data);
  }

  static Future<dynamic> downloadWizardDataFromCloud() async {
    return (await _fetchCloudData())['wizard_data'];
  }

  static Future<void> uploadCalendarDataToCloud(dynamic data) async {
    if (AppConfig.storeCalendarInCloud) await _uploadDataToCloud(calendar: data);
  }

  static Future<dynamic> downloadCalendarDataFromCloud() async {
    return (await _fetchCloudData())['calendar_data'];
  }
}
