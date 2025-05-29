import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

part 'vp_subject.dart';
part 'vp_class.dart';
part 'vp_lesson.dart';

class VPWrapper {
  late DateTime date;
  late DateTime lastUpdate;

  late List<VPClass> classes;

  VPWrapper({required this.date, required this.lastUpdate, required this.classes});

  VPWrapper.fromXML(String xmlString) {
    final xml = XmlDocument.parse(xmlString);

    String dateString = xml.findAllElements('DatumPlan').first.text;
    dateString = dateString.substring(dateString.indexOf(' ') + 1);

    date = DateFormat('dd. MMMM yyyy', 'de_DE').parse(dateString);
    lastUpdate = DateFormat('dd.MM.yyyy, HH:mm', 'de_DE').parse(xml.findAllElements('zeitstempel').first.text);

    classes = [for (final classInstance in xml.findAllElements('Kl')) VPClass.fromXML(classInstance)];
  }

  VPWrapper.empty() : date = DateTime.now(), lastUpdate = DateTime.now(), classes = [];
}
