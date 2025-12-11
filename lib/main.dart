import 'package:cryptacore/controller/UserController.dart';
import 'package:cryptacore/service/PreferenceHelper.dart';
import 'package:cryptacore/ui/Reward/RewardController.dart';
import 'package:cryptacore/ui/intro_screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sizer/sizer.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';
import 'NotificationService.dart';
import 'ad/IronSource/IronSourceService.dart';
import 'ad/IronSource/ini_ad/IsIntAdController.dart';
import 'ad/IronSource/reward_ad/IsRewardAdController.dart';
import 'ad/admob/AppOpenAdManager.dart';
import 'ad/admob/RewardAdController.dart';
import 'controller/AuthController.dart';
import 'controller/ConfigController.dart';
import 'controller/MiningController.dart';
import 'firebase_options.dart';
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final AppOpenAdManager appOpenAdManager = AppOpenAdManager();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await MobileAds.instance.initialize();
  await NotificationService.initialize();
  // await NotificationService.getToken();
  // Get.put(ConnectivityController());
  Get.put(ConfigController());

  // Future.delayed(const Duration(seconds: 2), () {
  //   appOpenAdManager.loadAd();
  // });


  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(testDeviceIds: ['16DABDC131ED249DF7B938D113C6D3B3']),
  );


  await PreferenceHelper().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          scaffoldMessengerKey: scaffoldMessengerKey,
          debugShowCheckedModeBanner: false,
          title: 'CryptaCore',
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(0.8),   // 👈 force text scale to 1
              ),
              child: child!,
            );
          },
          theme: ThemeData(
            fontFamily: 'Orbitron',
            scaffoldBackgroundColor: Colors.black,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
          ),
          // home: const SpinningWheelPage(),
          home: const SplashScreen(),
          // home: const LoginScreen(),
          // home: const Dashboard(),
          // home: MiningScreen(),
          onInit: () {
            Get.put(UserController());
            Get.put(AuthController());
            Get.put(MiningController());
            Get.put(RewardAdController());
            Get.put(RewardController());

            Get.put(IronSourceService());
            Get.put(IsRewardAdController(onReward: (LevelPlayReward reward) {  }));
            Get.put(IsIntAdController());
            // Get.put(NativeAdController());
            // Get.put(BannerAdController());
          },
        );
      },
    );
  }
}
