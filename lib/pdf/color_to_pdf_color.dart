import 'package:flutter/material.dart' show Color;
import 'package:pdf/pdf.dart' show PdfColor;

extension ToPdfColor on Color {
  PdfColor toPdfColor() {
    return PdfColor(red / 256, green / 256, blue / 256);
  }
}
