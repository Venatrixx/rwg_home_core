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
}
