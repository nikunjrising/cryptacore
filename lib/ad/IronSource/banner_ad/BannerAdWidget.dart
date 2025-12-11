import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';

import 'BannerAdController.dart';

class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BannerAdController>();

    return Obx(() {
      return Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        height: controller.bannerSize.height.toDouble(),
        child: LevelPlayBannerAdView(
          key: controller.bannerKey.value,
          adUnitId: controller.bannerAdUnitId,
          adSize: controller.bannerSize,
          placementName: "DefaultBanner",
          listener: controller,
        ),
      );
    });
  }
}
