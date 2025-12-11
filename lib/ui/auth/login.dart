import 'package:bounce/bounce.dart';
import 'package:cryptacore/const/app_images.dart';
import 'package:cryptacore/const/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../controller/AuthController.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(AppImages.bgApp),
                fit: BoxFit.fill
            )
        ),
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(AppSvg.appIcon, height: 150),
            Text(
              'Welcome',
              style: TextStyle(
                  color: AppColor.skyColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w400
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Login to continue mining',
              style: TextStyle(
                  color: AppColor.grayColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w400
              ),
            ),
            SizedBox(height: 15),

            // Error Message
            Obx(() => authController.errorMessage.isNotEmpty
                ? Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Text(
                authController.errorMessage.value,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            )
                : SizedBox.shrink()),

            // Google Sign In Button
            Obx(() => Bounce(
              onTap: authController.isGoogleLoading.value
                  ? null
                  : () async {
                await authController.signInWithGoogle();
              },
              child: Container(
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColor.grayColor.withOpacity(0.5)
                  ),
                  color: authController.isGoogleLoading.value
                      ? Colors.grey.withOpacity(0.3)
                      : Colors.transparent,
                ),
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (authController.isGoogleLoading.value)
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColor.skyColor,
                          ),
                        ),
                      )
                    else
                      Image.asset(AppImages.googleIcon),

                    SizedBox(width: authController.isGoogleLoading.value ? 15 : 30),

                    Text(
                      authController.isGoogleLoading.value
                          ? 'Signing in...'
                          : 'Login with Google',
                      style: TextStyle(
                        fontSize: 18,
                        color: authController.isGoogleLoading.value
                            ? Colors.grey
                            : Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            )),

            SizedBox(height: 30),

            // Guest Sign In Button
            Obx(() => Bounce(
              onTap: authController.isGuestLoading.value
                  ? null
                  : () async {
                await authController.signInAsGuest();
              },
              child: Container(
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColor.grayColor.withOpacity(0.5)
                  ),
                  color: authController.isGuestLoading.value
                      ? Colors.grey.withOpacity(0.3)
                      : Colors.transparent,
                ),
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (authController.isGuestLoading.value)
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColor.skyColor,
                          ),
                        ),
                      )
                    else
                      SvgPicture.asset(AppSvg.guestIcon),

                    SizedBox(width: authController.isGuestLoading.value ? 15 : 30),

                    Text(
                      authController.isGuestLoading.value
                          ? 'Signing in...'
                          : 'Continue as Guest',
                      style: TextStyle(
                        fontSize: 18,
                        color: authController.isGuestLoading.value
                            ? Colors.grey
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}