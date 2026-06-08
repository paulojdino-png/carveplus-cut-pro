class ProjectSettings {
  final String projectName;
  final String material;

  final double sheetWidth;
  final double sheetLength;

  final double thickness;

  final double borderMargin;
  final double partSpacing;

  final double edgeBandThickness;

  final bool allowRotation;
  final bool woodGrain;

  const ProjectSettings({
    required this.projectName,
    required this.material,
    required this.sheetWidth,
    required this.sheetLength,
    required this.thickness,
    required this.borderMargin,
    required this.partSpacing,
    required this.edgeBandThickness,
    required this.allowRotation,
    required this.woodGrain,
  });
}
