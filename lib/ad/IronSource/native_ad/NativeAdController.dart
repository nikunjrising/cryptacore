import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';

import '../IronSourceService.dart';

class NativeAdController extends GetxController
    with LevelPlayNativeAdListener {

  final IronSourceService _adService = Get.find<IronSourceService>();

  // Native ad state
  final RxBool isNativeLoaded = false.obs;
  final RxBool isNativeLoading = false.obs;

  late LevelPlayNativeAd nativeAd;

  // UI rebuild key for the widget
  final nativeAdKey = GlobalKey();

  final double width = 350;
  final double height = 300;

  final String placementName = Platform.isAndroid
      ? 'ysoafvxg3grxe59f'
      : 'your_ios_native_placement_id';
  final LevelPlayTemplateType templateType = LevelPlayTemplateType.MEDIUM;

  @override
  void onInit() {
    super.onInit();

    if (_adService.isInitialized.value) {
      _initializeNativeAd();
    } else {
      ever(_adService.isInitialized, (ready) {
        if (ready == true) _initializeNativeAd();
      });
    }
  }

  void _initializeNativeAd() {
    print('🎨 Initializing Native Ad...');

    nativeAd = LevelPlayNativeAd.builder()
        .withPlacementName(placementName)
        .withListener(this)
        .build();

    loadNativeAd();
  }

  // Load a new native ad
  void loadNativeAd() {
    if (!_adService.isInitialized.value) {
      print("❌ SDK not ready yet");
      return;
    }

    if (isNativeLoading.value) return;

    print("🔄 Loading Native Ad...");
    isNativeLoading.value = true;
    nativeAd.loadAd();
  }

  // Destroy and rebuild
  void destroyNativeAd() {
    print("🗑 Destroying Native Ad");
    nativeAd.destroyAd();

    // force widget to rebuild
    nativeAdKey.currentState?.setState(() {});
    isNativeLoaded.value = false;

    // recreate instance
    nativeAd = LevelPlayNativeAd.builder()
        .withPlacementName(placementName)
        .withListener(this)
        .build();
  }

  // ====== LISTENER EVENTS ======

  @override
  void onAdLoaded(LevelPlayNativeAd ad, AdInfo adInfo) {
    print("✅ Native Ad Loaded");
    isNativeLoading.value = false;
    isNativeLoaded.value = true;
  }

  @override
  void onAdLoadFailed(LevelPlayNativeAd ad, IronSourceError error) {
    print("❌ Native Failed: ${error.message}");
    isNativeLoading.value = false;
    isNativeLoaded.value = false;

    Future.delayed(Duration(seconds: 4), loadNativeAd);
  }

  @override
  void onAdImpression(LevelPlayNativeAd ad, AdInfo adInfo) {
    print("👀 Native Impression");
  }

  @override
  void onAdClicked(LevelPlayNativeAd ad, AdInfo adInfo) {
    print("👆 Native Clicked");
  }
}
