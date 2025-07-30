part of 'vp_wrapper.dart';

class VPSubject {
  late String label;
  late String teacher;
  late String? secondaryID;
  late int id;

  bool get isAdvanced => RegExp('[A-Z]+d*').hasMatch(secondaryID ?? label);

  VPSubject({required this.label, required this.teacher, required this.id, this.secondaryID});

  VPSubject.fromXML(XmlElement xmlObject) {
    label = xmlObject.getElement('UeNr')?.getAttribute('UeFa') ?? "?";
    teacher = xmlObject.getElement('UeNr')?.getAttribute('UeLe') ?? "?";
    id = int.tryParse(xmlObject.getElement('UeNr')?.text ?? "Z") ?? -1;
    secondaryID = xmlObject.getElement('UeNr')?.getAttribute('UeGr');
  }

  VPSubject.fromJson(dynamic json)
    : label = json['label'].toString(),
      teacher = json['teacher'].toString(),
      secondaryID = json['secondaryID'].toStringOrNull(),
      id = int.parse(json['id'].toString());

  dynamic toJson() => {'label': label, 'teacher': teacher, 'secondaryID': secondaryID, 'id': id};
}
