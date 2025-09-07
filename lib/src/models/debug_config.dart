import 'package:rwg_home_core/rwg_home_core.dart';
import 'package:rwg_home_core/src/hip/hip_lesson.dart';
import 'package:rwg_home_core/src/schedule/vp_time.dart';

class DebugConfig {
  bool sek1;

  String userClass;
  int level;

  List<String> lessonIds;

  DebugConfig({this.sek1 = false})
    : userClass = sek1 ? "9A" : "11D",
      level = sek1 ? 9 : 11,
      lessonIds = List.generate(9, (i) => (i + 1).toString());

  HipWrapper get hip => HipWrapper(
    semesters: [
      Semester(
        label: sek1 ? "9.1" : "11.1",
        level: sek1 ? 9 : 11,
        subjects: [
          Subject(
            name: 'Deutsch',
            abbr: 'De',
            onlineGrades: [
              Grade.empty(key: '1')
                ..pointsValue = 7
                ..seen = true
                ..uploadDate = DateTime(2025, 7, 14),
              Grade.empty(key: '2')
                ..pointsValue = 8
                ..seen = true
                ..uploadDate = DateTime(2025, 7, 16),
              Grade.empty(key: '3')
                ..pointsValue = 6
                ..seen = true
                ..uploadDate = DateTime(2025, 7, 22),
              Grade.empty(key: '4', isExam: true)
                ..pointsValue = 6
                ..description = "Klausur Klassik"
                ..seen = true
                ..uploadDate = DateTime(2025, 7, 24),
            ],
            customGrades: [
              Grade.empty(key: '1234567890')
                ..pointsValue = 8
                ..seen = true,
            ],
          ),
          Subject(
            name: 'Englisch',
            abbr: 'En',
            onlineGrades: [
              Grade.empty(key: '1')
                ..pointsValue = 14
                ..description = "Vocab test"
                ..seen = true
                ..uploadDate = DateTime(2025, 7, 15),
              Grade.empty(key: '2')
                ..pointsValue = 10
                ..seen = true
                ..uploadDate = DateTime(2025, 7, 17),
              Grade.empty(key: '3')
                ..pointsValue = 11
                ..seen = true
                ..uploadDate = DateTime(2025, 7, 23),
              Grade.empty(key: '4', isExam: true)
                ..pointsValue = 9
                ..seen = true
                ..uploadDate = DateTime(2025, 7, 25),
            ],
          ),
          Subject(name: 'Mathematik', abbr: 'Ma', onlineGrades: []),
          Subject(name: 'Geschichte und Politische Bildung', abbr: 'Ge', onlineGrades: []),
          Subject(name: 'Physik', abbr: 'Ph', onlineGrades: []),
          Subject(name: 'Chemie', abbr: 'Ch', onlineGrades: []),
          Subject(name: 'Musik', abbr: 'Mu', onlineGrades: []),
          Subject(name: 'Philosophie', abbr: 'Phil', onlineGrades: []),
          Subject(name: 'Sport', abbr: 'Sp', onlineGrades: []),
        ],
      ),
      Semester(
        label: sek1 ? "9.2" : "11.2",
        level: sek1 ? 9 : 11,
        subjects: [
          Subject(
            name: 'Deutsch',
            abbr: 'De',
            onlineGrades: [
              Grade.empty(key: '1')
                ..pointsValue = 14
                ..seen = true
                ..uploadDate = DateTime(2025, 7, 14),
              Grade.empty(key: '2')
                ..pointsValue = 10
                ..seen = true
                ..uploadDate = DateTime(2025, 7, 16),
              Grade.empty(key: '3')
                ..pointsValue = 12
                ..seen = true
                ..uploadDate = DateTime(2025, 7, 22),
              Grade.empty(key: '4', isExam: true)
                ..pointsValue = 6
                ..description = "Klausur Klassik"
                ..seen = true
                ..uploadDate = DateTime(2025, 7, 24),
            ],
          ),
          Subject(name: 'Englisch', abbr: 'En', onlineGrades: []),
          Subject(name: 'Mathematik', abbr: 'Ma', onlineGrades: []),
          Subject(name: 'Geschichte und Politische Bildung', abbr: 'Ge', onlineGrades: []),
          Subject(name: 'Physik', abbr: 'Ph', onlineGrades: []),
          Subject(name: 'Chemie', abbr: 'Ch', onlineGrades: []),
          Subject(name: 'Musik', abbr: 'Mu', onlineGrades: []),
          Subject(name: 'Philosophie', abbr: 'Phil', onlineGrades: []),
          Subject(name: 'Sport', abbr: 'Sp', onlineGrades: []),
        ],
      ),
      if (!sek1)
        Semester(
          label: "12.1",
          level: 12,
          subjects: [
            Subject(name: 'Deutsch', abbr: 'De', onlineGrades: []),
            Subject(name: 'Englisch', abbr: 'En', onlineGrades: []),
            Subject(name: 'Mathematik', abbr: 'Ma', onlineGrades: []),
            Subject(name: 'Geschichte und Politische Bildung', abbr: 'Ge', onlineGrades: []),
            Subject(name: 'Physik', abbr: 'Ph', onlineGrades: []),
            Subject(name: 'Chemie', abbr: 'Ch', onlineGrades: []),
            Subject(name: 'Musik', abbr: 'Mu', onlineGrades: []),
            Subject(name: 'Philosophie', abbr: 'Phil', onlineGrades: []),
            Subject(name: 'Sport', abbr: 'Sp', onlineGrades: []),
          ],
        ),
      if (!sek1)
        Semester(
          label: "12.2",
          level: 12,
          subjects: [
            Subject(name: 'Deutsch', abbr: 'De', onlineGrades: []),
            Subject(name: 'Englisch', abbr: 'En', onlineGrades: []),
            Subject(name: 'Mathematik', abbr: 'Ma', onlineGrades: []),
            Subject(name: 'Geschichte und Politische Bildung', abbr: 'Ge', onlineGrades: []),
            Subject(name: 'Physik', abbr: 'Ph', onlineGrades: []),
            Subject(name: 'Chemie', abbr: 'Ch', onlineGrades: []),
            Subject(name: 'Musik', abbr: 'Mu', onlineGrades: []),
            Subject(name: 'Philosophie', abbr: 'Phil', onlineGrades: []),
            Subject(name: 'Sport', abbr: 'Sp', onlineGrades: []),
          ],
        ),
    ],

    totalMissingDays: 12,
    totalMissingHours: 4,
    totalUnexcusedMissingDays: 1,
    totalUnexcusedMissingHours: 0,
    missingHourData: [
      MissingHour(date: DateTime(2025, 7, 10), term: "2. HJ", lessons: "3 Std", subject: "Mathematik", excused: false),
      MissingHour(date: DateTime(2025, 7, 2), term: "2. HJ", excused: true),
      MissingHour(date: DateTime(2025, 7, 9), term: "2. HJ", lessons: "2 Std", subject: "Deutsch"),
    ],

    lastLessons: [
      HipLesson(date: DateTime(2025, 7, 25), lesson: Range(from: 5), subject: 'Englisch', topic: 'British English'),
      HipLesson(date: DateTime(2025, 7, 25), lesson: Range(from: 3, to: 4), subject: 'Sport', topic: 'Volleyball'),
      HipLesson(date: DateTime(2025, 7, 24), lesson: Range(from: 1, to: 2), subject: 'Mathematik', topic: 'Analysis'),
      HipLesson(
        date: DateTime(2025, 7, 21),
        lesson: Range(from: 5, to: 6),
        subject: 'Mathematik',
        topic: 'Analysis',
        homework: "LB.S.50/3",
        type: 'Hausaufgabe',
      ),
      HipLesson(date: DateTime(2025, 7, 23), lesson: Range(from: 6), subject: 'Deutsch', topic: 'Faust'),
    ],
    forgottenHomework: [
      HipLesson(
        date: DateTime(2025, 7, 24),
        lesson: Range(from: 1),
        subject: 'Mathematik',
        comment: 'Buchaufgabe vergessen',
      ),
    ],
  )..loadingState = LoadingState.done;

