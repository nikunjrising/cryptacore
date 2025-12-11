import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';

import 'NativeAdController.dart';

class NativeAdViewWidget extends StatelessWidget {
  const NativeAdViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NativeAdController>();

    return Column(
      children: [
        const Text(
          "Native Ad",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: controller.loadNativeAd,
                child: const Text("Load Native"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: controller.destroyNativeAd,
                child: const Text("Destroy Native"),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        Obx(() {
          return SizedBox(
            width: controller.width,
            height: controller.height,
            child: controller.isNativeLoaded.value
                ? LevelPlayNativeAdView(
              key: controller.nativeAdKey,
              height: controller.height,
              width: controller.width,
              nativeAd: controller.nativeAd,
              templateType: controller.templateType,
            )
                : Center(
              child: controller.isNativeLoading.value
                  ? CircularProgressIndicator()
                  : Text("Native ad not loaded"),
            ),
          );
        }),
      ],
    );
  }
}
