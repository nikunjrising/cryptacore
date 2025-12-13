import 'package:get/get.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';
import 'dart:io';

import '../IronSourceService.dart';

class IsRewardAdController extends GetxController
    with LevelPlayRewardedAdListener {

  final RxBool _isAdReady = false.obs;
  final RxBool _isLoading = false.obs;

  bool get isAdReady => _isAdReady.value;
  bool get isLoading => _isLoading.value;

  // CHANGED: Make nullable to prevent LateInitializationError
  LevelPlayRewardedAd? _rewardedAd;

  late void Function(LevelPlayReward reward) onReward;

  final IronSourceService _adService = Get.find<IronSourceService>();

  IsRewardAdController({required this.onReward});

  @override
  void onInit() {
    super.onInit();

    // CHANGED: Check if ALREADY initialized, otherwise wait for it
    if (_adService.isInitialized.value) {
      _initializeAd();
    } else {
      ever(_adService.isInitialized, (isInitialized) {
        if (isInitialized && _rewardedAd == null) {
          _initializeAd();
        }
      });
    }
  }

  void _initializeAd() {
    print('Initializing rewarded ad...');
    _rewardedAd = LevelPlayRewardedAd(adUnitId: _getRewardedAdUnitId());
    _rewardedAd!.setListener(this); // Use ! because we just assigned it

    // Load immediately after init
    loadAd();
  }

  String _getRewardedAdUnitId() {
    return Platform.isAndroid
        ? '76yy3nay3ceui2a3'
        : 'qwouvdrkuwivay5q';
  }

  // Method to load the rewarded ad
  void loadAd() {
    if (!_adService.isInitialized.value) {
      print('Cannot load ad: SDK not initialized');
      return;
    }

    // CHANGED: Safety check if _rewardedAd is null
    if (_rewardedAd == null) {
      print('⚠️ _rewardedAd is null, initializing now...');
      _initializeAd();
      return;
    }

    if (_isLoading.value) return;

    _isLoading.value = true;
    _rewardedAd!.loadAd(); // Use !
  }

  // Method to show the rewarded ad
  Future<bool?> showRewardAd() async {
    if (!_adService.isInitialized.value || _rewardedAd == null) {
      print('Cannot show ad: SDK/AdObject not ready');
      Get.snackbar('Error', 'Ad system not ready yet');
      // Try to fix it for next time
      loadAd();
      return false;
    }

    if (await _rewardedAd!.isAdReady()) {
      _rewardedAd!.showAd(placementName: 'Default');
      return true;
    } else {
      print('Ad not ready, loading...');
      loadAd();
      // We don't show snackbar here because Utils handles the waiting dialog
      return false;
    }
  }

  // ---------------- LISTENERS ----------------

  @override
  void onAdRewarded(LevelPlayReward reward, LevelPlayAdInfo adInfo) {
    print('User rewarded with: $reward');
    onReward(reward);
    _isAdReady.value = false;
    loadAd();
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    print('Ad Load Failed: $error');
    _isLoading.value = false;
    _isAdReady.value = false;

    Future.delayed(Duration(seconds: 2), () => loadAd());
  }

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    print('Ad Loaded: $adInfo');
    _isLoading.value = false;
    _isAdReady.value = true;
  }

  @override
  void onAdClosed(LevelPlayAdInfo adInfo) {
    print('Ad Closed: $adInfo');
    _isAdReady.value = false;
    loadAd();
  }

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {
    print('Ad Clicked: $adInfo');
  }

  @override
  void onAdDisplayFailed(LevelPlayAdError error, LevelPlayAdInfo adInfo) {
    print('Ad Display Failed: $error');
    _isAdReady.value = false;
    loadAd();
  }

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {
    print('Ad Displayed: $adInfo');
  }

  @override
  void onAdInfoChanged(LevelPlayAdInfo adInfo) {
    print('Ad Info Changed: $adInfo');
  }
}
