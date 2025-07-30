part of 'vp_wrapper.dart';

class VPLesson {
  late int hour;
  late String subjectLabel;
  late String teacher;
  late String room;
  late int id;
  String? comment;

  bool hasChangedRoom = false;
  bool hasChangedTeacher = false;
  bool hasChangedSubject = false;

  bool get hasAnyChange => hasChangedRoom || hasChangedTeacher || hasChangedSubject;

  VPLesson();

  VPLesson.fromXML(XmlElement xmlObject) {
    try {
      hour = int.parse(xmlObject.getElement('St')!.text);
    } catch (e) {
      // only for debug
      rethrow;
    }

    subjectLabel = xmlObject.getElement('Fa')?.text ?? "?";
    if (xmlObject.getElement('Fa')?.getAttribute('FaAe') != null) {
      hasChangedSubject = true;
    }

    teacher = xmlObject.getElement('Le')?.text ?? "?";
    if (xmlObject.getElement('Le')?.getAttribute('LeAe') != null) {
      hasChangedTeacher = true;
    }

    room = xmlObject.getElement('Ra')?.text ?? "?";
    if (xmlObject.getElement('Ra')?.getAttribute('RaAe') != null) {
      hasChangedRoom = true;
    }

    id = int.tryParse(xmlObject.getElement('Nr')?.text ?? "Z") ?? -1;

    comment = xmlObject.getElement('If')?.text;
  }

  VPLesson.fromJson(dynamic json)
    : hour = int.parse(json['hour'].toString()),
      subjectLabel = json['subjectLabel'].toString(),
      teacher = json['teacher'].toString(),
      room = json['room'].toString(),
      id = int.parse(json['id'].toString()),
      comment = json['comment'].toStringOrNull();

  dynamic toJson() => {
    'hour': hour,
    'subjectLabel': subjectLabel,
    'teacher': teacher,
    'room': room,
    'id': id,
    'comment': comment,
  };

  @override
  bool operator ==(covariant VPLesson other) {
    return hour == other.hour &&
        subjectLabel == other.subjectLabel &&
        teacher == other.teacher &&
        room == other.room &&
        id == other.id &&
        comment == other.comment;
  }
}
