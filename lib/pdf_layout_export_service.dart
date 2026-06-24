import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'nesting_engine.dart';

class PdfLayoutExportService {
  static Future<File> exportLayout(
    List<PlacementPart> parts,
    int sheetCount,
    double utilization,
    double waste,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('CarvePlus Cut Pro', style: pw.TextStyle(fontSize: 24)),

              pw.SizedBox(height: 20),

              pw.Text('Project Summary'),

              pw.SizedBox(height: 10),

              pw.Text('Total Parts: ${parts.length}'),
              pw.Text('Sheets Used: $sheetCount'),

              pw.Text('Utilization: ${utilization.toStringAsFixed(1)}%'),

              pw.Text('Waste: ${waste.toStringAsFixed(1)}%'),
            ],
          );
        },
      ),
    );
    final sheets = <int>{};

    for (final part in parts) {
      sheets.add(part.sheet);
    }
    for (final sheetNumber in sheets) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            final sheetParts = parts
                .where((p) => p.sheet == sheetNumber)
                .toList();
            final groupedParts = <String, List<PlacementPart>>{};

            for (final part in sheetParts) {
              groupedParts.putIfAbsent(part.code, () => []);
              groupedParts[part.code]!.add(part);
            }

            const sheetWidth = 1220.0;
            const sheetHeight = 2440.0;

            const drawWidth = 250.0;
            const drawHeight = 500.0;

            final scaleX = drawWidth / sheetWidth;
            final scaleY = drawHeight / sheetHeight;

            return pw.Column(
              children: [
                pw.Text(
                  'Sheet $sheetNumber',
                  style: pw.TextStyle(fontSize: 20),
                ),

                pw.SizedBox(height: 20),

                pw.Container(
                  width: drawWidth,
                  height: drawHeight,
                  decoration: pw.BoxDecoration(border: pw.Border.all()),
                  child: pw.Stack(
                    children: [
                      ...sheetParts.map((part) {
                        return pw.Positioned(
                          left: part.x * scaleX,
                          top: part.y * scaleY,
                          child: pw.Container(
                            width: part.width * scaleX,
                            height: part.height * scaleY,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(),
                            ),
                            child: pw.Stack(
                              children: [
                                if (part.topEdge)
                                  pw.Positioned(
                                    top: 2,
                                    left: 2,
                                    right: 2,
                                    child: pw.Container(
                                      height: 2,
                                      color: PdfColors.red,
                                    ),
                                  ),

                                if (part.bottomEdge)
                                  pw.Positioned(
                                    bottom: 2,
                                    left: 2,
                                    right: 2,
                                    child: pw.Container(
                                      height: 2,
                                      color: PdfColors.red,
                                    ),
                                  ),

                                if (part.leftEdge)
                                  pw.Positioned(
                                    left: 2,
                                    top: 2,
                                    bottom: 2,
                                    child: pw.Container(
                                      width: 2,
                                      color: PdfColors.red,
                                    ),
                                  ),

                                if (part.rightEdge)
                                  pw.Positioned(
                                    right: 2,
                                    top: 2,
                                    bottom: 2,
                                    child: pw.Container(
                                      width: 2,
                                      color: PdfColors.red,
                                    ),
                                  ),

                                pw.Center(
                                  child: pw.Text(
                                    part.code,
                                    textAlign: pw.TextAlign.center,
                                    style: const pw.TextStyle(fontSize: 8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                pw.SizedBox(height: 15),

                pw.Text(
                  'Part Schedule',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),

                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Code',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),

                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Part Name',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),

                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Length',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),

                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Width',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),

                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Qty',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Edge Band',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    ...groupedParts.entries.map((entry) {
                      final first = entry.value.first;
                      int widthEdges = 0;
                      int lengthEdges = 0;

                      if (first.topEdge) widthEdges++;
                      if (first.bottomEdge) widthEdges++;

                      if (first.leftEdge) lengthEdges++;
                      if (first.rightEdge) lengthEdges++;

                      String edgeBand = '';

                      if (widthEdges > 0) {
                        edgeBand += '${widthEdges}W';
                      }

                      if (lengthEdges > 0) {
                        if (edgeBand.isNotEmpty) {
                          edgeBand += ' + ';
                        }

                        edgeBand += '${lengthEdges}L';
                      }

                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(entry.key),
                          ),

                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(first.name.split(' #').first),
                          ),

                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(first.height.toStringAsFixed(0)),
                          ),

                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(first.width.toStringAsFixed(0)),
                          ),

                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(entry.value.length.toString()),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(edgeBand),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }

    final dir = await getApplicationDocumentsDirectory();

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');

    final file = File('${dir.path}/carveplus_$timestamp.pdf');

    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
