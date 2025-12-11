import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../const/AnimatedFlipperText.dart';
import '../../const/color.dart';
import '../../controller/MiningController.dart';

class CurrentMiningText extends StatefulWidget {

   const CurrentMiningText({super.key});

  @override
  State<CurrentMiningText> createState() => _CurrentMiningTextState();
}

class _CurrentMiningTextState extends State<CurrentMiningText> {
  final MiningController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
          // return  Text(
          //   controller.currentMining.value.toStringAsFixed(8),
          //   style: TextStyle(fontSize: 26, color: Colors.green),
          // );
      return AnimatedFlipperText(
        value: controller.currentMining.value.toStringAsFixed(6),
        fractionDigits: 8,
        fontSize: 25,
        color: AppColor.skyColor,
      );

    });
  }
}
