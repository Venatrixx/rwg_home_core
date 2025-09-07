import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:rwg_home_core/rwg_home_core.dart';

Future<List> fetchAbstractSubjects() async {
  final res = await Client().get(Uri.https('rwg.nice-2know.de', '/api/subjects')).timeout(shortTimeoutDuration);

  if (res.statusCode != 200) throw HttpException('Unerwarteter Fehler: (${res.statusCode}) ${res.body}');

  return jsonDecode(res.body) as List;
}

Future<void> submitAbstractSubject(AbstractSubject subject) async {
  final data = {'abbr': subject.abbr, 'name': subject.name, 'kind': subject.kind};

  await Client()
      .post(
        Uri.https('rwg.nice-2know.de', '/api/subjects'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode(data),
      )
      .timeout(shortTimeoutDuration);

  return;
}
