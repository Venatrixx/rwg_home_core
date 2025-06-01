part of 'hip_wrapper.dart';

class MissingHour {
  late DateTime? date;

  late String? lessons;

  late String? subject;

  late String? comment;

  late bool? excused;

  late String? term;

  bool get isDay => lessons == null && subject == null;

  String get bodyString {
    return "${term != null ? "$term HJ" : ""}${subject != null ? " $subject" : ""}${lessons != null ? " $lessons" : ""}${comment != null ? "\n($comment)" : ""}";
  }

  MissingHour.dayFromJson(dynamic json) {
    lessons = null;
    subject = null;
    comment = json['reason'] != "" ? json['reason'] : null;
    term = json['semester'] != "" ? json['semester'] : null;

    try {
      date = DateFormat('dd.MM.yyyy').parse(json['date']);
    } catch (_) {
      date = null;
      comment = "$date: ${comment ?? ""}";
    }

    switch (json['excused'].trim().toLowerCase()) {
      case "entschuldigt":
        excused = true;
        break;
      case "unentschuldigt":
        excused = false;
        break;
      case "nicht entschieden":
        excused = null;
        break;
      default:
        excused = null;
        comment = "${comment ?? ""} (${json['excused']})";
        break;
    }
  }

  MissingHour.hourFromJson(dynamic json) {
    lessons = json['time'] != "" ? json['time'] : null;
    subject = json['subject'] != "" ? json['subject'] : null;
    comment = json['reason'] != "" ? json['reason'] : null;
    term = json['semester'] != "" ? json['semester'] : null;

    try {
      date = DateFormat('dd.MM.yyyy').parse(json['date']);
    } catch (_) {
      date = null;
      comment = "$date: ${comment ?? ""}";
    }

    switch (json['excused'].trim().toLowerCase()) {
      case "entschuldigt":
        excused = true;
        break;
      case "unentschuldigt":
        excused = false;
        break;
      case "nicht entschieden":
        excused = null;
        break;
      default:
        excused = null;
        comment = "${comment ?? ""} (${json['excused']})";
        break;
    }
  }

  int compareTo(MissingHour other) {
    if (excused != false && other.excused == false) return 1;
    if (excused == false && other.excused != false) return -1;
    if (excused == null && other.excused == true) return 1;
    if (excused == true && other.excused == null) return -1;
    return 0;
  }
}
