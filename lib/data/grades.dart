import 'package:vwa_grading/data/vwa/general_info.dart';
import 'package:vwa_grading/data/vwa/section.dart';
import 'package:vwa_grading/extensions/list.dart';
import 'package:vwa_grading/extensions/zip.dart';
import 'package:vwa_grading/state-management/vwa_data.dart';

/// ## Grade overview
///
/// * -1 = no grade provided (yet)
/// * 1 = Sehr gut
/// * 2 = Gut
/// * 3 = Befriedigend
/// * 4 = Genügend
/// * 5 = Nicht genügend
const possibleGrades = [1, 2, 3, 4, 5];

const possibleGradesDescriptions = [
  "Weit über das geforderte Maß hinaus erfüllt",
  "Über das geforderte Maß hinaus erfüllt",
  "Zur Gänze erfüllt",
  "Überwiegend erfüllt",
  "Nicht erfüllt",
];

final possibleGradesMap = {
  for (int i = 0; i < possibleGrades.length; i++)
    possibleGrades[i]: possibleGradesDescriptions[i],
};

double calculateSectionKalkul(SectionData section) {
  final grades = section.questions.values.where((e) => e != -1);
  return grades.sum() / grades.length;
}

double calculateWrittenSectionsGroupKalkul(
  SectionsGroupData written,
  bool isMainDate,
) {
  final weights = written.sections.map((e) => e.weight);
  final sectionGrades = written.sections.map(
    (e) => calculateSectionKalkul(e),
  );

  if (sectionGrades.any((e) => e >= 4.5)) return 5;

  if (isMainDate) {
    return [
      for (var entry in zip2(sectionGrades, weights)) entry.item1 * entry.item2
    ].sum();
  }

  // TODO: Make adaptable and not static
  final grades = sectionGrades.toList();
  return grades[1] * 0.4 + grades[2] * 0.2 + grades[3] * 0.2 + grades[4] * 0.2;
}

double calculateSpokenSectionsGroupKalkul(
  SectionsGroupData presentation,
  SectionsGroupData discussion,
) {
  final sections = [...presentation.sections, ...discussion.sections];

  final weights = sections.map((e) => e.weight);
  final sectionGrades = sections.map(
    (e) => calculateSectionKalkul(e),
  );

  if (sectionGrades.any((e) => e >= 4.5)) return 5;

  return [
    for (var entry in zip2(sectionGrades, weights)) entry.item1 * entry.item2
  ].sum();
}

double calculateKalkul(QuestionsData questions, GeneralInfoData generalInfo) {
  // TODO: Make dates dynamic
  final writtenKalkul = calculateWrittenSectionsGroupKalkul(
    questions.written,
    generalInfo.date == "Haupttermin",
  );
  final spokenKalkul = calculateSpokenSectionsGroupKalkul(
    questions.presentation,
    questions.discussion,
  );

  if (writtenKalkul == 5 || spokenKalkul == 5) return 5;

  if (spokenKalkul.isNaN) {
    //might have written part only
    return writtenKalkul;
  } else {
    return writtenKalkul * 0.7 + spokenKalkul * 0.3;
  }
}
