import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../controller/ConfigController.dart';


class NativeAdExample extends StatefulWidget {
  const NativeAdExample({super.key});

  @override
  NativeAdExampleState createState() => NativeAdExampleState();
}

class NativeAdExampleState extends State<NativeAdExample> with AutomaticKeepAliveClientMixin{
  final ConfigController appConfig = Get.find();

  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;
  String get _adUnitId => Platform.isAndroid ? appConfig.config.value.nativeAndroidId : appConfig.config.value.nativeIosId;


  @override
  void initState() {
    super.initState();
    // _waitAndLoadNativeAd();
    // _waitConfigAndMaybeLoadNativeAd();
    loadAd();
  }


  // Future<void> _waitConfigAndMaybeLoadNativeAd() async {
  //   while (!appConfigController.isConfigLoaded.value) {
  //     await Future.delayed(Duration(milliseconds: 200));
  //   }
  //
  //   // 🔥 Only load Google Native if StartAppSource = yes
  //   if (appConfigController.adsConfig.value!.startappSource.toLowerCase() == "yes") {
  //     loadAd();
  //   }
  // }


  @override
  void dispose() {
    _nativeAd?.dispose(); // Dispose the ad to free up resources
    super.dispose();
  }


  /// Loads a native ad.
  void loadAd() {

    final id = _adUnitId;

    if (id.isEmpty) {
      debugPrint("❌ Native Ad ID empty. Retrying in 2 seconds...");
      Future.delayed(Duration(seconds: 2), loadAd);
      return;
    }
    _nativeAd = NativeAd(
      adUnitId: id,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugPrint('$NativeAd loaded.');
          setState(() {
            _nativeAdIsLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Dispose the ad here to free resources
          debugPrint('$NativeAd failed to load: $error');
          ad.dispose();
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        // Customize the ad's look and feel
        templateType: TemplateType.medium, // Choose the template (small, medium, or large)
        mainBackgroundColor: Colors.purple,
        cornerRadius: 10.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.cyan,
          backgroundColor: Colors.red,
          style: NativeTemplateFontStyle.monospace,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.red,
          backgroundColor: Colors.cyan,
          style: NativeTemplateFontStyle.italic,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.green,
          backgroundColor: Colors.black,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.brown,
          backgroundColor: Colors.amber,
          style: NativeTemplateFontStyle.normal,
          size: 16.0,
        ),
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Obx(() {
      final config = appConfig.config.value;

      // ⛔ If config not loaded yet → return placeholder
      // if (!appConfigController.isConfigLoaded.value || config == null) {
      //   return SizedBox.shrink();
      // }

      // ⛔ If StartApp source is not "yes" → DO NOT SHOW ANY AD
      // if (config.startappSource.toLowerCase() != "yes") {
      //   return SizedBox.shrink();
      // }

      // ✅ VALID → show Google Native Ad
      return Center(
        child: _nativeAdIsLoaded
            ? ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 320,
            minHeight: 320,
            maxWidth: 400,
            maxHeight: 400,
          ),
          child: AdWidget(ad: _nativeAd!),
        )
            : CircularProgressIndicator(),
      );
    });
  }


  @override
  bool get wantKeepAlive => true;
}
