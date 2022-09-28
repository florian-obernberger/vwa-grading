import 'package:flutter/material.dart' show IconData, Icons;
import 'package:vwa_grading/data/vwa/data_mixin.dart';

/// The [weights] of [presentation] and [discussion] should be counted together!

class QuestionsData with ExportableMixin {
  const QuestionsData({
    required this.written,
    required this.presentation,
    required this.discussion,
  });

  factory QuestionsData.empty() {
    return QuestionsData(
      written: SectionsGroupData(name: "", sections: []),
      presentation: SectionsGroupData(name: "", sections: []),
      discussion: SectionsGroupData(name: "", sections: []),
    );
  }

  final SectionsGroupData written;
  final SectionsGroupData presentation;
  final SectionsGroupData discussion;

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "written": written.toMap(),
      "presentation": presentation.toMap(),
      "discussion": discussion.toMap(),
    };
  }

  @override
  void loadMap(Map<String, dynamic> data) {
    written.loadMap(data["written"]);
    presentation.loadMap(data["presentation"]);
    discussion.loadMap(data["discussion"]);
  }
}

class SectionsGroupData with ExportableMixin {
  SectionsGroupData({required this.name, required this.sections});

  String name;
  List<SectionData> sections;

  bool get hasEmptyFields {
    for (var section in sections) {
      if (section.questions.values.contains(-1)) {
        return true;
      }
    }

    return false;
  }

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  Map<String, dynamic> toMap() {
    return {"name": name, "sections": sections.map((s) => s.toMap()).toList()};
  }

  @override
  void loadMap(Map<String, dynamic> data) {
    name = data["name"];
    sections = [
      for (Map<String, dynamic> section
          in data["sections"] as List<Map<String, dynamic>>)
        SectionData.fromMap(section),
    ];
  }
}

class SectionData {
  SectionData({
    required this.name,
    required this.weight,
    required this.questions,
    IconData? icon,
    IconData? selectedIcon,
  })  : icon = icon ?? Icons.info_outlined,
        selectedIcon = selectedIcon ?? Icons.info;

  factory SectionData.fromMap(Map<String, dynamic> data) {
    return SectionData(
      name: data["name"],
      weight: data["weight"],
      questions: data["questions"].map<String, int>(
        (key, value) => MapEntry(key as String, value as int),
      ),
      icon: data.containsKey("icon")
          ? IconData(
              data["icon"],
              fontFamily: "MaterialIcons",
            )
          : null,
      selectedIcon: data.containsKey("selectedIcon")
          ? IconData(
              data["selectedIcon"],
              fontFamily: "MaterialIcons",
            )
          : null,
    );
  }

  IconData icon;
  IconData selectedIcon;
  String name;
  double weight;
  Map<String, int> questions;

  Map<String, dynamic> toMap() {
    return {"name": name, "weight": weight, "questions": questions};
  }
}
