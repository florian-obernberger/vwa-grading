class ToastMessages {
  const ToastMessages._();

  static String couldntOpenFile(String fileName) =>
      "Die Datei „$fileName“ konnte nicht geöffnet werden";
  static String couldntLoadFile(String fileName) =>
      "Die Datei „$fileName“ konnte nicht geladen werden";
  static String couldntReadFile(String fileName) =>
      "Die Datei „$fileName“ konnte nicht gelesen werden";
  static String importedFile(String fileName) => "Datei „$fileName“ importiert";
  static const String savedChanges = "Datei zwischengespeichert";
  static const String exportedPdf = "PDF exportiert";
}
