class Part {
  String name;
  double width;
  double height;
  int quantity;

  bool topEdge;
  bool bottomEdge;
  bool leftEdge;
  bool rightEdge;

  Part({
    required this.name,
    required this.width,
    required this.height,
    required this.quantity,

    this.topEdge = false,
    this.bottomEdge = false,
    this.leftEdge = false,
    this.rightEdge = false,
  });

  String get edgeBandSummary {
    List<String> edges = [];

    if (topEdge) edges.add('Top');
    if (bottomEdge) edges.add('Bottom');
    if (leftEdge) edges.add('Left');
    if (rightEdge) edges.add('Right');

    if (edges.isEmpty) {
      return 'No Edge Band';
    }

    return edges.join(', ');
  }
}

class Project {
  String projectName;
  String material;

  double sheetWidth;
  double sheetLength;
  double thickness;

  double borderMargin;
  double partSpacing;
  double edgeBandThickness;

  List<Part> parts;

  Project({
    required this.projectName,
    required this.material,

    required this.sheetWidth,
    required this.sheetLength,
    required this.thickness,

    required this.borderMargin,
    required this.partSpacing,
    required this.edgeBandThickness,

    this.parts = const [],
  });
}
