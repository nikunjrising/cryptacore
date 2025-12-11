import 'package:cryptacore/const/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../ui/widget/DiagonalBorderPainter.dart';

class LoadingDialog extends StatelessWidget {
  final String? message;

  const LoadingDialog({this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height,
      width: Get.width,
      color: Colors.black.withValues(alpha: 0.1),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child:SizedBox(
            height: 300,
            width: 300,
            child: Container(
              height: 300,
              width: 300,
              color: Colors.transparent,
              padding: EdgeInsets.all( 40),
              child: CustomPaint(
                painter: DiagonalBorderPainter(AppColor.skyGradient),
                child: Container(
                  height: 200,
                  width: 200,
                  margin: const EdgeInsets.all(2), // Adjust based on border width
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}





