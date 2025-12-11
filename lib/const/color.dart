import 'package:flutter/material.dart';

class AppColor {
  static const Color pinkColor = Color(0xFFF087FF);
  static const Color skyColor = Color(0xFF1FCFF1);
  static const Color greenColor = Color(0xFF19FB9B);
  static const Color purpleColor = Color(0xFF862BED);
  static const Color grayColor = Color(0xFF9D9DAE);
  static const Color dialogBgColor = Color(0xFF1E2324);
  static const LinearGradient skyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      skyColor,
      Colors.transparent,
      Colors.transparent,
      skyColor,
    ],
    stops: [0.0, 0.5, 0.5, 1.0],
  );
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      greenColor,
      Colors.transparent,
      Colors.transparent,
      greenColor,
    ],
    stops: [0.0, 0.5, 0.5, 1.0],
  );

}
