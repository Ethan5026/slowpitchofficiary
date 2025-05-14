import 'package:flutter/material.dart';

class DrawBbox extends CustomPainter {
  final int x;
  final int y;
  final int radius;

  DrawBbox({required this.x, required this.y, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw a circle around the detected center with the given radius.
    double scaleX = size.width / 4032;
    double scaleY = size.height / 3024;
    canvas.drawCircle(
        Offset(x.toDouble() * scaleX, y.toDouble() * scaleY), radius.toDouble(), paint);
  }

  @override
  bool shouldRepaint(covariant DrawBbox oldDelegate) {
    return oldDelegate.x != x ||
        oldDelegate.y != y ||
        oldDelegate.radius != radius;
  }
}
