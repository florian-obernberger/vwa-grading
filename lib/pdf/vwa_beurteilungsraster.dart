import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:flutter/services.dart' as services;
import 'package:vwa_grading/data/grades.dart';
import 'package:vwa_grading/data/vwa/section.dart';
import 'package:vwa_grading/state-management/vwa_data.dart';
import 'package:vwa_grading/theme/number_formatter.dart';

late TextStyle _defaultTextStyle;
final _primary = PdfColor.fromHex("3B5BA9");
final _onMain = PdfColor.fromHex("FFFFFF");
final _secondary = PdfColor.fromHex("585E71");
final _tertiary = PdfColor.fromHex("#735471");
final _outline = PdfColor.fromHex("#757780");

enum VWAExportType {
  pdfWritten,
  pdfSpoken,
  pdfTotal,
  toml,
}

class VWAPrintNaNException implements Exception {}

Future<Document> generateVWABeurteilungsraster(
  VWAExportType printStyle,
  bool printKalkul,
) async {
  final pdf = Document();

  final fontData = await services.rootBundle.load(
    "assets/fonts/noto-regular.ttf",
  );

  final ttf = Font.ttf(fontData.buffer.asByteData());
  _defaultTextStyle = TextStyle(font: ttf, fontSize: 6);

  if (printStyle == VWAExportType.pdfTotal) {
    pdf.addPage(_createPage(VWAExportType.pdfWritten, printKalkul));
    pdf.addPage(_createPage(VWAExportType.pdfSpoken, printKalkul, false));
  } else {
    pdf.addPage(_createPage(printStyle, printKalkul));
  }

  return pdf;
}

Page _createPage(
  VWAExportType printStyle,
  bool printKalkul, [
  bool includeInfo = true,
]) {
  return Page(
    pageTheme: PageTheme(
      theme: ThemeData(defaultTextStyle: _defaultTextStyle),
      // margin: const EdgeInsets.all(40),
      pageFormat: PdfPageFormat.a4,
    ),
    build: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Beurteilungsraster für die VWA",
            style: _defaultTextStyle.copyWith(
              color: _primary,
              fontSize: 11,
            ),
          ),
          if (includeInfo) SizedBox(height: 8),
          if (includeInfo) _genralInfo(),
          SizedBox(height: 8),
          if (printStyle == VWAExportType.pdfWritten)
            ..._buildSection(questionsProvider.written, printKalkul),
          if (printStyle == VWAExportType.pdfSpoken)
            ..._buildSection(questionsProvider.presentation, printKalkul),
          if (printStyle == VWAExportType.pdfSpoken)
            ..._buildSection(questionsProvider.discussion, printKalkul),
          if (printKalkul) ..._buildKalkul()
        ],
      );
    },
  );
}

List<Widget> _buildKalkul() {
  final style = _defaultTextStyle.copyWith(fontSize: 8);
  final kalkul = calculateKalkul(questionsProvider, generalInfoProvider);
  final kalkulString = kalkul.isNaN ? "" : kalkulFormatter.format(kalkul);

  return [
    SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Text(
          "Vorläufiges Kalkül: $kalkulString",
          textAlign: TextAlign.right,
          style: style,
        ),
      ),
    ),
    SizedBox(height: 48),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: _outline, width: 0.5),
              ),
            ),
            child: Text("Ort, Datum", style: style),
          ),
        ),
        SizedBox(width: 24),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: _outline, width: 0.5),
              ),
            ),
            child: Text("Unterschrift Prüfer*in", style: style),
          ),
        ),
      ],
    ),
  ];
}

String _calcSectionKalkul(SectionData section) {
  final kalkul = calculateSectionKalkul(section);
  if (kalkul.isNaN) {
    return "";
  }
  return kalkulFormatter.format(calculateSectionKalkul(section));
}

List<Widget> _buildSection(SectionsGroupData sectionsGroup, bool printKalkul) {
  const padding = EdgeInsets.all(1);

  final spacer = TableRow(children: [
    SizedBox(height: 4),
  ]);

  return [
    Text(
      sectionsGroup.name,
      style: _defaultTextStyle.copyWith(fontSize: 8, color: _secondary),
    ),
    for (var section in sectionsGroup.sections) ...[
      Table(
        border: TableBorder.all(color: _outline, width: 0.5),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FractionColumnWidth(0.7),
          1: FractionColumnWidth(0.3)
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: _secondary),
            children: [
              Text(
                section.name,
                style: _defaultTextStyle.copyWith(
                  fontSize: 7,
                  color: _onMain,
                ),
              ),
              if (printKalkul)
                Text(
                  "Kalkül: ${_calcSectionKalkul(section)}",
                  style: _defaultTextStyle.copyWith(
                    fontSize: 7,
                    color: _onMain,
                  ),
                ),
            ].map((e) => Padding(padding: padding, child: e)).toList(),
          ),
          TableRow(
            children: [
              Text("Der*Die Prüfungskandidat*in..."),
            ].map((e) => Padding(padding: padding, child: e)).toList(),
          ),
          for (var question in section.questions.entries)
            TableRow(
              children: [
                Text(question.key),
                Text(
                  question.value == -1
                      ? ""
                      : possibleGradesMap[question.value]!,
                ),
              ].map((e) => Padding(padding: padding, child: e)).toList(),
            ),
          // spacer,
        ],
      ),
      spacer.children.first,
    ],
  ];
}

Widget _genralInfo() {
  const padding = EdgeInsets.all(2);

  return Table(
    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
    columnWidths: const {
      0: FractionColumnWidth(0.2),
      1: FractionColumnWidth(0.8)
    },
    children: [
      TableRow(children: [
        Text("Thema der VWA"),
        Padding(
          padding: padding,
          child: Text(generalInfoProvider.topic),
        ),
      ]),
      TableRow(children: [
        Text("Schüler*in"),
        Padding(
          padding: padding,
          child: Text(generalInfoProvider.name),
        ),
      ]),
      TableRow(children: [
        Text("Prüfer*in"),
        Padding(
          padding: padding,
          child: Text(generalInfoProvider.teacher),
        ),
      ]),
      TableRow(children: [
        Text("Klasse"),
        Padding(
          padding: padding,
          child: Text(generalInfoProvider.class_),
        ),
      ]),
      TableRow(children: [
        Text("Zeichenanzahl"),
        Padding(
          padding: padding,
          child: Text(
            int.tryParse(generalInfoProvider.char) == null
                ? generalInfoProvider.char
                : charFormatter.format(
                    int.parse(generalInfoProvider.char),
                  ),
          ),
        ),
      ]),
      TableRow(children: [
        Text("Schuljahr"),
        Padding(
          padding: padding,
          child: Text(generalInfoProvider.schoolYear),
        ),
      ]),
      TableRow(children: [
        Text("Termin"),
        Padding(
          padding: padding,
          child: Text(generalInfoProvider.date),
        ),
      ]),
      TableRow(children: [
        Text("Plagiatsverdacht"),
        Padding(
          padding: padding,
          child: Text(generalInfoProvider.plagiarism),
        ),
      ]),
    ],
  );
}
