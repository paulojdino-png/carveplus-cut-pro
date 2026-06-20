import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'nesting_engine.dart';

class DxfExportService {
  static Future<File> exportLayout(List<PlacementPart> parts) async {
    final buffer = StringBuffer();

    buffer.writeln('0');
    buffer.writeln('SECTION');
    buffer.writeln('2');
    buffer.writeln('ENTITIES');
    void addLine(
      StringBuffer buffer,
      double sx,
      double sy,
      double ex,
      double ey,
    ) {
      buffer.writeln('0');
      buffer.writeln('LINE');

      buffer.writeln('8');
      buffer.writeln('0');

      buffer.writeln('10');
      buffer.writeln(sx);

      buffer.writeln('20');
      buffer.writeln(sy);

      buffer.writeln('11');
      buffer.writeln(ex);

      buffer.writeln('21');
      buffer.writeln(ey);
    }

    void addText(
      StringBuffer buffer,
      String text,
      double x,
      double y,
      double height, {
      double rotation = 0,
    }) {
      buffer.writeln('0');
      buffer.writeln('TEXT');

      buffer.writeln('8');
      buffer.writeln('0');

      buffer.writeln('10');
      buffer.writeln(x);

      buffer.writeln('20');
      buffer.writeln(y);

      buffer.writeln('40');
      buffer.writeln(height);

      buffer.writeln('50');
      buffer.writeln(rotation);

      buffer.writeln('72');
      buffer.writeln('1');

      buffer.writeln('73');
      buffer.writeln('2');

      buffer.writeln('11');
      buffer.writeln(x);

      buffer.writeln('21');
      buffer.writeln(y);

      buffer.writeln('1');
      buffer.writeln(text);
    }

    const sheetSpacing = 200.0;
    const sheetWidth = 1220.0;
    const sheetHeight = 2440.0;

    final sheetNumbers = parts.map((p) => p.sheet).toSet().toList();

    for (final sheet in sheetNumbers) {
      final offsetX = (sheet - 1) * (sheetWidth + sheetSpacing);
      addText(
        buffer,
        'SHEET $sheet',
        offsetX + (sheetWidth / 2),
        sheetHeight + 60,
        40,
      );

      addLine(buffer, offsetX, 0, offsetX + sheetWidth, 0);

      addLine(
        buffer,
        offsetX + sheetWidth,
        0,
        offsetX + sheetWidth,
        sheetHeight,
      );

      addLine(buffer, offsetX + sheetWidth, sheetHeight, offsetX, sheetHeight);

      addLine(buffer, offsetX, sheetHeight, offsetX, 0);
    }
    for (final part in parts) {
      final sheetOffsetX = (part.sheet - 1) * (sheetWidth + sheetSpacing);

      final x1 = part.x + sheetOffsetX;
      final y1 = part.y;

      final x2 = x1 + part.width;
      final y2 = y1 + part.height;
      final centerX = x1 + (part.width / 2);
      final centerY = y1 + (part.height / 2);

      final rotateText = part.width < 180 || part.width < (part.height * 0.25);

      addText(
        buffer,
        '${part.name} ${part.width.toInt()}x${part.height.toInt()}',
        centerX,
        centerY,
        20,
        rotation: rotateText ? 90 : 0,
      );

      addLine(buffer, x1, y1, x2, y1);
      addLine(buffer, x2, y1, x2, y2);
      addLine(buffer, x2, y2, x1, y2);
      addLine(buffer, x1, y2, x1, y1);
    }

    buffer.writeln('0');
    buffer.writeln('ENDSEC');

    buffer.writeln('0');
    buffer.writeln('EOF');

    final dir = await getApplicationDocumentsDirectory();

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');

    final file = File('${dir.path}/carveplus_$timestamp.dxf');

    await file.writeAsString(buffer.toString());

    return file;
  }
}
