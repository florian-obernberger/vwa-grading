// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:convert';

void webExportToml(List<int> bytes) {
  AnchorElement(
    href:
        "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}",
  )
    ..setAttribute("download", "vwa-benotung.vwa")
    ..click();
}
