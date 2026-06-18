import 'nesting_engine.dart';
import 'package:flutter/material.dart';
import 'edge_band_part.dart';
import 'project_settings.dart';
import 'dxf_export_service.dart';
import 'nesting_engine_v4.dart';
import 'package:share_plus/share_plus.dart';

class OptimizationScreen extends StatelessWidget {
  final List<EdgeBandPart> parts;
  final ProjectSettings settings;

  const OptimizationScreen({
    super.key,
    required this.parts,
    required this.settings,
  });

  double get sheetWidthMm => settings.sheetWidth;

  double get sheetHeightMm => settings.sheetLength;

  double get borderMm => settings.borderMargin;

  double get spacingMm => settings.partSpacing;

  @override
  Widget build(BuildContext context) {
    final engine = NestingEngineV4(settings);

    final placedParts = engine.optimize(parts);
    for (final p in placedParts) {
      if (p.name.contains('d #8')) {
        debugPrint(
          'D8 => x=${p.x}, y=${p.y}, w=${p.width}, h=${p.height}, sheet=${p.sheet}',
        );
      }
    }
    double totalPartArea = 0;

    for (final p in placedParts) {
      totalPartArea += p.width * p.height;
    }

    final sheets = <List<PlacementPart>>[[]];

    for (final part in placedParts.where((p) => p.sheet > 0)) {
      while (sheets.length < part.sheet) {
        sheets.add([]);
      }

      sheets[part.sheet - 1].add(part);
    }

    final sheetArea = sheetWidthMm * sheetHeightMm;
    final totalSheetArea = sheetArea * sheets.length;

    final utilization = totalSheetArea == 0
        ? 0
        : (totalPartArea / totalSheetArea) * 100;

    final waste = 100 - utilization;
    double lastSheetArea = 0;

    for (final p in sheets.last) {
      lastSheetArea += p.width * p.height;
    }

    final lastSheetUtilization = (lastSheetArea / sheetArea) * 100;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1120),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Optimization Result',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...List.generate(sheets.length, (sheetIndex) {
              final sheetParts = sheets[sheetIndex];

              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2234),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Sheet ${sheetIndex + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    AspectRatio(
                      aspectRatio: sheetWidthMm / sheetHeightMm,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2234),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final scaleX = constraints.maxWidth / sheetWidthMm;
                            final scaleY =
                                constraints.maxHeight / sheetHeightMm;

                            return Stack(
                              children: [
                                Positioned(
                                  left: borderMm * scaleX,
                                  top: borderMm * scaleY,
                                  right: borderMm * scaleX,
                                  bottom: borderMm * scaleY,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white54),
                                    ),
                                  ),
                                ),
                                ...sheetParts.map((part) {
                                  if (part.name == 'd #8') {
                                    debugPrint(
                                      'DRAWING D8 left=${part.x} top=${part.y} width=${part.width} height=${part.height}',
                                    );
                                  }
                                  return Positioned(
                                    left: part.x * scaleX,

                                    top: part.y * scaleY,

                                    child: Container(
                                      width: part.width * scaleX,
                                      height: part.height * scaleY,

                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Center(
                                        child: FittedBox(
                                          child: Padding(
                                            padding: const EdgeInsets.all(2),
                                            child: Text(
                                              part.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      debugPrint('PDF EXPORT CLICKED');
                    },
                    child: const Text('Export PDF'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final file = await DxfExportService.exportLayout(
                        placedParts,
                      );

                      debugPrint('DXF CREATED: ${file.path}');

                      await Share.shareXFiles([
                        XFile(file.path),
                      ], text: 'CarvePlus DXF Export');
                    },
                    child: const Text('Export DXF'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2234),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Total Parts: ${placedParts.length}\n'
                'Sheets Used: ${sheets.length}\n'
                'Utilization: ${utilization.toStringAsFixed(1)}%\n'
                'Waste: ${waste.toStringAsFixed(1)}%\n'
                'Last Sheet Utilization: ${lastSheetUtilization.toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
