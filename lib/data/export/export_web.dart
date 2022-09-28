import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:toml/toml.dart';
import 'package:download/download.dart';
import 'package:vwa_grading/pdf/vwa_beurteilungsraster.dart';
import 'package:vwa_grading/state-management/vwa_data.dart';

Future<void> exportToml() async {
  final document = TomlDocument.fromMap({
    "general_info": generalInfoProvider.toMap(),
    "questions": questionsProvider.toMap(),
  });

  final bytes = utf8.encode(document.toString());

  final stream = Stream.fromIterable(bytes);
  download(stream, "vwa-benotung.vwa");
}

Future<void> exportPdf(VWAExportType type, bool withKalkul) async {
  final pdf = await generateVWABeurteilungsraster(type, withKalkul);
  final bytes = await pdf.save();

  final stream = Stream.fromIterable(bytes);
  download(stream, "vwa-benotung.pdf");
}

enum ImportStatus {
  cancelled,
  openError,
  parseError,
  readError,
  noIssues,
}

class ImportResult {
  const ImportResult(this.status, this.fileName);

  final ImportStatus status;
  final String fileName;
}

Future<ImportResult> importToml() async {
  final result = await FilePicker.platform.pickFiles(
    withData: true,
    lockParentWindow: true,
    allowMultiple: false,
    allowedExtensions: ["vwa", "toml"],
    type: FileType.custom,
  );

  if (result == null) {
    return const ImportResult(ImportStatus.cancelled, "");
  }

  final fileName = result.files.first.name;
  final bytes = result.files.first.bytes!;

  final tomlResult = TomlDocument.parser.parse(utf8.decode(bytes));
  if (tomlResult.isFailure) {
    return ImportResult(ImportStatus.parseError, fileName);
  }

  final map = tomlResult.value.toMap();
  try {
    generalInfoProvider.loadMap(map["general_info"]);
    questionsProvider.loadMap(map["questions"]);
  } catch (_) {
    return ImportResult(ImportStatus.readError, fileName);
  }

  return ImportResult(ImportStatus.noIssues, fileName);
}
