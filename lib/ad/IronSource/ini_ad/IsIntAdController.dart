import 'dart:io';
import 'package:get/get.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';
import '../IronSourceService.dart';

class IsIntAdController extends GetxController with LevelPlayInterstitialAdListener {

  // Debug logging helper
  void printLog(String message) {
    print('🔵 [IronSource] $message');
  }

  // Interstitial Ad States
  final RxBool _isInterstitialAdReady = false.obs;
  final RxBool _isInterstitialAdLoading = false.obs;

  bool get isInterstitialAdReady => _isInterstitialAdReady.value;
  bool get isInterstitialAdLoading => _isInterstitialAdLoading.value;

  // Ad Instances
  late LevelPlayInterstitialAd _interstitialAd;

  // Callbacks
  late void Function() onInterstitialClosed;

  // Service
  final IronSourceService _adService = Get.find<IronSourceService>();

  // Constructor with default callbacks
  IntAdController({
    void Function()? onInterstitialClosed,
  }) {
    this.onInterstitialClosed = onInterstitialClosed ?? () {
      printLog('Default interstitial closed handler');
    };
  }

  @override
  void onInit() {
    super.onInit();
    printLog('Ad Controller Initialized');

    // Check if SDK is already initialized
    if (_adService.isInitialized.value) {
      printLog('SDK already initialized, setting up ads...');
      _initializeAds();
    } else {
      // Wait for SDK initialization
      ever(_adService.isInitialized, (isInitialized) {
        if (isInitialized == true) {
          printLog('SDK initialized, setting up ads...');
          _initializeAds();
        }
      });
    }
  }

  void _initializeAds() {
    printLog('Initializing ads...');

    try {
      // Initialize Interstitial Ad
      _interstitialAd = LevelPlayInterstitialAd(adUnitId: _getInterstitialAdUnitId());
      _interstitialAd.setListener(this);
      printLog('Interstitial Ad initialized with ID: ${_getInterstitialAdUnitId()}');

      // Load interstitial ad
      Future.delayed(Duration(milliseconds: 500), () {
        loadInterstitialAd();
      });

    } catch (e) {
      printLog('Error initializing ads: $e');
    }
  }

  // ============== INTERSTITIAL AD METHODS ==============

  void loadInterstitialAd() {
    if (!_adService.isInitialized.value) {
      printLog('❌ Cannot load interstitial ad: SDK not initialized');
      return;
    }

    if (_isInterstitialAdLoading.value) return;

    printLog('🔄 Loading Interstitial Ad...');
    _isInterstitialAdLoading.value = true;
    _interstitialAd.loadAd();
  }

  Future<bool?> showInterstitialAd() async {
    if (!_adService.isInitialized.value) {
      printLog('❌ Cannot show interstitial ad: SDK not initialized');
      Get.snackbar('Error', 'Ad system not ready yet');
      return false;
    }

    if (await _interstitialAd.isAdReady()) {
      _interstitialAd.showAd(placementName: 'DefaultInterstitial');
      return true;
    } else {
      printLog('Interstitial ad not ready, loading...');
      loadInterstitialAd();
      Get.snackbar('Info', 'Interstitial ad is loading');
      return false;
    }
  }

  // ============== AD UNIT IDs ==============
  String _getInterstitialAdUnitId() {
    return Platform.isAndroid
        ? 'aeyqi3vqlv6o8sh9'
        : 'wmgt0712uuux8ju4';
  }

  // ============== INTERSTITIAL AD LISTENERS ==============
  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    printLog('✅ INTERSTITIAL Loaded Successfully');
    _isInterstitialAdLoading.value = false;
    _isInterstitialAdReady.value = true;
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    printLog('❌ INTERSTITIAL Load Failed: ${error.errorCode} - ${error.errorMessage}');
    _isInterstitialAdLoading.value = false;
    _isInterstitialAdReady.value = false;
    // Retry after 5 seconds
    Future.delayed(Duration(seconds: 5), () => loadInterstitialAd());
  }

  @override
  void onAdClosed(LevelPlayAdInfo adInfo) {
    printLog('🚪 INTERSTITIAL Ad Closed');
    _isInterstitialAdReady.value = false;
    onInterstitialClosed();
    // Load next interstitial ad after 3 seconds
    Future.delayed(Duration(seconds: 3), () => loadInterstitialAd());
  }

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {
    printLog('👆 INTERSTITIAL Ad Clicked');
  }

  @override
  void onAdDisplayFailed(LevelPlayAdError error, LevelPlayAdInfo adInfo) {
    printLog('❌ INTERSTITIAL Display Failed: ${error.errorMessage}');
    _isInterstitialAdReady.value = false;
    loadInterstitialAd();
  }

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {
    printLog('📺 INTERSTITIAL Ad Displayed');
  }

  @override
  void onAdInfoChanged(LevelPlayAdInfo adInfo) {
    printLog('ℹ️ INTERSTITIAL Info Changed');
  }

  // Debug method
  void debugAdStatus() {
    printLog('===== DEBUG AD STATUS =====');
    printLog('SDK Initialized: ${_adService.isInitialized.value}');
    printLog('Interstitial - Loading: $_isInterstitialAdLoading, Ready: $_isInterstitialAdReady');
    printLog('===========================');
  }
}

