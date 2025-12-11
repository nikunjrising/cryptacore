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

  late LevelPlayRewardedAd _rewardedAd;
  late void Function(LevelPlayReward reward) onReward;

  // Use Get.find to get the service
  final IronSourceService _adService = Get.find<IronSourceService>();

  // Constructor
  IsRewardAdController({required this.onReward});

  @override
  void onInit() {
    super.onInit();
    // Wait for SDK initialization
    ever(_adService.isInitialized, (isInitialized) {
      if (isInitialized) {
        _initializeAd();
      }
    });
  }

  void _initializeAd() {
    print('Initializing rewarded ad...');
    _rewardedAd = LevelPlayRewardedAd(adUnitId: _getRewardedAdUnitId());
    _rewardedAd.setListener(this);
    loadAd(); // Load the ad after SDK is initialized
  }

  String _getRewardedAdUnitId() {
    return Platform.isAndroid
        ? '76yy3nay3ceui2a3'  // Android Ad Unit ID
        : 'qwouvdrkuwivay5q'; // iOS Ad Unit ID
  }

  // Method to load the rewarded ad
  void loadAd() {
    if (!_adService.isInitialized.value) {
      print('Cannot load ad: SDK not initialized');
      return;
    }

    if (_isLoading.value) return; // Prevent multiple loads

    _isLoading.value = true;
    _rewardedAd.loadAd();
  }

  // Method to show the rewarded ad
  Future<bool?> showRewardAd() async {
    if (!_adService.isInitialized.value) {
      print('Cannot show ad: SDK not initialized');
      Get.snackbar('Error', 'Ad system not ready yet');
      return false;
    }

    if (await _rewardedAd.isAdReady()) {
      _rewardedAd.showAd(placementName: 'Default');
      return true;
    } else {
      print('Ad not ready, loading...');
      loadAd();
      Get.snackbar('Ad Loading', 'Please wait while we load the ad');
      return false;
    }
  }

  // ---------------- LISTENERS ----------------

  @override
  void onAdRewarded(LevelPlayReward reward, LevelPlayAdInfo adInfo) {
    print('User rewarded with: $reward');
    onReward(reward); // Call the dynamic reward handler
    _isAdReady.value = false; // Reset ad state
    loadAd(); // Load next ad
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    print('Ad Load Failed: $error');
    _isLoading.value = false;
    _isAdReady.value = false;

    // Retry after 2 seconds if failed
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
    loadAd(); // Load next ad when closed
  }

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {
    print('Ad Clicked: $adInfo');
  }

  @override
  void onAdDisplayFailed(LevelPlayAdError error, LevelPlayAdInfo adInfo) {
    print('Ad Display Failed: $error');
    _isAdReady.value = false;
    loadAd(); // Try loading again
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