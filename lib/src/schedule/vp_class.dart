part of 'vp_wrapper.dart';

class VPClass {
  late String name;

  late List<VPTime> times;

  late List<VPSubject> subjects;
  late List<VPLesson> lessons;

  VPClass({required this.name, this.times = const [], required this.subjects, required this.lessons});

  VPClass.fromXML(XmlElement xmlObject) {
    name = xmlObject.findAllElements('Kurz').first.text;

    times = [for (final time in xmlObject.findAllElements('KlSt')) VPTime.fromXML(time)];

    subjects = [for (final subject in xmlObject.findAllElements('Ue')) VPSubject.fromXML(subject)];

    lessons = [for (final lesson in xmlObject.findAllElements('Std')) VPLesson.fromXML(lesson)];
  }

  VPClass.fromJson(dynamic json)
    : name = json['name'].toString(),
      times = [],
      subjects = [for (final entry in json['subjects'] ?? []) VPSubject.fromJson(entry)],
      lessons = [for (final entry in json['lessons'] ?? []) VPLesson.fromJson(entry)];

  dynamic toJson() => {
    'name': name,
    'subjects': [for (final subject in subjects) subject.toJson()],
    'lessons': [for (final lesson in lessons) lesson.toJson()],
  };
}
