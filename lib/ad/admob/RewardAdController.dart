import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../controller/ConfigController.dart';



class RewardAdController extends GetxController {
  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  @override
  void onInit() {
    super.onInit();
    _loadRewardAd();
  }

  @override
  void onClose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    super.onClose();
  }
  final configController = Get.find<ConfigController>();


  /// Load a rewarded ad if not already loaded
  Future<void> _loadRewardAd() async {
    if (_isLoading || _rewardedAd != null) return;

    _isLoading = true;
    final adUnitId = Platform.isAndroid
                      ? configController.config.value.rewardAndroidId
                      : configController.config.value.rewardIosId;

    RewardedAd.load(
      // adUnitId: 'ca-app-pub-3940256099942544/5224354917',
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
          debugPrint('[RewardAd] loaded');
        },
        onAdFailedToLoad: (err) {
          debugPrint('[RewardAd] failed to load: $err');
          _rewardedAd = null;
          _isLoading = false;
          // try reload after short delay
          Future.delayed(const Duration(seconds: 5), _loadRewardAd);
        },
      ),
    );
  }

  /// Shows the rewarded ad and returns true iff user earned reward.
  /// If no ad is loaded, it attempts to load and returns false.
  Future<bool> showRewardAd() async {
    // If ad isn't ready, try to load and early-return false (caller can retry later).
    if (_rewardedAd == null) {
      debugPrint('[RewardAd] no ad ready, trying to load...');
      _loadRewardAd();
      return false;
    }

    final completer = Completer<bool>();
    bool rewardEarned = false;

    // set full screen content callbacks BEFORE showing
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[RewardAd] showed full screen content');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[RewardAd] dismissed. rewardEarned=$rewardEarned');
        // dispose the ad reference and load a fresh one
        ad.dispose();
        _rewardedAd = null;
        _loadRewardAd();
        if (!completer.isCompleted) completer.complete(rewardEarned);
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        debugPrint('[RewardAd] failed to show: $err');
        ad.dispose();
        _rewardedAd = null;
        _loadRewardAd();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    // onUserEarnedReward callback
    _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      debugPrint('[RewardAd] user earned reward: ${reward.amount} ${reward.type}');
      rewardEarned = true;
      // do not complete here — wait for dismiss callback (keeps UX consistent)
    });

    // Wait for dismiss/fail callback to complete the completer
    return completer.future.timeout(const Duration(seconds: 30), onTimeout: () {
      // If something went wrong and no callback fired, mark as failure and cleanup
      debugPrint('[RewardAd] show timeout, treating as failure');
      try {
        _rewardedAd?.dispose();
      } catch (_) {}
      _rewardedAd = null;
      _loadRewardAd();
      return false;
    });
  }
}


/*
class RewardAdController1 extends GetxController {
  RewardedAd? rewardedAd;

  RxBool isLoading = false.obs;
  RxBool isAdLoaded = false.obs;

  @override
  void onInit() {
    loadRewardAd();
    super.onInit();
  }

  void loadRewardAd() async {
    isLoading.value = true;

    await RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          isLoading.value = false;
          isAdLoaded.value = true;
        },
        onAdFailedToLoad: (err) {
          rewardedAd = null;
          isLoading.value = false;
          isAdLoaded.value = false;
        },
      ),
    );
  }

  /// SHOW REWARDED AD AND RETURN RESULT
  Future<bool?> showRewardAd() async {
    if (rewardedAd == null) return null;

    bool earned = false;

    await rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        earned = true;
      },
    );

    rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewardAd();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        loadRewardAd();
      },
    );

    return earned;
  }
}
*/