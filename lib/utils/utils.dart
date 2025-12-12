import 'package:cryptacore/controller/ConfigController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../ad/IronSource/reward_ad/IsRewardAdController.dart';
import '../ad/admob/InterstitialAdService.dart';
import '../ad/IronSource/ini_ad/IsIntAdController.dart'; // Import IronSource Controller
import '../ad/admob/RewardAdController.dart';
import '../service/PreferenceHelper.dart'; // Import Preference Helper

class ShowIntAd {
  // AdMob Service
  final InterstitialAdService _adMobService = Get.put(InterstitialAdService());

  final IsIntAdController _ironSourceController = Get.put(IsIntAdController());

  void onGoAction({required Function() onGoAction}) async {
    final appConfig = Get.find<ConfigController>();
    debugPrint('isShowAds ${appConfig.config.value.isShowAd}');

    // 1. Check if Ads are enabled globally
    if (appConfig.config.value.isShowAd == true) {

      // 2. Get current rotation count (Default to 0)
      int currentCount = PreferenceHelper().getInt(PreferenceKeys.intAdRotationCount) ?? 0;

      // 3. Determine whose turn it is
      // Even numbers (0, 2, 4...) -> AdMob
      // Odd numbers (1, 3, 5...)  -> IronSource
      bool isAdMobTurn = (currentCount % 2 == 0);

      if (isAdMobTurn) {
        debugPrint("👉 Attempting to show AdMob (Count: $currentCount)");
        _showAdMob(
          onClose: onGoAction,
          // If AdMob fails/not ready, try IronSource as fallback
          onUnavailable: () => _showIronSource(onClose: onGoAction, onUnavailable: onGoAction, incrementCount: true),
        );
      } else {
        debugPrint("👉 Attempting to show IronSource (Count: $currentCount)");
        _showIronSource(
          onClose: onGoAction,
          // If IronSource fails/not ready, try AdMob as fallback
          onUnavailable: () => _showAdMob(onClose: onGoAction, onUnavailable: onGoAction, incrementCount: true),
        );
      }
    } else {
      // Ads disabled, just go
      onGoAction();
    }
  }

  // --- Helper: Show AdMob ---
  void _showAdMob({
    required Function() onClose,
    required Function() onUnavailable,
    bool incrementCount = true,
  }) {
    print('_adMobService.isAdReady ${_adMobService.isAdReady}');
    if (_adMobService.isAdReady) {
      _adMobService.show(
        onClose: () {
          if (incrementCount) _incrementAdCounter();
          onClose();
        },
        onUnavailable: () {
          onUnavailable();
        },
      );
    } else {
      onUnavailable();
    }
  }

  // --- Helper: Show IronSource ---
  void _showIronSource({
    required Function() onClose,
    required Function() onUnavailable,
    bool incrementCount = true,
  }) async {
    if (_ironSourceController.isInterstitialAdReady) {

      // Override the close callback dynamically for this specific action
      _ironSourceController.onInterstitialClosed = () {
        if (incrementCount) _incrementAdCounter();
        onClose();
      };

      await _ironSourceController.showInterstitialAd();
    } else {
      onUnavailable();
    }
  }

  // --- Helper: Increment Counter ---
  void _incrementAdCounter() {
    int currentCount = PreferenceHelper().getInt(PreferenceKeys.intAdRotationCount) ?? 0;
    PreferenceHelper().setInt(PreferenceKeys.intAdRotationCount, currentCount + 1);
    debugPrint("✅ Ad Counter Incremented to: ${currentCount + 1}");
  }
}


class ShowRewardAd {
  // Get instances of the controllers
  final RewardAdController _adMobRewardController = Get.put(RewardAdController());
  final IsRewardAdController _ironSourceRewardController = Get.put(IsRewardAdController(onReward: (_) {}));

  /// Main function to call when user clicks a button expecting a reward
  void show({
    required Function() onReward, // Called when user successfully earns reward
    required Function() onFailed, // Called if ads fail or aren't ready
  }) {
    final appConfig = Get.find<ConfigController>();

    // 1. Check if Ads are enabled globally
    if (appConfig.config.value.isShowAd == true) {

      // 2. Get current rotation count
      int currentCount = PreferenceHelper().getInt(PreferenceKeys.rewardAdRotationCount) ?? 0;

      // 3. Determine whose turn it is
      // Even -> AdMob, Odd -> IronSource
      bool isAdMobTurn = (currentCount % 2 == 0);

      if (isAdMobTurn) {
        debugPrint("👉 Attempting to show AdMob Reward (Count: $currentCount)");
        _showAdMob(
          onReward: onReward,
          onUnavailable: () => _showIronSource(onReward: onReward, onUnavailable: onFailed, incrementCount: true),
        );
      } else {
        debugPrint("👉 Attempting to show IronSource Reward (Count: $currentCount)");
        _showIronSource(
          onReward: onReward,
          onUnavailable: () => _showAdMob(onReward: onReward, onUnavailable: onFailed, incrementCount: true),
        );
      }
    } else {
      // Ads disabled, give reward immediately
      onReward();
    }
  }

  // --- Helper: Show AdMob Reward ---
  void _showAdMob({
    required Function() onReward,
    required Function() onUnavailable,
    bool incrementCount = true,
  }) async {
    // Note: Your RewardAdController.showRewardAd returns a Future<bool>
    bool earned = await _adMobRewardController.showRewardAd();

    if (earned) {
      if (incrementCount) _incrementAdCounter();
      onReward();
    } else {
      // If false, it means either ad wasn't ready or user closed without watching
      // Since we can't easily distinguish 'not ready' from 'closed early' in simple bool,
      // we usually assume if it returned false immediately, it wasn't ready.
      // Ideally, your controller should have an 'isReady' check exposed.
      onUnavailable();
    }
  }

  // --- Helper: Show IronSource Reward ---
  void _showIronSource({
    required Function() onReward,
    required Function() onUnavailable,
    bool incrementCount = true,
  }) async {
    if (_ironSourceRewardController.isAdReady) {

      // Inject the logic for this specific show instance
      _ironSourceRewardController.onReward = (reward) {
        if (incrementCount) _incrementAdCounter();
        onReward();
      };

      await _ironSourceRewardController.showRewardAd();
    } else {
      onUnavailable();
    }
  }

  // --- Helper: Increment Counter ---
  void _incrementAdCounter() {
    int currentCount = PreferenceHelper().getInt(PreferenceKeys.rewardAdRotationCount) ?? 0;
    PreferenceHelper().setInt(PreferenceKeys.rewardAdRotationCount, currentCount + 1);
    debugPrint("✅ Reward Ad Counter Incremented to: ${currentCount + 1}");
  }
}