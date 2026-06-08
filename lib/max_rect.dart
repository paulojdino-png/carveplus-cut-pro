class MaxRect {
  double x;
  double y;
  double width;
  double height;

  MaxRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  double get area => width * height;
}
