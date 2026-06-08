import 'edge_band_part.dart';
import 'project_settings.dart';
import 'nesting_engine.dart';

class FreeRect {
  final double x;
  final double y;
  final double width;
  final double height;

  FreeRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}

class NestingEngineV2 {
  final ProjectSettings settings;

  NestingEngineV2(this.settings);

  List<PlacementPart> optimize(List<EdgeBandPart> parts) {
    final expanded = <PlacementPart>[];

    for (final part in parts) {
      final qty = int.tryParse(part.qty) ?? 1;

      final width = double.tryParse(part.width) ?? 0;

      final height = double.tryParse(part.height) ?? 0;

      for (int i = 1; i <= qty; i++) {
        expanded.add(
          PlacementPart(name: '${part.name} #$i', width: width, height: height),
        );
      }
    }

    expanded.sort((a, b) => b.height.compareTo(a.height));

    final freeRects = <FreeRect>[
      FreeRect(
        x: settings.borderMargin,
        y: settings.borderMargin,
        width: settings.sheetWidth - (settings.borderMargin * 2),
        height: settings.sheetLength - (settings.borderMargin * 2),
      ),
    ];

    int currentSheet = 1;

    for (final part in expanded) {
      bool placed = false;

      while (!placed) {
        FreeRect? fittingRect;
        double smallestWaste = double.infinity;

        for (final rect in freeRects) {
          if (part.width <= rect.width && part.height <= rect.height) {
            final waste =
                (rect.width * rect.height) - (part.width * part.height);

            if (waste < smallestWaste) {
              smallestWaste = waste;
              fittingRect = rect;
            }
          }
        }

        if (fittingRect != null) {
          part.x = fittingRect.x;
          part.y = fittingRect.y;
          part.sheet = currentSheet;

          // ignore: avoid_print
          print(
            '${part.name} sheet=${part.sheet} '
            'x=${part.x} y=${part.y} '
            'w=${part.width} h=${part.height}',
          );

          freeRects.remove(fittingRect);

          final rightWidth =
              fittingRect.width - part.width - settings.partSpacing;

          final bottomHeight =
              fittingRect.height - part.height - settings.partSpacing;

          if (rightWidth > bottomHeight) {
            if (rightWidth > 0) {
              freeRects.add(
                FreeRect(
                  x: fittingRect.x + part.width + settings.partSpacing,
                  y: fittingRect.y,
                  width: rightWidth,
                  height: fittingRect.height,
                ),
              );
            }

            if (bottomHeight > 0) {
              freeRects.add(
                FreeRect(
                  x: fittingRect.x,
                  y: fittingRect.y + part.height + settings.partSpacing,
                  width: part.width,
                  height: bottomHeight,
                ),
              );
            }
          } else {
            if (bottomHeight > 0) {
              freeRects.add(
                FreeRect(
                  x: fittingRect.x,
                  y: fittingRect.y + part.height + settings.partSpacing,
                  width: fittingRect.width,
                  height: bottomHeight,
                ),
              );
            }

            if (rightWidth > 0) {
              freeRects.add(
                FreeRect(
                  x: fittingRect.x + part.width + settings.partSpacing,
                  y: fittingRect.y,
                  width: rightWidth,
                  height: part.height,
                ),
              );
            }
          }
          freeRects.removeWhere(
            (rectA) => freeRects.any((rectB) {
              if (identical(rectA, rectB)) return false;

              return rectA.x >= rectB.x &&
                  rectA.y >= rectB.y &&
                  rectA.x + rectA.width <= rectB.x + rectB.width &&
                  rectA.y + rectA.height <= rectB.y + rectB.height;
            }),
          );
          placed = true;
        } else {
          // ignore: avoid_print
          print('NEW SHEET CREATED FOR ${part.name}');
          currentSheet++;

          freeRects.clear();

          freeRects.add(
            FreeRect(
              x: settings.borderMargin,
              y: settings.borderMargin,
              width: settings.sheetWidth - (settings.borderMargin * 2),
              height: settings.sheetLength - (settings.borderMargin * 2),
            ),
          );
        }
      }
    }
    return expanded;
  }
}
