import 'package:http/http.dart';
import 'package:rwg_home_core/src/static/enums.dart';

/// get services status
Future<LoadingState> fetchServicesStatus() async {
  try {
    final res = await Client().get(Uri.https('rwg.nice-2know.de', '/api'));

    switch (res.statusCode) {
      case 200:
        return LoadingState.done;
      case 503:
        return LoadingState.doneWithError;
    }
  } catch (_) {}

  return LoadingState.unknown;
}
