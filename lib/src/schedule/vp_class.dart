part of 'vp_wrapper.dart';

class VPClass {
  late String name;

  late List<VPSubject> subjects;
  late List<VPLesson> lessons;

  VPClass({required this.name, required this.subjects, required this.lessons});

  VPClass.fromXML(XmlElement xmlObject) {
    name = xmlObject.findAllElements('Kurz').first.text;

    subjects = [for (final subject in xmlObject.findAllElements('Ue')) VPSubject.fromXML(subject)];

    lessons = [for (final lesson in xmlObject.findAllElements('Std')) VPLesson.fromXML(lesson)];
  }
}
