import 'package:flutter/material.dart';
import 'package:vwa_grading/data/toast_messages.dart';
import 'package:vwa_grading/destinations/destinations_mixin.dart';

import 'package:vwa_grading/data/export/export_stub.dart'
    if (dart.library.io) 'package:vwa_grading/data/export/export.dart'
    if (dart.library.html) 'package:vwa_grading/data/export/export_web.dart';
import 'package:vwa_grading/pdf/vwa_beurteilungsraster.dart';

class EndWrittenPart extends StatelessWidget with PageSliderDestinationMixin {
  const EndWrittenPart({super.key});

  @override
  IconData get icon => Icons.picture_as_pdf_outlined;

  @override
  IconData get selectedIcon => Icons.picture_as_pdf;

  @override
  String get label => "Überblick";

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth <= 900;

        return Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                label,
                style: (isMobile
                        ? textTheme.headlineMedium
                        : textTheme.displayMedium)
                    ?.copyWith(color: colorScheme.secondary),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 224),
                child: Text(
                  "Es wurden alle Fragen zum schriftlichen Teil der Arbeit ausgefüllt. Als nächstes kommen die Fragen zur Präsentation und Diskussion.",
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 96),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: () => exportToml().then(
                      (_) => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          duration: Duration(seconds: 2),
                          dismissDirection: DismissDirection.horizontal,
                          margin: EdgeInsets.fromLTRB(24, 8, 24, 18),
                          content: Text(ToastMessages.savedChanges),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text("Zwischenspeichern"),
                  ),
                  SizedBox(width: isMobile ? 8 : 16),
                  FilledButton.icon(
                    onPressed: () async {
                      final withKalkul = await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                          title: const Text("PDF Export"),
                          content:
                              const Text("Soll das Kalkül berechnet werden?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("Ja"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Nein"),
                            ),
                          ],
                        ),
                      );

                      if (withKalkul == null) return;

                      exportPdf(VWAExportType.pdfWritten, withKalkul).then(
                        (_) => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            duration: Duration(seconds: 2),
                            dismissDirection: DismissDirection.horizontal,
                            margin: EdgeInsets.fromLTRB(24, 8, 24, 18),
                            content: Text(ToastMessages.exportedPdf),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.file_download_outlined),
                    label: const Text("PDF exportieren"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
