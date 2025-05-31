part of 'validation_catalog.dart';

ValidationCatalog catalog2019 = ValidationCatalog(
  catalogName: 'APVO-MV (2019)',
  catalogLink: '-',
  comment: "Besondere Lernleistungen werden nicht berücksichtigt.\nKein Anspruch auf vollständige Richtigkeit.",
  date: DateTime(2025, 6, 1),
  standardTests: standardTests,
  examSubjectsTests: examSubjectsTests,
  allowedWrittenExamSubjects: ['ma', 'de', 'en', 'ge', 'la', 'bio', 'ch', 'ph', 'info'],
  chooseOptimal: chooseOptimal,
);

List<ValidationTest> standardTests = [
  ValidationTest(
    description: "Verifiziere alle Fächer.",
    test: (config) {
      if (config.unknownSubjects.isNotEmpty) {
        return ["Min. ein Fach konnte nicht verifiziert werden."];
      }
      return null;
    },
  ),
  ValidationTest(
    description: "Wähle 2 Leistungskurse aus.",
    test: (config) {
      List<String> r = [];
      if (config.advancedSubjects.isEmpty) {
        r.add("Keine LKs ausgewählt.");
      } else if (config.advancedSubjects.length != 2) {
        r.add("Nicht genau zwei LKs ausgewählt.");
      }
      return r;
    },
    reference: "§12 Absatz 1 Satz 1",
  ),
  ValidationTest(
    description:
        "Leistungskurse müssen min. eines der folgenden Fächer enthalten: Mathe, Deutsch, fortgeführte Fremdsprache, Biologie, Chemie oder Physik.",
    test: (config) {
      if ([
        'ma',
        'de',
        'en',
        'la',
        'franz',
        'span',
        'bio',
        'ch',
        'ph',
      ].any((element) => config.advancedSubjects.contains(element))) {
        return null;
      }
      return ["Mathe, Deutsch, fortgeführte Fremdsprache, Biologie, Chemie oder Physik muss Leistungskurs sein."];
    },
    reference: "§12 Absatz 1 Satz 2",
  ),
  ValidationTest(
    description: "Wähle Prüfungsfach 3.",
    test: (config) {
      if (config.writtenExamSubject == null) {
        return ["Prüfungsfach 3 nicht belegt."];
      } else if (!['ma', 'de', 'en', 'ge', ...config.mintSubjects, 'la'].contains(config.writtenExamSubject)) {
        return [
          "Prüfungsfach 3 muss entweder Mathe, Deutsch, Englisch, Latein, Geschichte oder ein anderes naturwissenschaftliches Fach sein.",
        ];
      }
      return null;
    },
    reference: "§26 Absatz 4",
  ),
  ValidationTest(
    description: "Wähle Prüfungsfach 4 und 5.",
    test: (config) {
      if (config.oralExamSubjects.isEmpty) {
        return ["Prüfungsfach 4 und 5 nicht belegt."];
      } else if (config.advancedSubjects.length == 1) {
        return ["Prüfungsfach 5 nicht belegt."];
      }
      return null;
    },
    reference: "§25 Absatz 4",
  ),
  ValidationTest(
    description: "Belege Deutsch als Prüfungsfach.",
    test: (config) {
      if (!config.allExamSubjects.any((e) => e == 'de')) {
        return ["Deutsch ist kein Prüfungsfach."];
      }
      return null;
    },
    reference: "§25 Absatz 5 Satz 1",
  ),
  ValidationTest(
    description: "Belege Mathe als Prüfungsfach.",
    test: (config) {
      if (!config.allExamSubjects.any((e) => e == 'ma')) {
        return ["Mathe ist keine Prüfungsfach."];
      }
      return null;
    },
    reference: "§25 Absatz 5 Satz 1",
  ),
  ValidationTest(
    description: "Belege eine Gesellschaftswissenschaft als Prüfungsfach.",
    test: (config) {
      try {
        if (!config.allExamSubjects.any((e) => config.subjects.firstWhere((s) => s.abbr == e).kind == 'sc')) {
          return ["Kein gesellschaftswissenschaftliches Prüfungsfach."];
        }
      } catch (_) {
        return ["Kein gesellschaftswissenschaftliches Prüfungsfach."];
      }

      return null;
    },

    reference: "§25 Absatz 5 Satz 1",
  ),
  ValidationTest(
    description: "Belege eine Naturwissenschaft oder Informatik oder Fremdsprache als Prüfungsfach.",
    test: (config) {
      List<String> mintAbbr = [for (final elem in config.mintSubjects) elem.abbr]..remove('ma');
      if (![...mintAbbr, 'en', 'span', 'franz', 'la'].any((e) => config.allExamSubjects.contains(e))) {
        return ["Naturwissenschaft oder Informatik oder Fremdsprache nicht als Prüfungsfach belegt."];
      }
      return null;
    },
    reference: "§25 Absatz 5 Satz 1",
  ),
  ValidationTest(
    description: "Bringe Deutsch vollständig ein.",
    test: (config) {
      if (config.subjects.firstWhere((s) => s.abbr == 'de').activeGradesCount != 4) {
        return ["Deutsch nicht vollständig eingebracht."];
      }
      return null;
    },
    reference: "Anlage 5 (5a)",
  ),
  ValidationTest(
    description: "Bringe Mathe vollständig ein.",
    test: (config) {
      if (config.subjects.firstWhere((s) => s.abbr == 'ma').activeGradesCount != 4) {
        return ["Mathe nicht vollständig eingebracht."];
      }
      return null;
    },
    reference: "Anlage 5 (5a)",
  ),
  ValidationTest(
    description: "Bringe Geschichte vollständig ein.",
    test: (config) {
      if (config.subjects.firstWhere((s) => s.abbr == 'ge').activeGradesCount != 4) {
        return ["Geschichte nicht vollständig eingebracht."];
      }
      return null;
    },
    reference: "Anlage 5 (5a)",
  ),
  ValidationTest(
    description: "Bringe min. eine Naturwissenschaft (Bio, Che, Phy) vollständig ein.",
    test: (config) {
      if (![
        'bio',
        'ch',
        'ph',
      ].any((e) => config.subjects.where((s) => s.abbr == e).firstOrNull?.activeGradesCount == 4)) {
        return ["Keine Naturwissenschaft (Bio, Che oder Phy) vollständig eingebracht."];
      }
      return null;
    },
    reference: "Anlage 5 (5a)",
  ),
  ValidationTest(
    description: "Bringe min. eine Fremdsprache vollständig ein.",
    test: (config) {
      if (![
        'en',
        'span',
        'franz',
        'la',
      ].any((e) => config.subjects.where((s) => s.abbr == e).firstOrNull?.activeGradesCount == 4)) {
        return ["Keine Fremdsprache vollständig eingebracht."];
      }
      return null;
    },
    reference: "Anlage 5 (5a)",
  ),
  ValidationTest(
    description: "Bringe min. 2 Semester von Musik oder Kunst ein.",
    test: (config) {
      if (![
        'ku',
        'mu',
      ].any((e) => (config.subjects.where((s) => s.abbr == e).firstOrNull?.activeGradesCount ?? 0) >= 2)) {
        return ["Musik oder Kunst: nicht min. 2 Semester eingebracht."];
      }
      return null;
    },
    reference: "Anlage 5 (5a)",
  ),
  ValidationTest(
    description: "Bringe min. 2 Semester von Philosophie oder Religion ein.",
    test: (config) {
      if (![
        'phil',
        'ere',
      ].any((e) => (config.subjects.where((s) => s.abbr == e).firstOrNull?.activeGradesCount ?? 0) >= 2)) {
        return ["Philosophie oder Religion: nicht min. 2 Semester eingebracht."];
      }
      return null;
    },
    reference: "Anlage 5 (5a)",
  ),
  ValidationTest(
    description: "Bringe alle Prüfungsfächer vollständig ein.",
    test: (config) {
      if (!config.allExamSubjects.every((e) => config.subjects.firstWhere((s) => s.abbr == e).activeGradesCount == 4)) {
        return ["Prüfungsfächer nicht vollständig eingebracht."];
      }
      return null;
    },
    reference: "Anlage 5 (5a)",
  ),
  ValidationTest(
    description: "Bringe 44 Halbjahresleistungen ein. (LKs zählen doppelt.)",
    test: (config) {
      int count = 0;
      for (final elem in config.subjects) {
        count += elem.activeGradesCount * ((config.advancedSubjects.contains(elem.abbr)) ? 2 : 1);
      }
      if (count != 44) {
        return ["Nicht 44 Halbjahresleistungen eingebracht. Es fehlen: ${44 - count}"];
      }
      return null;
    },
    reference: "§43 Absatz 2",
  ),
  ValidationTest(
    description: "Bringe max. 7 Halbjahre mit weniger als 5 NP ein.",
    test: (config) {
      final activeGrades = <int>[];
      for (final subject in config.subjects) {
        for (final grade in subject.finalGrades) {
          if (grade.active && grade.value != null) activeGrades.add(grade.value!);
        }
      }
      final gradesBelow5 = activeGrades.where((element) => element < 5).length;
      if (gradesBelow5 > 7) {
        return ["Zu viele Unterpunktungen ($gradesBelow5)."];
      }
      return null;
    },
    reference: "§43 Absatz 2 Satz 3",
  ),
];

