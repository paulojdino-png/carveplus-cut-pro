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

    for (final part in parts) {
      final x1 = part.x;
      final y1 = part.y;

      final x2 = part.x + part.width;
      final y2 = part.y + part.height;

      void addLine(double sx, double sy, double ex, double ey) {
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

      addLine(x1, y1, x2, y1);
      addLine(x2, y1, x2, y2);
      addLine(x2, y2, x1, y2);
      addLine(x1, y2, x1, y1);
    }

    buffer.writeln('0');
    buffer.writeln('ENDSEC');

    buffer.writeln('0');
    buffer.writeln('EOF');

    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/nesting_layout.dxf');

    await file.writeAsString(buffer.toString());

    return file;
  }
}
