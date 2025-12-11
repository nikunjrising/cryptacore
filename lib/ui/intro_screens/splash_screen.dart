import 'package:cryptacore/const/app_images.dart';
import 'package:cryptacore/const/color.dart';
import 'package:cryptacore/service/PreferenceHelper.dart';
import 'package:cryptacore/ui/intro_screens/on_boarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../controller/AuthController.dart';
import '../auth/login.dart';
import '../dashboard/dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    // Fade animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),  // fade duration
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward(); // start fade animation

    // Navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      // Get.off(OnBoardingScreen());
      _navigateUser();
    });
  }

  void _navigateUser() async {
    // Check if user is logged in (Google or Guest)
    final isLoggedIn = AuthController.instance.isSignedIn;

    // Check onboarding complete?
    final onboardingDone = PreferenceHelper().getBool(PreferenceKeys.onboardingDone) ?? false;

    if (isLoggedIn) {
      // User already logged in
      Get.off(() => Dashboard());
    }
    else if (!onboardingDone) {
      // User never completed onboarding
      Get.off(() => OnBoardingScreen());
    }
    else {
      // User completed onboarding but not logged in
      Get.off(() => LoginScreen());
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.bgApp),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fadeAnim,
              child: SvgPicture.asset(
                AppSvg.appIcon,
                height: 160,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'CRYPTACORE',
              style: TextStyle(
                  color: AppColor.skyColor,
                  fontSize: 30),
            ),

            Text(
              'Mine Solana. Master Crypto.',
              style: TextStyle(
                  color: AppColor.grayColor,
                  fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
