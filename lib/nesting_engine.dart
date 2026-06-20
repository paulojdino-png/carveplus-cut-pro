import 'edge_band_part.dart';
import 'project_settings.dart';

class PlacementPart {
  final String name;
  double width;
  double height;
  bool topEdge;

  bool bottomEdge;
  bool leftEdge;
  bool rightEdge;

  bool rotated;

  double x;
  double y;
  int sheet;

  PlacementPart({
    required this.name,
    required this.width,
    required this.height,

    this.topEdge = false,
    this.bottomEdge = false,
    this.leftEdge = false,
    this.rightEdge = false,

    this.x = 0,
    this.y = 0,
    this.sheet = 1,
    this.rotated = false,
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

    int currentSheet = 1;

    double cursorX = settings.borderMargin;
    double cursorY = settings.borderMargin;

    double currentRowHeight = 0;

    for (final part in expanded) {
      if (cursorX + part.width > settings.sheetWidth - settings.borderMargin) {
        cursorX = settings.borderMargin;
        cursorY += currentRowHeight + settings.partSpacing;
        currentRowHeight = 0;
      }

      if (cursorY + part.height >
          settings.sheetLength - settings.borderMargin) {
        currentSheet++;

        cursorX = settings.borderMargin;
        cursorY = settings.borderMargin;
        currentRowHeight = 0;
      }

      part.x = cursorX;
      part.y = cursorY;
      part.sheet = currentSheet;

      cursorX += part.width + settings.partSpacing;

      if (part.height > currentRowHeight) {
        currentRowHeight = part.height;
      }
    }

    return expanded;
  }
}
