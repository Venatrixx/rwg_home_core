part of 'vp_wrapper.dart';

class VPClass {
  late String name;

  late List<VPTime> times;

  late List<VPSubject> subjects;
  late List<VPLesson> lessons;

  VPClass({
    required this.name,
    this.times = const [],
    required this.subjects,
    required this.lessons,
  });

  VPClass.fromXML(XmlElement xmlObject) {
    name = xmlObject.findAllElements('Kurz').first.text;

    times = [
      for (final time in xmlObject.findAllElements('KlSt'))
        VPTime.fromXML(time),
    ];

    subjects = [
      for (final subject in xmlObject.findAllElements('Ue'))
        VPSubject.fromXML(subject),
    ];

    lessons = [
      for (final lesson in xmlObject.findAllElements('Std'))
        VPLesson.fromXML(lesson),
    ];
  }

  VPClass.fromJson(dynamic json)
    : name = json['name'].toString(),
      times = [],
      subjects = [
        for (final entry in json['subjects'] ?? []) VPSubject.fromJson(entry),
      ],
      lessons = [
        for (final entry in json['lessons'] ?? []) VPLesson.fromJson(entry),
      ];

  dynamic toJson() => {
    'name': name,
    'subjects': [for (final subject in subjects) subject.toJson()],
    'lessons': [for (final lesson in lessons) lesson.toJson()],
  };

  Map<String, List<VPSubject>> getGroupedSubjects() {
    Map<String, List<VPSubject>> result = {};

    for (final subject in subjects) {
      final name = subject.label.toLowerCase().replaceAll(RegExp('[0-9]'), '');

      if (result.keys.contains(name)) {
        result[name]!.add(subject);
      } else {
        result[name] = [subject];
      }
    }

    return {
      for (final entry in result.entries)
        "${entry.key[0].toUpperCase()}${entry.key.substring(1)}": entry.value,
    };
  }
}
