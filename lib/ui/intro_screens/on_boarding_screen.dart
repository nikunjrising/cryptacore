import 'dart:io';

import 'package:cryptacore/const/app_images.dart';
import 'package:cryptacore/ui/dashboard/dashboard.dart';
import 'package:cryptacore/ui/intro_screens/select_country_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../const/color.dart';
import '../../model/OnBModel.dart';
import '../../service/PreferenceHelper.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      await PreferenceHelper().setBool(PreferenceKeys.onboardingDone, true);

      Get.off(SelectCountryScreen());

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: true,
        child: Stack(
          fit: StackFit.expand,
          children: [
            /// --- PageView (Background + Page Content) ---
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: onboardingData.length,
              itemBuilder: (context, index) {
                final data = onboardingData[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    /// --- Background ---
                    Image.asset(
                      data.bg,
                      fit: BoxFit.cover,
                    ),

                    /// --- Page Content ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 75),

                          /// --- Logo Section ---
                          SvgPicture.asset(
                            data.logo,
                            width: Platform.isIOS ? 40.w : 60.w,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            data.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: data.color,
                              fontSize: 28,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 11),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: data.color,width: 1),
                              color: data.color.withValues(alpha: 0.05)
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 10,
                              children: [
                                Text(
                                  data.title2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SvgPicture.asset(data.subLogo)
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              data.subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColor.grayColor,
                                fontSize: 16,
                                height: 1.4,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),


            /// back button
            if (_currentPage != 0)
              Positioned(
                top: 12.w,
                left: 5.w,
                child: Transform.scale(
                  scale: 0.8,
                  child: InkWell(
                    onTap: () {
                      if (_currentPage > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: SvgPicture.asset(
                      AppSvg.backBtn,
                      colorFilter:  ColorFilter.mode(
                        _currentPage == 0 ? AppColor.pinkColor :_currentPage == 1 ? AppColor.skyColor: _currentPage == 2 ? AppColor.greenColor : AppColor.purpleColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),

            /// --- Page Indicator + Static Button (Fixed at Bottom) ---
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                          (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 10,
                        width: _currentPage == i ? 40 : 10,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? onboardingData[_currentPage].color
                              : Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: _nextPage,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: onboardingData[_currentPage].color,
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          _currentPage == onboardingData.length - 1
                              ? "Get Started"
                              : "Next",
                          style: TextStyle(
                            color: onboardingData[_currentPage].color,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
