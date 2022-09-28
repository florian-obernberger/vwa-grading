import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vwa_grading/data/grades.dart';
import 'package:vwa_grading/data/vwa/section.dart';
import 'package:vwa_grading/destinations/destinations_mixin.dart';

class QuestionsSection extends StatefulWidget with PageSliderDestinationMixin {
  const QuestionsSection({
    required this.groupName,
    required this.section,
    super.key,
  });

  @override
  IconData get icon => section.icon;

  @override
  IconData get selectedIcon => section.selectedIcon;

  final String groupName;
  final SectionData section;

  @override
  String get label => section.name;

  @override
  State<QuestionsSection> createState() => _QuestionsSectionState();
}

class _QuestionsSectionState extends State<QuestionsSection> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final controllers = {
      for (MapEntry<String, int> question in widget.section.questions.entries)
        question.key: TextEditingController(
          text: question.value == -1 ? null : question.value.toString(),
        ),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth <= 700;

        return Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${widget.groupName} – ${widget.section.name}",
                maxLines: 2,
                style: (isMobile
                        ? textTheme.headlineMedium
                        : textTheme.displayMedium)
                    ?.copyWith(color: colorScheme.secondary),
              ),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Der*Die Schüler*in ...", style: textTheme.titleLarge),
                  IconButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Benotung"),
                        content: Text([
                          for (int i = 0; i < possibleGrades.length; i++)
                            "${possibleGrades[i]} = ${possibleGradesDescriptions[i]}"
                        ].join("\n")),
                        actions: [
                          TextButton(
                            onPressed: Navigator.of(context).pop,
                            child: const Text("Okay"),
                          )
                        ],
                      ),
                    ),
                    icon: const Icon(Icons.info_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!isMobile) _buildLargeLayout(controllers),
              if (isMobile) _buildMobileLayout(controllers),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(Map<String, TextEditingController> controllers) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FractionColumnWidth(0.85),
        1: FractionColumnWidth(0.15)
      },
      children: [
        for (var line in controllers.entries)
          TableRow(children: [
            Text(
              line.key,
              style:
                  textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: DropdownButtonFormField<int>(
                items: [
                  for (int grade in possibleGrades)
                    DropdownMenuItem(
                      value: grade,
                      child: Text(grade.toString()),
                    )
                ],
                onChanged: (v) {
                  if (v == null) return;

                  widget.section.questions[line.key] = v;
                },
              ),
            ),
          ]),
      ],
    );
  }

  Widget _buildLargeLayout(Map<String, TextEditingController> controllers) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FractionColumnWidth(0.9),
        1: FractionColumnWidth(0.1)
      },
      children: [
        for (var line in controllers.entries)
          TableRow(children: [
            Text(
              line.key,
              style:
                  textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8),
              child: TextFormField(
                onEditingComplete: FocusScope.of(context).nextFocus,
                controller: line.value,
                maxLength: 1,
                maxLengthEnforcement:
                    MaxLengthEnforcement.truncateAfterCompositionEnds,
                decoration: const InputDecoration(counterText: ""),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(possibleGrades.toString().replaceAll(", ", "")),
                  )
                ],
                onChanged: (v) {
                  final parsed = int.tryParse(v);
                  if (parsed == null) return;

                  widget.section.questions[line.key] = parsed;
                },
              ),
            ),
          ]),
      ],
    );
  }
}
