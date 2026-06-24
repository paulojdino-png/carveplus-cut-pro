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
      double ey, {
      String layer = 'PARTS',
      int color = 7,
    }) {
      buffer.writeln('0');
      buffer.writeln('LINE');

      buffer.writeln('8');
      buffer.writeln(layer);

      buffer.writeln('62');
      buffer.writeln(color);

      buffer.writeln('10');
      buffer.writeln(sx);

      buffer.writeln('20');
      buffer.writeln(sy);

      buffer.writeln('11');
      buffer.writeln(ex);

      buffer.writeln('21');
      buffer.writeln(ey);
    }

    void addDashedLine(
      StringBuffer buffer,
      double x1,
      double y1,
      double x2,
      double y2, {
      String layer = 'EDGE_BAND',
      int color = 1,
    }) {
      const dash = 20.0;
      const gap = 10.0;

      if (y1 == y2) {
        double x = x1;

        while (x < x2) {
          final end = (x + dash > x2) ? x2 : x + dash;

          addLine(buffer, x, y1, end, y2, layer: layer, color: color);

          x += dash + gap;
        }
      } else if (x1 == x2) {
        double y = y1;

        while (y < y2) {
          final end = (y + dash > y2) ? y2 : y + dash;

          addLine(buffer, x1, y, x2, end, layer: layer, color: color);

          y += dash + gap;
        }
      }
    }

    void addText(
      StringBuffer buffer,
      String text,
      double x,
      double y,
      double height, {
      double rotation = 0,
      String layer = 'TEXT',
      int color = 4,
    }) {
      buffer.writeln('0');
      buffer.writeln('TEXT');

      buffer.writeln('8');
      buffer.writeln(layer);

      buffer.writeln('62');
      buffer.writeln(color);

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
        layer: 'SHEETS',
        color: 8,
      );

      addLine(
        buffer,
        offsetX,
        0,
        offsetX + sheetWidth,
        0,
        layer: 'SHEETS',
        color: 8,
      );

      addLine(
        buffer,
        offsetX + sheetWidth,
        0,
        offsetX + sheetWidth,
        sheetHeight,
        layer: 'SHEETS',
        color: 8,
      );

      addLine(
        buffer,
        offsetX + sheetWidth,
        sheetHeight,
        offsetX,
        sheetHeight,
        layer: 'SHEETS',
        color: 8,
      );

      addLine(
        buffer,
        offsetX,
        sheetHeight,
        offsetX,
        0,
        layer: 'SHEETS',
        color: 8,
      );
    }
    for (final part in parts) {
      final sheetOffsetX = (part.sheet - 1) * (sheetWidth + sheetSpacing);

      final x1 = part.x + sheetOffsetX;

      final y1 = sheetHeight - part.y - part.height;

      final x2 = x1 + part.width;
      final y2 = y1 + part.height;
      final centerX = x1 + (part.width / 2);
      final centerY = y1 + (part.height / 2);

      final rotateText = part.width < 180 || part.width < (part.height * 0.25);

      addText(
        buffer,
        part.code,
        centerX,
        centerY,
        20,
        rotation: rotateText ? 90 : 0,
        layer: 'TEXT',
        color: 4,
      );

      addLine(buffer, x1, y1, x2, y1, layer: 'PARTS');

      addLine(buffer, x2, y1, x2, y2, layer: 'PARTS');

      addLine(buffer, x2, y2, x1, y2, layer: 'PARTS');

      addLine(buffer, x1, y2, x1, y1, layer: 'PARTS');
      bool topEdge = part.topEdge;
      bool rightEdge = part.rightEdge;
      bool bottomEdge = part.bottomEdge;
      bool leftEdge = part.leftEdge;

      if (part.rotated) {
        final oldTop = topEdge;
        final oldRight = rightEdge;
        final oldBottom = bottomEdge;
        final oldLeft = leftEdge;

        topEdge = oldLeft;
        rightEdge = oldTop;
        bottomEdge = oldRight;
        leftEdge = oldBottom;
      }
      const edgeOffset = 5.0;

      if (topEdge) {
        addDashedLine(
          buffer,
          x1 + edgeOffset,
          y1 + edgeOffset,
          x2 - edgeOffset,
          y1 + edgeOffset,
        );
      }

      if (bottomEdge) {
        addDashedLine(
          buffer,
          x1 + edgeOffset,
          y2 - edgeOffset,
          x2 - edgeOffset,
          y2 - edgeOffset,
        );
      }

      if (leftEdge) {
        addDashedLine(
          buffer,
          x1 + edgeOffset,
          y1 + edgeOffset,
          x1 + edgeOffset,
          y2 - edgeOffset,
        );
      }

      if (rightEdge) {
        addDashedLine(
          buffer,
          x2 - edgeOffset,
          y1 + edgeOffset,
          x2 - edgeOffset,
          y2 - edgeOffset,
        );
      }
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