List<ValidationTest<TaskStatus>> examSubjectsTests = [
  ValidationTest(
    description: "Deutsch als Prüfungsfach",
    test: (config) {
      if (config.allExamSubjects.contains("de")) return TaskStatus.complete;
      if (config.writtenExamSubject == null ||
          (config.oralExamSubjects.where((t) => t != "").length != 2) ||
          config.advancedSubjects.length != 2) {
        return TaskStatus.unknown;
      }
      return TaskStatus.error;
    },
    reference: "§25 Absatz 5",
  ),
  ValidationTest(
    description: "Mathe als Prüfungsfach",
    test: (config) {
      if (config.allExamSubjects.contains("ma")) return TaskStatus.complete;
      if (config.writtenExamSubject == null ||
          (config.oralExamSubjects.where((t) => t != "").length != 2) ||
          config.advancedSubjects.length != 2) {
        return TaskStatus.unknown;
      }
      return TaskStatus.error;
    },
    reference: "§25 Absatz 5",
  ),
  ValidationTest(
    description: "Gesellschaftswissenschaft als Prüfungsfach",
    test: (config) {
      if (config.allExamSubjects.any((examSub) {
        try {
          if (config.subjects.firstWhere((elem) => elem.abbr == examSub).kind == 'sc') return true;
          return false;
        } catch (_) {
          return false;
        }
      })) {
        return TaskStatus.complete;
      }
      if (config.writtenExamSubject == null ||
          (config.oralExamSubjects.where((t) => t != "").length != 2) ||
          config.advancedSubjects.length != 2) {
        return TaskStatus.unknown;
      }
      return TaskStatus.error;
    },
    reference: "§25 Absatz 5",
  ),
  ValidationTest(
    description: "Ma, De, En, Ge, La oder MINT-Fach als 3. Prüfungsfach",
    test: (config) {
      if (config.writtenExamSubject == null) return TaskStatus.unknown;
      if (["ma", "de", "en", "ge", "la"].contains(config.writtenExamSubject) ||
          config.mintSubjectsStrings.contains(config.writtenExamSubject)) {
        return TaskStatus.complete;
      }
      return TaskStatus.error;
    },
    reference: "§25 Absatz 5",
  ),
  ValidationTest(
    description: "Fortgeführte Fremdsprache oder MINT-Fach (außer Ma) als Prüfungsfach",
    test: (config) {
      if (config.allExamSubjects.any(
        (s) => ["en", "franz", "la", "span"].contains(s) || (config.mintSubjectsStrings..remove("ma")).contains(s),
      )) {
        return TaskStatus.complete;
      }
      if (config.writtenExamSubject == null ||
          (config.oralExamSubjects.where((t) => t != "").length != 2) ||
          config.advancedSubjects.length != 2) {
        return TaskStatus.unknown;
      }
      return TaskStatus.error;
    },
    reference: "§25 Absatz 5",
  ),
];

