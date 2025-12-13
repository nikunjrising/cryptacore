import 'dart:async';
import 'package:cryptacore/const/color.dart';
import 'package:cryptacore/controller/ConfigController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../ad/IronSource/reward_ad/IsRewardAdController.dart';
import '../ad/admob/InterstitialAdService.dart';
import '../ad/IronSource/ini_ad/IsIntAdController.dart';
import '../ad/admob/RewardAdController.dart';
import '../service/PreferenceHelper.dart';

// =========================================================
// HELPER: Loading Dialog
// =========================================================
void showAdLoadingDialog() {
  Get.dialog(
    PopScope(
      canPop: false, // User cannot close it manually
      child: Center(
        child: Material(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 15),
                Text("Loading Ad...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: Colors.black)),
              ],
            ),
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

// =========================================================
// INTERSTITIAL AD CLASS
// =========================================================
class ShowIntAd {
  final InterstitialAdService _adMobService = Get.put(InterstitialAdService());
  final IsIntAdController _ironSourceController = Get.put(IsIntAdController());

  void onGoAction({required Function() onGoAction}) async {
    final appConfig = Get.find<ConfigController>();

    if (appConfig.config.value.isShowAd == true) {
      int currentCount = PreferenceHelper().getInt(PreferenceKeys.intAdRotationCount) ?? 0;
      bool isAdMobTurn = (currentCount % 2 == 0);

      if (isAdMobTurn) {
        _handleAdMob(onClose: onGoAction, onUnavailable: onGoAction);
      } else {
        _handleIronSource(onClose: onGoAction, onUnavailable: onGoAction);
      }
    } else {
      onGoAction();
    }
  }

  // --- AdMob Handler (With Waiting) ---
  void _handleAdMob({required Function() onClose, required Function() onUnavailable}) {
    if (_adMobService.isAdReady.value) {
      // Ad is ready, show immediately
      _showAdMob(onClose: onClose, onUnavailable: onUnavailable);
    } else {
      // Ad NOT ready, Show Loading and Wait
      showAdLoadingDialog();
      _waitForAd(
        isReadyChecker: () => _adMobService.isAdReady.value,
        onReady: () {
          Get.back(); // Close Loading
          _showAdMob(onClose: onClose, onUnavailable: onUnavailable);
        },
        onTimeout: () {
          Get.back(); // Close Loading
          // Fallback to IronSource if AdMob timed out
          _handleIronSourceFallback(onClose, onUnavailable);
        },
      );
    }
  }

  // --- IronSource Handler (With Waiting) ---
  void _handleIronSource({required Function() onClose, required Function() onUnavailable}) {
    if (_ironSourceController.isInterstitialAdReady) {
      _showIronSource(onClose: onClose, onUnavailable: onUnavailable);
    } else {
      showAdLoadingDialog();
      _ironSourceController.loadInterstitialAd(); // Trigger load just in case
      _waitForAd(
        isReadyChecker: () => _ironSourceController.isInterstitialAdReady,
        onReady: () {
          Get.back();
          _showIronSource(onClose: onClose, onUnavailable: onUnavailable);
        },
        onTimeout: () {
          Get.back();
          // Fallback to AdMob
          _handleAdMobFallback(onClose, onUnavailable);
        },
      );
    }
  }

  // --- Fallbacks (No waiting, just check) ---
  void _handleIronSourceFallback(Function() onClose, Function() onUnavailable) {
    if (_ironSourceController.isInterstitialAdReady) {
      _showIronSource(onClose: onClose, onUnavailable: onUnavailable, incrementCount: true);
    } else {
      onUnavailable(); // Give up
    }
  }

  void _handleAdMobFallback(Function() onClose, Function() onUnavailable) {
    if (_adMobService.isAdReady.value) {
      _showAdMob(onClose: onClose, onUnavailable: onUnavailable, incrementCount: true);
    } else {
      onUnavailable(); // Give up
    }
  }

  // --- Existing Logic to Show ---
  void _showAdMob({required Function() onClose, required Function() onUnavailable, bool incrementCount = true}) {
    _adMobService.show(
      onClose: () { if (incrementCount) _incrementAdCounter(); onClose(); },
      onUnavailable: onUnavailable,
    );
  }

  void _showIronSource({required Function() onClose, required Function() onUnavailable, bool incrementCount = true}) async {
    _ironSourceController.onInterstitialClosed = () {
      if (incrementCount) _incrementAdCounter();
      onClose();
    };
    await _ironSourceController.showInterstitialAd();
  }

  void _incrementAdCounter() {
    int currentCount = PreferenceHelper().getInt(PreferenceKeys.intAdRotationCount) ?? 0;
    PreferenceHelper().setInt(PreferenceKeys.intAdRotationCount, currentCount + 1);
  }

  // --- GENERIC WAITER ---
  void _waitForAd({required bool Function() isReadyChecker, required Function() onReady, required Function() onTimeout}) {
    int attempts = 0;
    // Check every 1 second, for max 8 seconds
    Timer.periodic(const Duration(seconds: 1), (timer) {
      attempts++;
      if (isReadyChecker()) {
        timer.cancel();
        onReady();
      } else if (attempts >= 8) { // 8 Seconds timeout
        timer.cancel();
        onTimeout();
      }
    });
  }
}

// =========================================================
// REWARD AD CLASS
// =========================================================
class ShowRewardAd {
  final RewardAdController _adMobRewardController = Get.put(RewardAdController());
  final IsRewardAdController _ironSourceRewardController = Get.put(IsRewardAdController(onReward: (_) {}));

  void show({required Function() onReward, required Function() onFailed}) {
    final appConfig = Get.find<ConfigController>();
    if (appConfig.config.value.isShowAd == true) {
      int currentCount = PreferenceHelper().getInt(PreferenceKeys.rewardAdRotationCount) ?? 0;
      bool isAdMobTurn = (currentCount % 2 == 0);

      if (isAdMobTurn) {
        _handleAdMob(onReward, onFailed);
      } else {
        _handleIronSource(onReward, onFailed);
      }
    } else {
      onReward();
    }
  }

  // --- AdMob Handler ---
  void _handleAdMob(Function() onReward, Function() onFailed) {
    if (_adMobRewardController.isAdLoaded.value) {
      _showAdMob(onReward: onReward, onUnavailable: onFailed);
    } else {
      print('_adMobRewardController.isAdLoaded.value1 ${_adMobRewardController.isAdLoaded.value}');
      showAdLoadingDialog();
      print('_adMobRewardController.isAdLoaded.value2 ${_adMobRewardController.isAdLoaded.value}');

      _waitForAd(
        isReadyChecker: () => _adMobRewardController.isAdLoaded.value,
        onReady: () {
          Get.back();
          _showAdMob(onReward: onReward, onUnavailable: onFailed);
        },
        onTimeout: () {
          Get.back();
          // Fallback
          if (_ironSourceRewardController.isAdReady) {
            _showIronSource(onReward: onReward, onUnavailable: onFailed, incrementCount: true);
          } else {
            onFailed();
          }
        },
      );
    }
  }

  // --- IronSource Handler ---
  void _handleIronSource(Function() onReward, Function() onFailed) {
    if (_ironSourceRewardController.isAdReady) {
      _showIronSource(onReward: onReward, onUnavailable: onFailed);
    } else {
      print('_adMobRewardController.isAdLoaded.value11 ${_adMobRewardController.isAdLoaded.value}');
      showAdLoadingDialog();
      print('_adMobRewardController.isAdLoaded.value22 ${_adMobRewardController.isAdLoaded.value}');
      _ironSourceRewardController.loadAd();
      _waitForAd(
        isReadyChecker: () => _ironSourceRewardController.isAdReady,
        onReady: () {
          Get.back();
          _showIronSource(onReward: onReward, onUnavailable: onFailed);
        },
        onTimeout: () {
          Get.back();
          // Fallback
          if (_adMobRewardController.isAdLoaded.value) {
            _showAdMob(onReward: onReward, onUnavailable: onFailed, incrementCount: true);
          } else {
            onFailed();
          }
        },
      );
    }
  }

  // --- Helper: Show AdMob ---
  void _showAdMob({required Function() onReward, required Function() onUnavailable, bool incrementCount = true}) async {
    bool earned = await _adMobRewardController.showRewardAd();
    if (earned) {
      if (incrementCount) _incrementAdCounter();
      onReward();
    } else {
      onUnavailable();
    }
  }

  // --- Helper: Show IronSource ---
  void _showIronSource({required Function() onReward, required Function() onUnavailable, bool incrementCount = true}) async {
    _ironSourceRewardController.onReward = (reward) {
      if (incrementCount) _incrementAdCounter();
      onReward();
    };
    await _ironSourceRewardController.showRewardAd();
  }

  void _incrementAdCounter() {
    int currentCount = PreferenceHelper().getInt(PreferenceKeys.rewardAdRotationCount) ?? 0;
    PreferenceHelper().setInt(PreferenceKeys.rewardAdRotationCount, currentCount + 1);
  }

  // --- Reuse the Waiter ---
  void _waitForAd({required bool Function() isReadyChecker, required Function() onReady, required Function() onTimeout}) {
    int attempts = 0;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      attempts++;
      if (isReadyChecker()) {
        timer.cancel();
        onReady();
      } else if (attempts >= 8) { // Timeout after 8 seconds
        timer.cancel();
        onTimeout();
      }
    });
  }
}
