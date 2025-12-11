import 'package:flutter/material.dart';

import '../../const/color.dart';
import '../../main.dart';

class AppSnackBar {
  static void show({
    required String title,
    required String subtitle,
    Color? backgroundColor,
  }) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "$title\n",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColor.dialogBgColor,
                  fontSize: 16,
                ),
              ),
              if (subtitle != '')
                TextSpan(
                  text: subtitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColor.dialogBgColor,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
        backgroundColor: backgroundColor?.withValues(alpha: 0.5) ?? AppColor.skyColor,
        behavior: SnackBarBehavior.fixed, // Changed to fixed
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 2),
      ),
    );
  }
}