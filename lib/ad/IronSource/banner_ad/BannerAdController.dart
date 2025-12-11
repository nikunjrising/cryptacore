import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';

import '../IronSourceService.dart';

class BannerAdController extends GetxController
    with LevelPlayBannerAdViewListener {

  // Debug logger
  void printLog(String msg) => print('🟡 [BannerAd] $msg');

  // Banner States
  final RxBool isBannerReady = false.obs;
  final RxBool isBannerLoading = false.obs;

  // Banner widget key (important!)
  final Rx<GlobalKey<LevelPlayBannerAdViewState>> bannerKey =
      GlobalKey<LevelPlayBannerAdViewState>().obs;

  // Service
  final _adService = Get.find<IronSourceService>();

  // Banner size
  final LevelPlayAdSize bannerSize = LevelPlayAdSize.BANNER;

  // Ad Unit getter
  String get bannerAdUnitId =>
      Platform.isAndroid ? "thnfvcsog13bhn08" : "iep3rxsyp9na3rw8";

  @override
  void onInit() {
    super.onInit();
    printLog("Banner Controller Initialized");

    if (_adService.isInitialized.value) {
      _initializeBanner();
    } else {
      ever(_adService.isInitialized, (ready) {
        if (ready == true) _initializeBanner();
      });
    }
  }

  void _initializeBanner() {
    printLog("SDK Ready → Initializing banner...");
    loadBanner();
  }

  // ===================== BANNER METHODS ====================== //

  void loadBanner() {
    if (!_adService.isInitialized.value) {
      printLog("❌ Banner load failed: SDK not initialized");
      return;
    }

    if (isBannerLoading.value) return;

    printLog("🔄 Loading Banner...");
    isBannerLoading.value = true;

    // Trigger bannerView.loadAd()
    bannerKey.value.currentState?.loadAd();
  }

  void destroyBanner() {
    printLog("🗑 Destroying Banner...");
    bannerKey.value.currentState?.destroy();

    isBannerReady.value = false;
    isBannerLoading.value = false;

    // force new widget instance
    bannerKey.value = GlobalKey<LevelPlayBannerAdViewState>();
  }

  // ===================== BANNER LISTENERS ====================== //

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    printLog("✅ Banner Loaded");
    isBannerLoading.value = false;
    isBannerReady.value = true;
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    printLog("❌ Banner Load Failed: ${error.errorMessage}");
    isBannerLoading.value = false;
    isBannerReady.value = false;

    // Auto retry after 5 sec
    Future.delayed(Duration(seconds: 5), loadBanner);
  }

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {
    printLog("📢 Banner Displayed");
  }

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {
    printLog("👆 Banner Clicked");
  }

  @override
  void onAdExpanded(LevelPlayAdInfo adInfo) {
    printLog("⬆ Banner Expanded");
  }

  @override
  void onAdCollapsed(LevelPlayAdInfo adInfo) {
    printLog("⬇ Banner Collapsed");
  }

  @override
  void onAdLeftApplication(LevelPlayAdInfo adInfo) {
    printLog("🏃 Banner Left Application");
  }

  @override
  void onAdDisplayFailed(LevelPlayAdInfo adInfo, LevelPlayAdError error) {
    printLog("❌ Banner Display Failed: ${error.errorMessage}");
    isBannerReady.value = false;
    loadBanner();
  }
}
