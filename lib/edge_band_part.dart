class EdgeBandPart {
  String name;
  String width;
  String height;
  String qty;

  bool top;
  bool right;
  bool bottom;
  bool left;
  bool allowRotation;

  EdgeBandPart({
    required this.name,
    required this.width,
    required this.height,
    required this.qty,
    this.top = false,
    this.right = false,
    this.bottom = false,
    this.left = false,
    this.allowRotation = true,
  });
}
