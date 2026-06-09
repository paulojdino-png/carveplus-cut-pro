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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'width': width,
      'height': height,
      'quantity': quantity,
      'topEdge': topEdge,
      'bottomEdge': bottomEdge,
      'leftEdge': leftEdge,
      'rightEdge': rightEdge,
    };
  }

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
      name: json['name'],
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      quantity: json['quantity'],
      topEdge: json['topEdge'] ?? false,
      bottomEdge: json['bottomEdge'] ?? false,
      leftEdge: json['leftEdge'] ?? false,
      rightEdge: json['rightEdge'] ?? false,
    );
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

  Map<String, dynamic> toJson() {
    return {
      'projectName': projectName,
      'material': material,
      'sheetWidth': sheetWidth,
      'sheetLength': sheetLength,
      'thickness': thickness,
      'borderMargin': borderMargin,
      'partSpacing': partSpacing,
      'edgeBandThickness': edgeBandThickness,
      'parts': parts.map((e) => e.toJson()).toList(),
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectName: json['projectName'],
      material: json['material'],
      sheetWidth: (json['sheetWidth'] as num).toDouble(),
      sheetLength: (json['sheetLength'] as num).toDouble(),
      thickness: (json['thickness'] as num).toDouble(),
      borderMargin: (json['borderMargin'] as num).toDouble(),
      partSpacing: (json['partSpacing'] as num).toDouble(),
      edgeBandThickness: (json['edgeBandThickness'] as num).toDouble(),
      parts: (json['parts'] as List).map((e) => Part.fromJson(e)).toList(),
    );
  }
}
