import 'edge_band_part.dart';
import 'project_settings.dart';
import 'nesting_engine.dart';
import 'package:flutter/foundation.dart';

class FreeRect {
  double x;
  double y;
  double width;
  double height;

  FreeRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}

class NestingEngineV3 {
  final ProjectSettings settings;

  NestingEngineV3(this.settings);

  bool _collide(FreeRect a, FreeRect b) {
    return b.x < a.x + a.width &&
        b.x + b.width > a.x &&
        b.y < a.y + a.height &&
        b.y + b.height > a.y;
  }

  bool _contain(FreeRect a, FreeRect b) {
    return b.x >= a.x &&
        b.y >= a.y &&
        b.x + b.width <= a.x + a.width &&
        b.y + b.height <= a.y + a.height;
  }

  FreeRect? _findNode(List<FreeRect> freeRects, double width, double height) {
    double bestScore = double.infinity;
    FreeRect? best;

    for (final rect in freeRects) {
      if (rect.width >= width && rect.height >= height) {
        final areaFit = (rect.width * rect.height) - (width * height);

        if (areaFit < bestScore) {
          bestScore = areaFit;

          best = FreeRect(x: rect.x, y: rect.y, width: width, height: height);
        }
      }
    }

    return best;
  }

  bool _splitNode(
    List<FreeRect> freeRects,
    FreeRect freeRect,
    FreeRect usedNode,
  ) {
    if (!_collide(freeRect, usedNode)) {
      return false;
    }

    if (usedNode.x < freeRect.x + freeRect.width &&
        usedNode.x + usedNode.width > freeRect.x) {
      if (usedNode.y > freeRect.y &&
          usedNode.y < freeRect.y + freeRect.height) {
        freeRects.add(
          FreeRect(
            x: freeRect.x,
            y: freeRect.y,
            width: freeRect.width,
            height: usedNode.y - freeRect.y,
          ),
        );
      }

      if (usedNode.y + usedNode.height < freeRect.y + freeRect.height) {
        freeRects.add(
          FreeRect(
            x: freeRect.x,
            y: usedNode.y + usedNode.height,
            width: freeRect.width,
            height:
                freeRect.y + freeRect.height - (usedNode.y + usedNode.height),
          ),
        );
      }
    }

    if (usedNode.y < freeRect.y + freeRect.height &&
        usedNode.y + usedNode.height > freeRect.y) {
      if (usedNode.x > freeRect.x && usedNode.x < freeRect.x + freeRect.width) {
        freeRects.add(
          FreeRect(
            x: freeRect.x,
            y: freeRect.y,
            width: usedNode.x - freeRect.x,
            height: freeRect.height,
          ),
        );
      }

      if (usedNode.x + usedNode.width < freeRect.x + freeRect.width) {
        freeRects.add(
          FreeRect(
            x: usedNode.x + usedNode.width,
            y: freeRect.y,
            width: freeRect.x + freeRect.width - (usedNode.x + usedNode.width),
            height: freeRect.height,
          ),
        );
      }
    }

    return true;
  }

  void _pruneFreeList(List<FreeRect> freeRects) {
    int i = 0;

    while (i < freeRects.length) {
      int j = i + 1;

      while (j < freeRects.length) {
        final a = freeRects[i];
        final b = freeRects[j];

        if (_contain(b, a)) {
          freeRects.removeAt(i);
          i--;
          break;
        }

        if (_contain(a, b)) {
          freeRects.removeAt(j);
          j--;
        }

        j++;
      }

      i++;
    }
  }

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

    List<FreeRect> freeRects = [
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
        var node = _findNode(
          freeRects,
          part.width + settings.partSpacing,
          part.height + settings.partSpacing,
        );

        bool rotated = false;

        final rotatedNode = _findNode(
          freeRects,
          part.height + settings.partSpacing,
          part.width + settings.partSpacing,
        );

        if (node == null && rotatedNode != null) {
          node = rotatedNode;
          rotated = true;
        }

        if (node != null && rotatedNode != null) {
          final normalWaste = node.width * node.height;
          final rotatedWaste = rotatedNode.width * rotatedNode.height;

          if (rotatedWaste < normalWaste) {
            node = rotatedNode;
            rotated = true;
          }
        }

        if (node == null) {
          currentSheet++;

          freeRects = [
            FreeRect(
              x: settings.borderMargin,
              y: settings.borderMargin,
              width: settings.sheetWidth - (settings.borderMargin * 2),
              height: settings.sheetLength - (settings.borderMargin * 2),
            ),
          ];

          continue;
        }
        if (rotated) {
          final temp = part.width;
          part.width = part.height;
          part.height = temp;
          part.rotated = true;
        }

        part.x = node.x;
        part.y = node.y;
        part.sheet = currentSheet;

        int i = 0;

        while (i < freeRects.length) {
          if (_splitNode(freeRects, freeRects[i], node)) {
            freeRects.removeAt(i);
            i--;
          }

          i++;
        }

        _pruneFreeList(freeRects);

        placed = true;
      }
    }

    final sheetCounts = <int, int>{};

    for (final p in expanded) {
      sheetCounts[p.sheet] = (sheetCounts[p.sheet] ?? 0) + 1;
    }

    debugPrint('----- SHEET SUMMARY -----');

    for (final entry in sheetCounts.entries) {
      debugPrint('Sheet ${entry.key}: ${entry.value} parts');
    }

    return expanded;
  }
}
