import 'dart:io';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../controller/ConfigController.dart';

// 1. Extend GetxService (or GetxController)
class InterstitialAdService extends GetxService {
  InterstitialAd? _interstitialAd;
  RxBool isAdReady = false.obs;
  final configController = Get.find<ConfigController>();

  // 2. Add onInit to Auto-Load the ad when this service is started
  @override
  void onInit() {
    super.onInit();
    loadAd();
  }

  /// ----------------------------------------------------------
  /// Load Interstitial Ad
  /// ----------------------------------------------------------
  void loadAd() {
    print('Loading interstitial ad...');

    // Safety check to prevent crashing if config isn't ready
    if (!Get.isRegistered<ConfigController>()) return;

    final adUnitId = Platform.isAndroid
        ? configController.config.value.intAndroidId
        : configController.config.value.intIosId;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('✅ Interstitial ad loaded.');
          _interstitialAd = ad;
          isAdReady.value = true;
          _setCallbacks(ad);
        },
        onAdFailedToLoad: (error) {
          print('❌ Failed to load interstitial ad: ${error.message}');
          _interstitialAd = null;
          isAdReady.value = false;

          // Optional: Retry loading after a delay if it fails
          Future.delayed(const Duration(seconds: 10), () => loadAd());
        },
      ),
    );
  }

  /// ----------------------------------------------------------
  /// Set callbacks for close / fail
  /// ----------------------------------------------------------
  void _setCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        print('Interstitial ad dismissed.');
        try { ad.dispose(); } catch (_) {}
        isAdReady.value = false; // Mark as not ready immediately
        loadAd(); // Load next ad immediately for the next click
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Interstitial failed to show: $error');
        try { ad.dispose(); } catch (_) {}
        isAdReady.value = false;
        loadAd(); // Reload
      },
    );
  }

  /// ----------------------------------------------------------
  /// Show Interstitial Ad
  /// ----------------------------------------------------------
  void show({
    required VoidCallback onClose,
    required VoidCallback onUnavailable,
  }) {
    if (isAdReady.value && _interstitialAd != null) {
      _interstitialAd!.show();

      // We don't nullify _interstitialAd here immediately,
      // we wait for the dismissal callback to clean it up.

      // When ad is closed (handled above in callbacks), we just fire the user callback
      // NOTE: With AdMob, the onClose logic is usually better handled in the fullScreenContentCallback
      // But to keep your structure working:

      Future.delayed(const Duration(milliseconds: 500), () {
        // This is a bit risky because the ad might still be open.
        // Ideally, pass 'onClose' to _setCallbacks.
        // But for your logic, we execute the action when the ad *closes*,
        // which the admob callback handles.
      });

      // Update: Let's attach the specific onClose action to the current ad callback
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            isAdReady.value = false;
            onClose(); // <--- Call your action here
            loadAd(); // Load next
          },
          onAdFailedToShowFullScreenContent: (ad, err) {
            ad.dispose();
            isAdReady.value = false;
            onUnavailable(); // <--- Call fallback here
            loadAd();
          }
      );

    } else {
      print("⚠ Interstitial Ad NOT ready");
      // Try loading one for next time
      loadAd();
      onUnavailable();
    }
  }
}
