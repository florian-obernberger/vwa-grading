import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vwa_grading/data/school_year.dart';
import 'package:vwa_grading/destinations/destinations_mixin.dart';
import 'package:vwa_grading/state-management/vwa_data.dart';

class GeneralInfo extends StatelessWidget with PageSliderDestinationMixin {
  const GeneralInfo({super.key});

  @override
  String get label => "Allgemein";

  @override
  IconData get icon => Icons.description_outlined;

  @override
  IconData get selectedIcon => Icons.description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth <= 900;

        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: textTheme.copyWith(titleMedium: textTheme.bodyLarge),
          ),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: (isMobile
                          ? textTheme.headlineMedium
                          : textTheme.displayMedium)
                      ?.copyWith(color: colorScheme.secondary),
                ),
                const SizedBox(height: 32),
                if (!isMobile) _buildLargeLayout(context),
                if (isMobile) _buildMobileLayout(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final topicController = TextEditingController(
      text: generalInfoProvider.topic,
    );
    final nameController = TextEditingController(
      text: generalInfoProvider.name,
    );
    final teacherController = TextEditingController(
      text: generalInfoProvider.teacher,
    );
    final classController = TextEditingController(
      text: generalInfoProvider.class_,
    );
    final charController = TextEditingController(
      text: generalInfoProvider.char,
    );
    final schoolYears = [
      for (String y in generateSchoolYears())
        DropdownMenuItem<String>(
          value: y,
          child: Text(y),
        )
    ];
    final dates = [
      for (String d in {"Haupttermin", "1. Nebentermin", "2. Nebentermin"})
        DropdownMenuItem<String>(
          value: d,
          child: Text(d),
        )
    ];
    final plagiarism = [
      for (String d in {"Ja", "Nein"})
        DropdownMenuItem<String>(
          value: d,
          child: Text(d),
        )
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          onEditingComplete: FocusScope.of(context).nextFocus,
          decoration: const InputDecoration(labelText: "Thema der VWA"),
          controller: topicController,
          onChanged: (topic) => _handleData(#topic, topic),
        ),
        TextFormField(
          onEditingComplete: FocusScope.of(context).nextFocus,
          decoration: const InputDecoration(labelText: "Schüler*in"),
          controller: nameController,
          onChanged: (student) => _handleData(#student, student),
        ),
        TextFormField(
          onEditingComplete: FocusScope.of(context).nextFocus,
          decoration: const InputDecoration(labelText: "Prüfer*in"),
          controller: teacherController,
          onChanged: (teacher) => _handleData(#teacher, teacher),
        ),
        TextFormField(
          onEditingComplete: FocusScope.of(context).nextFocus,
          decoration: const InputDecoration(labelText: "Klasse"),
          controller: classController,
          onChanged: (class_) => _handleData(const Symbol("class"), class_),
        ),
        TextFormField(
          onEditingComplete: FocusScope.of(context).nextFocus,
          decoration: const InputDecoration(labelText: "Zeichenanzahl"),
          controller: charController,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (char) => _handleData(#char, char),
          // keyboardType: TextInputType.number,
        ),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: "Schuljahr"),
          value: generalInfoProvider.schoolYear.isEmpty
              ? null
              : generalInfoProvider.schoolYear,
          isExpanded: true,
          onChanged: (schoolYear) {
            if (schoolYear == null) return;
            _handleData(#schoolYear, schoolYear);
          },
          items: schoolYears,
        ),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: "Termin"),
          value: generalInfoProvider.date.isEmpty
              ? null
              : generalInfoProvider.date,
          isExpanded: true,
          onChanged: (date) {
            if (date == null) return;
            _handleData(#date, date);
          },
          items: dates,
        ),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: "Plagiatsverdacht"),
          value: generalInfoProvider.plagiarism.isEmpty
              ? null
              : generalInfoProvider.plagiarism,
          isExpanded: true,
          onChanged: (pla) {
            if (pla == null) return;
            _handleData(#plagiarism, pla);
          },
          items: plagiarism,
        ),
      ]
          .map(
            (e) => Padding(padding: const EdgeInsets.all(8), child: e),
          )
          .toList(),
    );
  }

  Widget _buildLargeLayout(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final topicController = TextEditingController(
      text: generalInfoProvider.topic,
    );
    final nameController = TextEditingController(
      text: generalInfoProvider.name,
    );
    final teacherController = TextEditingController(
      text: generalInfoProvider.teacher,
    );
    final classController = TextEditingController(
      text: generalInfoProvider.class_,
    );
    final charController = TextEditingController(
      text: generalInfoProvider.char,
    );
    final schoolYears = [
      for (String y in generateSchoolYears())
        DropdownMenuItem<String>(
          value: y,
          child: Text(y),
        )
    ];
    final dates = [
      for (String d in {"Haupttermin", "1. Nebentermin", "2. Nebentermin"})
        DropdownMenuItem<String>(
          value: d,
          child: Text(d),
        )
    ];
    final plagiarism = [
      for (String d in {"Ja", "Nein"})
        DropdownMenuItem<String>(
          value: d,
          child: Text(d),
        )
    ];

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FractionColumnWidth(0.25),
        1: FractionColumnWidth(0.75)
      },
      children: [
        TableRow(children: [
          Text(
            "Thema der VWA",
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextFormField(
              onEditingComplete: FocusScope.of(context).nextFocus,
              controller: topicController,
              onChanged: (topic) => _handleData(#topic, topic),
            ),
          ),
        ]),
        TableRow(children: [
          Text(
            "Schüler*in",
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextFormField(
              onEditingComplete: FocusScope.of(context).nextFocus,
              controller: nameController,
              onChanged: (student) => _handleData(#student, student),
            ),
          ),
        ]),
        TableRow(children: [
          Text(
            "Prüfer*in",
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextFormField(
              onEditingComplete: FocusScope.of(context).nextFocus,
              controller: teacherController,
              onChanged: (teacher) => _handleData(#teacher, teacher),
            ),
          ),
        ]),
        TableRow(children: [
          Text(
            "Klasse",
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextFormField(
              onEditingComplete: FocusScope.of(context).nextFocus,
              controller: classController,
              onChanged: (class_) => _handleData(const Symbol("class"), class_),
            ),
          ),
        ]),
        TableRow(children: [
          Text(
            "Zeichenanzahl",
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextFormField(
              onEditingComplete: FocusScope.of(context).nextFocus,
              controller: charController,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (char) => _handleData(#char, char),
            ),
          ),
        ]),
        TableRow(children: [
          Text(
            "Schuljahr",
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: DropdownButtonFormField<String>(
              value: generalInfoProvider.schoolYear.isEmpty
                  ? null
                  : generalInfoProvider.schoolYear,
              isExpanded: true,
              onChanged: (schoolYear) {
                if (schoolYear == null) return;
                _handleData(#schoolYear, schoolYear);
              },
              items: schoolYears,
            ),
          ),
        ]),
        TableRow(children: [
          Text(
            "Termin",
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: DropdownButtonFormField<String>(
              value: generalInfoProvider.date.isEmpty
                  ? null
                  : generalInfoProvider.date,
              isExpanded: true,
              onChanged: (date) {
                if (date == null) return;
                _handleData(#date, date);
              },
              items: dates,
            ),
          ),
        ]),
        TableRow(children: [
          Text(
            "Plagiatsverdacht",
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: DropdownButtonFormField<String>(
              value: generalInfoProvider.plagiarism.isEmpty
                  ? null
                  : generalInfoProvider.plagiarism,
              isExpanded: true,
              onChanged: (pla) {
                if (pla == null) return;
                _handleData(#plagiarism, pla);
              },
              items: plagiarism,
            ),
          ),
        ]),
      ],
    );
  }

  void _handleData(Symbol type, String data) {
    switch (type) {
      case #topic:
        generalInfoProvider.topic = data;
        break;
      case #student:
        generalInfoProvider.name = data;
        break;
      case #teacher:
        generalInfoProvider.teacher = data;
        break;
      case Symbol("class"):
        generalInfoProvider.class_ = data;
        break;
      case #char:
        generalInfoProvider.char = data;
        break;
      case #schoolYear:
        generalInfoProvider.schoolYear = data;
        break;
      case #date:
        generalInfoProvider.date = data;
        break;
      case #plagiarism:
        generalInfoProvider.plagiarism = data;
        break;
    }
  }
}
