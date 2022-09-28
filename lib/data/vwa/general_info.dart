import 'package:vwa_grading/data/vwa/data_mixin.dart';

class GeneralInfoData with ExportableMixin {
  GeneralInfoData({
    required this.topic,
    required this.name,
    required this.teacher,
    required this.class_,
    required this.char,
    required this.schoolYear,
    required this.date,
    required this.plagiarism,
  });

  factory GeneralInfoData.empty() {
    return GeneralInfoData(
      topic: "",
      name: "",
      teacher: "",
      class_: "",
      char: "",
      schoolYear: "",
      date: "",
      plagiarism: "",
    );
  }

  String topic;
  String name;
  String teacher;
  String class_;
  String char;
  String schoolYear;
  String date;
  String plagiarism;

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  void loadMap(Map<String, dynamic> data) {
    topic = data["topic"] as String;
    name = data["name"] as String;
    teacher = data["teacher"] as String;
    class_ = data["class"] as String;
    char = data["char"] as String;
    schoolYear = data["school"] as String;
    date = data["date"] as String;
    plagiarism = data["plagiarism"] as String;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "topic": topic,
      "name": name,
      "teacher": teacher,
      "class": class_,
      "char": char,
      "school": schoolYear,
      "date": date,
      "plagiarism": plagiarism,
    };
  }
}
