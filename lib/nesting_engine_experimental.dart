import 'edge_band_part.dart';
import 'project_settings.dart';
import 'free_rect.dart';

class PlacementPart {
  final String name;
  final double width;
  final double height;

  double x;
  double y;
  int sheet;

  PlacementPart({
    required this.name,
    required this.width,
    required this.height,
    this.x = 0,
    this.y = 0,
    this.sheet = 1,
  });
}

class NestingEngine {
  final ProjectSettings settings;

  NestingEngine(this.settings);

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

    expanded.sort((a, b) => (b.width * b.height).compareTo(a.width * a.height));
    final freeRects = <FreeRect>[
      FreeRect(
        x: settings.borderMargin,
        y: settings.borderMargin,
        width: settings.sheetWidth - (settings.borderMargin * 2),
        height: settings.sheetLength - (settings.borderMargin * 2),
      ),
    ];

    bool intersects(FreeRect rect, PlacementPart part) {
      return !(part.x + part.width <= rect.x ||
          part.x >= rect.x + rect.width ||
          part.y + part.height <= rect.y ||
          part.y >= rect.y + rect.height);
    }

    List<FreeRect> splitRect(FreeRect freeRect, PlacementPart part) {
      final rects = <FreeRect>[];

      // Bottom
      rects.add(
        FreeRect(
          x: freeRect.x,
          y: part.y + part.height + settings.partSpacing,
          width: freeRect.width,
          height:
              (freeRect.y + freeRect.height) -
              (part.y + part.height + settings.partSpacing),
        ),
      );

      // Right
      rects.add(
        FreeRect(
          x: part.x + part.width + settings.partSpacing,
          y: freeRect.y,
          width:
              (freeRect.x + freeRect.width) -
              (part.x + part.width + settings.partSpacing),
          height: part.height,
        ),
      );

      return rects;
    }

    int currentSheet = 1;

    for (final part in expanded) {
      FreeRect? fittingRect;

      double smallestWaste = double.infinity;

      for (final rect in freeRects) {
        if (part.width <= rect.width && part.height <= rect.height) {
          final waste = (rect.width * rect.height) - (part.width * part.height);

          if (waste < smallestWaste) {
            smallestWaste = waste;
            fittingRect = rect;
          }
        }
      }
      if (fittingRect != null) {
        part.x = fittingRect.x;
        part.y = fittingRect.y;

        final rectsToSplit = freeRects
            .where((rect) => intersects(rect, part))
            .toList();

        for (final rect in rectsToSplit) {
          freeRects.remove(rect);

          final newRects = splitRect(rect, part);

          freeRects.addAll(newRects);
        }

        freeRects.removeWhere((rect) => rect.width <= 0 || rect.height <= 0);

        freeRects.removeWhere((rectA) {
          return freeRects.any((rectB) {
            if (identical(rectA, rectB)) return false;

            return rectA.x >= rectB.x &&
                rectA.y >= rectB.y &&
                rectA.x + rectA.width <= rectB.x + rectB.width &&
                rectA.y + rectA.height <= rectB.y + rectB.height;
          });
        });

        part.sheet = currentSheet;
      }
    }

    return expanded;
  }
}
