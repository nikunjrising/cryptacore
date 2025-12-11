import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../controller/ConfigController.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  BannerAdWidgetState createState() => BannerAdWidgetState();
}

class BannerAdWidgetState extends State<BannerAdWidget>
    with AutomaticKeepAliveClientMixin {
  final ConfigController appConfig = Get.find();

  BannerAd? _bannerAd;
  bool _isLoaded = false;

  String get _adUnitId => Platform.isAndroid
      ? appConfig.config.value.bannerAndroidId
      : appConfig.config.value.bannerIosId;

  @override
  void initState() {
    super.initState();
    loadBanner();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void loadBanner() {
    final id = _adUnitId;

    if (id.isEmpty) {
      debugPrint("❌ Banner Ad ID empty → retrying...");
      Future.delayed(Duration(seconds: 2), loadBanner);
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: id,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint("Banner Ad Loaded!");
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint("Banner Ad Failed to Load → $error");
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Obx(() {
      final config = appConfig.config.value;

      // ❌ If config not loaded → hide
      // if (!appConfig.isConfigLoaded.value) return SizedBox.shrink();

      // ❌ If StartApp disabled → hide banner
      // if (config.startappSource.toLowerCase() != "yes") {
      //   return SizedBox.shrink();
      // }

      return Center(
        child: _isLoaded
            ? SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        )
            : const SizedBox(height: 0),
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}
