import 'dart:io';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../controller/ConfigController.dart';


class InterstitialAdService {
  InterstitialAd? _interstitialAd;
  bool isAdReady = false;
  final configController = Get.find<ConfigController>();


  /// ----------------------------------------------------------
  /// Load Interstitial Ad
  /// ----------------------------------------------------------
  void loadAd() {
    print('Loading interstitial ad...');
    final adUnitId = Platform.isAndroid
        ? configController.config.value.intAndroidId
        : configController.config.value.intIosId;

    InterstitialAd.load(
      // adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('✅ Interstitial ad loaded.');
          _interstitialAd = ad;
          isAdReady = true;
          _setCallbacks(ad);
        },
        onAdFailedToLoad: (error) {
          print('❌ Failed to load interstitial ad: ${error.message}');
          _interstitialAd = null;
          isAdReady = false;
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
        loadAd(); // Load next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Interstitial failed to show: $error');
        try { ad.dispose(); } catch (_) {}
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
    if (isAdReady && _interstitialAd != null) {
      _interstitialAd!.show();

      // After showing, reset
      isAdReady = false;
      _interstitialAd = null;

      // When ad is closed (handled above), call callback
      Future.delayed(const Duration(milliseconds: 100), () {
        onClose();
      });
    } else {
      print("⚠ Interstitial Ad NOT ready");
      onUnavailable();
    }
  }
}
