import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../controller/ConfigController.dart';

class AppOpenAdManager {
  AppOpenAd? _appOpenAd;
  bool _isAdLoaded = false;
  bool _isShowingAd = false;
  bool _isLoading = false;
  DateTime? _lastBackgroundTime;

  // 1. Expose this getter so Dashboard can check it
  bool get isShowingAd => _isShowingAd;

  final appConfig = Get.find<ConfigController>();

  /// Wait for config to load completely
  Future<bool> _waitForConfig() async {
    int attempts = 0;
    while (appConfig.config.value.appOpenAndroidId == null && attempts < 50) {
      await Future.delayed(Duration(milliseconds: 100));
      attempts++;
      debugPrint("⏳ Waiting for config... attempt $attempts");
    }

    if (appConfig.config.value.isShowAppOpenAd != true) {
      debugPrint("🚫 AppOpen Ads disabled by config.");
      return false;
    }

    return true;
  }

  /// Load app open ad
  Future<void> loadAd() async {
    if (_isAdLoaded || _isLoading) {
      debugPrint("📱 Ad already loaded or loading");
      return;
    }

    debugPrint("🚀 Starting to load AppOpenAd...");
    _isLoading = true;

    try {
      final allowed = await _waitForConfig();
      if (!allowed) {
        _isLoading = false;
        return;
      }

      final appOpenId = Platform.isAndroid
          ? appConfig.config.value.appOpenAndroidId ?? ''
          : appConfig.config.value.appOpenIosId ?? '';

      debugPrint("📱 AppOpen ID: $appOpenId");

      if (appOpenId.isEmpty) {
        debugPrint("❌ AppOpen ID empty");
        _isLoading = false;
        Future.delayed(Duration(seconds: 30), loadAd); // Retry after 30s
        return;
      }

      await AppOpenAd.load(
        adUnitId: appOpenId,
        request: AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint("✅✅✅ AppOpenAd LOADED SUCCESSFULLY!");
            _appOpenAd = ad;
            _isAdLoaded = true;
            _isLoading = false;

            // Set callbacks immediately
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                debugPrint("📤 AppOpenAd dismissed");
                _isShowingAd = false;
                _isAdLoaded = false;
                _appOpenAd = null;
                ad.dispose();

                // Load next ad
                Future.delayed(Duration(seconds: 1), loadAd);
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint("❌ Failed to show AppOpenAd: $error");
                _isShowingAd = false;
                _isAdLoaded = false;
                _appOpenAd = null;
                ad.dispose();

                // Load next ad
                Future.delayed(Duration(seconds: 1), loadAd);
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint("❌❌❌ FAILED to load AppOpenAd: $error");
            _appOpenAd = null;
            _isAdLoaded = false;
            _isLoading = false;

            // Retry after delay
            Future.delayed(Duration(seconds: 30), loadAd);
          },
        ),
      );
    } catch (e) {
      debugPrint("❌ Exception in loadAd: $e");
      _isLoading = false;
    }
  }

  void recordAppPaused() {
    // 2. Fix: If pause is caused by OUR Ad, don't record time
    if (_isShowingAd) {
      debugPrint("⏸️ App paused due to Ad Showing - IGNORING time record");
      return;
    }

    debugPrint("⏸️ App paused - recording time");
    _lastBackgroundTime = DateTime.now();
  }

  bool shouldShowAd() {
    if (_lastBackgroundTime == null) {
      debugPrint("🆕 Cold start - should show ad");
      return true;
    }

    final minutes = DateTime.now().difference(_lastBackgroundTime!).inMinutes;
    debugPrint("⏰ Time since last background: $minutes minutes");
    return minutes >= 30;
  }

  /// Show only when REALLY available
  void showAdIfAvailable() {
    debugPrint("🎬 showAdIfAvailable called");
    printStatus();

    if (_isShowingAd) {
      debugPrint("⏳ Ad already showing");
      return;
    }

    if (!_isAdLoaded || _appOpenAd == null) {
      debugPrint("📦 Ad not loaded yet");
      return;
    }

    if (!shouldShowAd()) {
      debugPrint("⏰ Not enough time passed since last ad");
      return;
    }

    debugPrint("✅✅✅ SHOWING AppOpenAd...");
    _isShowingAd = true;

    // 3. Fix: Reset the timer NOW.
    // This ensures that when this ad closes and app resumes,
    // 'shouldShowAd' will calculate 0 minutes difference and return FALSE.
    _lastBackgroundTime = DateTime.now();

    try {
      _appOpenAd!.show();
    } catch (e) {
      debugPrint("❌ Error showing AppOpenAd: $e");
      _isShowingAd = false;
      _isAdLoaded = false;
      _appOpenAd = null;
      Future.delayed(Duration(seconds: 1), loadAd);
    }
  }

  void printStatus() {
    debugPrint("""
📊 AppOpenAd Status:
  - _appOpenAd: ${_appOpenAd != null ? 'Loaded' : 'Null'}
  - _isAdLoaded: $_isAdLoaded
  - _isLoading: $_isLoading
  - _isShowingAd: $_isShowingAd
  - shouldShowAd(): ${shouldShowAd()}
  - _lastBackgroundTime: $_lastBackgroundTime
""");
  }
}
