import 'package:flutter/material.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';

class AnimatedFlipperText extends StatelessWidget {
  final String value;
  final int fractionDigits;
  final double fontSize;
  final Color color;
  final Duration duration;

  const AnimatedFlipperText({
    super.key,
    required this.value,
    this.fractionDigits = 8,
    this.fontSize = 26,
    this.color = Colors.green,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedFlipCounter(
      // Pass the numeric value directly — don't parse from string here
      value: double.parse(value),
      fractionDigits: fractionDigits,
      duration: duration,
      curve: Curves.easeOut,
      // style config
      textStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      // Optional: provide a fallback for empty values (not usually needed)
    );
  }
}