  ScheduleWrapper get schedule => ScheduleWrapper(
    vpCache: {
      '20250825': VPWrapper(
        date: DateTime(2025, 7, 25),
        lastUpdate: DateTime(2025, 7, 25, 11, 50),
        classes: [
          VPClass(
            name: userClass,
            times: [
              VPTime(lesson: 1, startHour: 8, startMinute: 0, endHour: 8, endMinute: 45),
              VPTime(lesson: 2, startHour: 8, startMinute: 45, endHour: 9, endMinute: 30),
              VPTime(lesson: 3, startHour: 9, startMinute: 50, endHour: 10, endMinute: 35),
              VPTime(lesson: 4, startHour: 10, startMinute: 35, endHour: 11, endMinute: 20),
              VPTime(lesson: 5, startHour: 12, startMinute: 0, endHour: 12, endMinute: 45),
              VPTime(lesson: 6, startHour: 12, startMinute: 50, endHour: 13, endMinute: 35),
              VPTime(lesson: 7, startHour: 13, startMinute: 40, endHour: 14, endMinute: 25),
              VPTime(lesson: 8, startHour: 14, startMinute: 30, endHour: 15, endMinute: 15),
              VPTime(lesson: 9, startHour: 15, startMinute: 15, endHour: 16, endMinute: 0),
            ],
            subjects: [
              VPSubject(label: 'de', teacher: 'Me.D', id: 1),
              VPSubject(label: 'ma', teacher: 'Se.I', id: 2),
              VPSubject(label: 'en', teacher: 'Dr.A', id: 3),
              VPSubject(label: 'ge', teacher: 'Me.D', id: 4),
              VPSubject(label: 'ph', teacher: 'Ul.P', id: 5),
              VPSubject(label: 'ch', teacher: 'Er.E', id: 6),
              VPSubject(label: 'mu', teacher: 'Me.D', id: 7),
              VPSubject(label: 'phil', teacher: 'Le.R', id: 8),
              VPSubject(label: 'sp', teacher: 'So.G', id: 9),
            ],
            lessons: [
              VPLesson(hour: 3, subjectLabel: 'sp', teacher: 'So.G', room: 'J1', id: 9),
              VPLesson(hour: 4, subjectLabel: 'sp', teacher: 'So.G', room: 'J1', id: 9),
              VPLesson(hour: 6, subjectLabel: 'en', teacher: 'Dr.A', room: 'A201', id: 3, hasChangedTeacher: true),
            ],
          ),
        ],
      ),
      '20250824': VPWrapper(
        date: DateTime(2025, 7, 25),
        lastUpdate: DateTime(2025, 7, 25, 11, 50),
        classes: [
          VPClass(
            name: userClass,
            times: [
              VPTime(lesson: 1, startHour: 8, startMinute: 0, endHour: 8, endMinute: 45),
              VPTime(lesson: 2, startHour: 8, startMinute: 45, endHour: 9, endMinute: 30),
              VPTime(lesson: 3, startHour: 9, startMinute: 50, endHour: 10, endMinute: 35),
              VPTime(lesson: 4, startHour: 10, startMinute: 35, endHour: 11, endMinute: 20),
              VPTime(lesson: 5, startHour: 12, startMinute: 0, endHour: 12, endMinute: 45),
              VPTime(lesson: 6, startHour: 12, startMinute: 50, endHour: 13, endMinute: 35),
              VPTime(lesson: 7, startHour: 13, startMinute: 40, endHour: 14, endMinute: 25),
              VPTime(lesson: 8, startHour: 14, startMinute: 30, endHour: 15, endMinute: 15),
              VPTime(lesson: 9, startHour: 15, startMinute: 15, endHour: 16, endMinute: 0),
            ],
            subjects: [
              VPSubject(label: 'de', teacher: 'Me.D', id: 1),
              VPSubject(label: 'ma', teacher: 'Se.I', id: 2),
              VPSubject(label: 'en', teacher: 'Dr.A', id: 3),
              VPSubject(label: 'ge', teacher: 'Me.D', id: 4),
              VPSubject(label: 'ph', teacher: 'Ul.P', id: 5),
              VPSubject(label: 'ch', teacher: 'Er.E', id: 6),
              VPSubject(label: 'mu', teacher: 'Me.D', id: 7),
              VPSubject(label: 'phil', teacher: 'Le.R', id: 8),
              VPSubject(label: 'sp', teacher: 'So.G', id: 9),
            ],
            lessons: [
              VPLesson(hour: 1, subjectLabel: 'ma', teacher: 'Se.I', room: 'B305', id: 2),
              VPLesson(hour: 2, subjectLabel: 'ma', teacher: 'Se.I', room: 'B305', id: 2),
              VPLesson(hour: 3, subjectLabel: 'ge', teacher: 'Me.D', room: 'A108', id: 4, hasChangedRoom: true),
              VPLesson(
                hour: 5,
                subjectLabel: 'mu',
                teacher: 'Me.D',
                room: 'C200',
                id: 7,
                comment: 'für Philosophie Herr Lehmann',
                hasChangedRoom: true,
                hasChangedSubject: true,
                hasChangedTeacher: true,
              ),
            ],
          ),
        ],
      ),
    },
  )..loadingState = LoadingState.done;

  CalendarWrapper get calendar => CalendarWrapper(
    events: [
      Event(EventType.event, "Letzter Schultag", DateTime(2025, 7, 25)),
      Event(EventType.exam, "Deutsch Klausur", DateTime(2025, 7, 24)),
      Event(EventType.test, "Vokabeltest", DateTime(2025, 7, 15), location: '4. Std', comment: "Unit A"),
    ],
  )..loadingState = LoadingState.done;
}
