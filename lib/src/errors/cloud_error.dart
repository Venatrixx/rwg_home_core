import 'package:http/http.dart';

class CloudException {
  /// Description of this error.
  String? description;

  CloudException([String? message]) : description = message;

  CloudException.fromHttp(Response response) : description = "(${response.statusCode}) ${response.body}";
}
