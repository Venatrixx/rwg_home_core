import 'package:intl/intl.dart';
import 'package:rwg_home_core/rwg_home_core.dart';
import 'package:xml/xml.dart';

part 'vp_subject.dart';
part 'vp_class.dart';
part 'vp_lesson.dart';
part 'vp_time.dart';

class VPWrapper {
  late DateTime date;
  late DateTime lastUpdate;

  late List<VPClass> classes;

  late bool cached;

  VPWrapper({
    required this.date,
    required this.lastUpdate,
    required this.classes,
    this.cached = false,
  });

  VPWrapper.fromXML(String xmlString, {this.cached = false}) {
    final xml = XmlDocument.parse(xmlString);

    String dateString = xml.findAllElements('DatumPlan').first.text;
    dateString = dateString.substring(dateString.indexOf(' ') + 1);

    date = DateFormat('dd. MMMM yyyy', 'de_DE').parse(dateString);
    lastUpdate = DateFormat(
      'dd.MM.yyyy, HH:mm',
      'de_DE',
    ).parse(xml.findAllElements('zeitstempel').first.text);

    classes = [
      for (final classInstance in xml.findAllElements('Kl'))
        VPClass.fromXML(classInstance),
    ];
  }

  VPWrapper.fromJson(dynamic json)
    : date = DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['date'].toString()),
      ),
      lastUpdate = DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['lastUpdate'].toString()),
      ),
      classes = [
        for (final entry in json['classes'] ?? []) VPClass.fromJson(entry),
      ],
      cached = json['cached'] ?? false;

  VPWrapper.empty()
    : date = DateTime.now(),
      lastUpdate = DateTime.now(),
      classes = [],
      cached = false;

  dynamic toJson() => {
    'date': date.millisecondsSinceEpoch,
    'lastUpdate': lastUpdate.millisecondsSinceEpoch,
    'classes': [for (final element in classes) element.toJson()],
    'cached': cached,
  };

  VPWrapper filterClasses(String classNameFilter) => VPWrapper(
    date: date,
    lastUpdate: lastUpdate,
    classes: classes
        .where((element) => element.name == classNameFilter)
        .toList(),
    cached: cached,
  );

  //
  // methods
  //

  VPClass? getClassByName(String className) =>
      classes.firstWhereOrNull((element) => element.name == className);
}
