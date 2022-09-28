import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:toml/toml.dart';
import 'package:path/path.dart' as path;
import 'package:vwa_grading/pdf/vwa_beurteilungsraster.dart';
import 'package:vwa_grading/state-management/vwa_data.dart';

Future<void> exportToml() async {
  final document = TomlDocument.fromMap({
    "general_info": generalInfoProvider.toMap(),
    "questions": questionsProvider.toMap(),
  });

  final file = await _pickFile("vwa");
  if (file == null) return;

  await file.writeAsString(document.toString());
}

Future<void> exportPdf(VWAExportType type, bool withKalkul) async {
  final pdf = await generateVWABeurteilungsraster(type, withKalkul);
  final bytes = await pdf.save();

  final file = await _pickFile("pdf");
  if (file == null) return;

  await file.writeAsBytes(bytes);
}

Future<File?> _pickFile(String fileEnding) async {
  late final File file;

  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    final result = await FilePicker.platform.saveFile(
      lockParentWindow: true,
      fileName: "vwa-benotung.$fileEnding",
      allowedExtensions: [fileEnding],
      type: FileType.custom,
    );

    if (result == null) return null;

    file = File(result);
    await file.create(recursive: true);
    return file;
  } else {
    final result = await FilePicker.platform.getDirectoryPath(
      lockParentWindow: true,
    );
    if (result == null) return null;

    file = File(path.join(result, "vwa-benotung.$fileEnding"));
  }

  await file.create(recursive: true);
  return file;
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
    lockParentWindow: true,
    allowMultiple: false,
    allowedExtensions: ["vwa", "toml"],
    type: FileType.custom,
  );

  if (result == null) {
    return const ImportResult(ImportStatus.cancelled, "");
  }

  final fileName = result.files.first.name;
  late final Uint8List bytes;

  try {
    bytes = await File(result.files.first.path!).readAsBytes();
  } catch (_) {
    return ImportResult(ImportStatus.openError, fileName);
  }

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
