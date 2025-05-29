import 'dart:convert';

import 'package:http/http.dart';
import 'package:rwg_home_core/src/static/enums.dart';

/// get services status
Future<(LoadingState, List<String>)> fetchServicesStatus() async {
  try {
    final res = await Client().get(Uri.https('nice-2know.de', '/rwg-home/services'));
    final resBody = List<String>.from(jsonDecode(res.body));

    switch (res.statusCode) {
      case 200:
        return (LoadingState.done, <String>[]);
      case 540:
        return (LoadingState.doneWithError, <String>[]);
      case 541:
        return (LoadingState.error, resBody);
    }
  } catch (_) {}

  return (LoadingState.unknown, <String>[]);
}