void chooseOptimal(ALevelWrapper config) {
  for (var subject in config.subjects) {
    for (var grade in subject.finalGrades) {
      grade.active = false;
    }
  }

  for (final sub in config.subjects) {
    // must-include
    if (["ma", "de", "ge"].contains(sub.abbr) || config.allExamSubjects.contains(sub.abbr)) {
      for (var grade in sub.finalGrades) {
        grade.active = true;
      }
    }
  }

  // one foreign language
  List<AbstractSubject> foreignSubjects = config.subjects
      .where((sub) => ['en', 'span', 'franz', 'la'].contains(sub.abbr))
      .toList();
  if (foreignSubjects.isNotEmpty && !foreignSubjects.every((sub) => sub.activeGradesCount == 4)) {
    foreignSubjects.sort((a, b) => b.compareToByAverage(a));
    for (final grade in foreignSubjects.first.finalGrades) {
      grade.active = true;
    }
  }

  // bio, che or phy
  List<AbstractSubject> basicMintSubjects = config.subjects
      .where((sub) => ['bio', 'ch', 'ph'].contains(sub.abbr))
      .toList();
  if (basicMintSubjects.isNotEmpty && !basicMintSubjects.every((sub) => sub.activeGradesCount == 4)) {
    basicMintSubjects.sort((a, b) => b.compareToByAverage(a));
    for (final grade in basicMintSubjects.first.finalGrades) {
      grade.active = true;
    }
  }

  // music or art
  List<AbstractSubject> muOrArtSubjects = config.subjects.where((sub) => ['mu', 'ku'].contains(sub.abbr)).toList();
  if (muOrArtSubjects.isNotEmpty && !muOrArtSubjects.every((sub) => sub.activeGradesCount == 4)) {
    muOrArtSubjects.sort((a, b) => b.compareToByAverage(a));
    var targetSubject = muOrArtSubjects.first;
    var finalGrades = targetSubject.finalGradesDesc;
    targetSubject.finalGrades[finalGrades[0].index].active = true;
    targetSubject.finalGrades[finalGrades[1].index].active = true;
  }

  // rel or phil
  List<AbstractSubject> relOrPhilSubjects = config.subjects.where((sub) => ['ere', 'phil'].contains(sub.abbr)).toList();
  if (relOrPhilSubjects.isNotEmpty && !relOrPhilSubjects.every((sub) => sub.activeGradesCount == 4)) {
    relOrPhilSubjects.sort((a, b) => b.compareToByAverage(a));
    var targetSubject = relOrPhilSubjects.first;
    var finalGrades = targetSubject.finalGradesDesc;
    targetSubject.finalGrades[finalGrades[0].index].active = true;
    targetSubject.finalGrades[finalGrades[1].index].active = true;
  }

  // fill remaining
  var remaining = 44 - config.activeGradesCount;
  List<AbstractFinalGrade> availableGrades =
      [for (final sub in config.subjects) ...sub.finalGradesFilled.where((t) => !t.active)]
        ..sort((a, b) => a.compareToWithAveraged(b))
        ..sort((a, b) => b.compareTo(a));
  for (int i = 0; i < remaining; i++) {
    if (i >= availableGrades.length) break;
    availableGrades[i].active = true;
  }
}
