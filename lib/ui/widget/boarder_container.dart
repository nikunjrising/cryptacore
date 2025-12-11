import 'package:flutter/material.dart';

import '../../const/color.dart';
import 'DiagonalBorderPainter.dart';
class BoarderContainer extends StatelessWidget {
  final Widget child;
  const BoarderContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DiagonalBorderPainter(AppColor.greenGradient),
      child: Container(
        height: 200,
        width: double.infinity,
        margin: const EdgeInsets.all(0), // Adjust based on border width
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: child,
      ),
    );
  }
}
