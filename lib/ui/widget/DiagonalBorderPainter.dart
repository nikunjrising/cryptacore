import 'package:cryptacore/const/color.dart';
import 'package:flutter/material.dart';

class DiagonalBorderPainter extends CustomPainter {
  final LinearGradient gradient;

  DiagonalBorderPainter(this.gradient);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      0.5,
      0.5,
      size.width - 1,
      size.height - 1,
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(10),
    );

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
