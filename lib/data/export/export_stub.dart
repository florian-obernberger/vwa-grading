import 'package:vwa_grading/pdf/vwa_beurteilungsraster.dart';

Future<void> exportToml() async {
  throw UnimplementedError("Stub file cannot export");
}

Future<void> exportPdf(VWAExportType type, bool withKalkul) async {
  throw UnimplementedError("Stub file cannot export");
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
  throw UnimplementedError("Stub file cannot import");
}
