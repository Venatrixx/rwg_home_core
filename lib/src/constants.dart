final List<String> allowedGradeValuesSek1 = [
  "1+",
  "1",
  "1-",
  "2+",
  "2",
  "2-",
  "3+",
  "3",
  "3-",
  "4+",
  "4",
  "4-",
  "5+",
  "5",
  "5-",
  "6",
];

final List<String> allowedGradeValuesSek2 = [
  "0",
  "1",
  "2",
  "3",
  "4",
  "5",
  "6",
  "7",
  "8",
  "9",
  "10",
  "11",
  "12",
  "13",
  "14",
  "15",
];

final List<String> allowedGradeValues = [...allowedGradeValuesSek1, ...allowedGradeValuesSek2];

final Duration shortTimeoutDuration = Duration(seconds: 4);

final Duration longTimeoutDuration = Duration(seconds: 7);
