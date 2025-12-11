import 'dart:io';

import 'package:bounce/bounce.dart';
import 'package:cryptacore/const/color.dart';
import 'package:cryptacore/controller/AuthController.dart';
import 'package:cryptacore/controller/ConfigController.dart';
import 'package:cryptacore/service/PreferenceHelper.dart';
import 'package:cryptacore/ui/intro_screens/on_boarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../ad/admob/BannerAdWidget.dart';
import '../../const/app_images.dart';
import '../../main.dart';
import '../spin_wheel/SpinningWheelPage.dart';
import '../widget/AppSnackBar.dart';
import '../widget/DiagonalBorderPainter.dart';

class ProfileItem {
  final String title;
  final String icon;

  const ProfileItem({
    required this.title,
    required this.icon,
  });
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController authController = Get.find();
  final ConfigController configController = Get.find();
  final List<ProfileItem> profileItem = [
    // ProfileItem(title: 'Notification', icon: AppSvg.notification),
    ProfileItem(title: 'Share', icon: AppSvg.share),
    ProfileItem(title: 'Privacy Policy', icon: AppSvg.privacyPolicy),
    ProfileItem(title: 'Terms & Condition', icon: AppSvg.termCon),
    ProfileItem(title: 'Logout', icon: AppSvg.logout),
    ProfileItem(title: 'Delete Account', icon: AppSvg.deleteAccount),
  ];


  void handleProfileClick(String title) {
    switch (title) {
      case 'Notification':
        // Get.to(() => NotificationScreen());  // create page if not exist
        break;

      case 'Share':
        ShareHelper.shareApp(Platform.isIOS ? configController.config.value.appStoreLink :configController.config.value.playStoreLink );   // using your share function
        break;

      case 'Privacy Policy':
        openUrl(configController.config.value.privacyPolicyUrl);
        break;

      case 'Terms & Condition':
        openUrl(configController.config.value.termsConditionsUrl);
        break;

      case 'Logout':
        Get.defaultDialog(
          title: "Logout",
          middleText: "Are you sure you want to logout?",
          textConfirm: "Yes",
          textCancel: "No",
          onCancel:   () {
            Get.back();
          },
          onConfirm: () {
            // Add logout logic here
            PreferenceHelper().clear();
            Get.offAll(OnBoardingScreen());
            AppSnackBar.show(
              title: "Logged Out",
              subtitle: "You have been logged out successfully",
            );
          },
        );
        break;

      case 'Delete Account':
        Get.defaultDialog(
          title: "Delete Account",
          middleText: "This action is permanent. Proceed?",
          textConfirm: "Delete",
          textCancel: "Cancel",
          confirmTextColor: Colors.white,
          onCancel: () {
            Get.back();
          },
          onConfirm: () {
           PreferenceHelper().clear();
           Get.offAll(OnBoardingScreen());
           AppSnackBar.show(
              title: "Deleted",
              subtitle: "Your account has been deleted",
            );
          },
        );
        break;

      default:
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Profile',style: TextStyle(fontSize: 24,fontWeight: FontWeight.w400,color: AppColor.skyColor),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            balanceSection(),
            ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 30),
              itemCount: profileItem.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                var item = profileItem[index];
                  return Column(
                    spacing: 5,
                    children: [
                      ListTile(
                        onTap: () {
                          handleProfileClick(item.title);
                        },
                        contentPadding: EdgeInsets.all(0),
                        leading: SvgPicture.asset(item.icon),
                        title: Text(item.title,style: TextStyle(color: AppColor.skyColor,fontSize: 18),),
                        trailing: Icon(Icons.arrow_forward_ios,color: AppColor.skyColor,size: 17,),

                      ),
                      Divider(color: AppColor.grayColor.withValues(alpha: 0.5),)
                    ],
                  );
                },
            ),
            BannerAdWidget()
          ],
        ),
      ),
    );
  }
  Widget balanceSection(){
    return CustomPaint(
      painter: DiagonalBorderPainter(AppColor.skyGradient),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(horizontal: 15,vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 15,
          children: [
            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.skyColor
              ),
              child: authController.currentUser!.isAnonymous
                  ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(AppSvg.guestIcon,),
              )
                  : ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(authController.currentUser!.photoURL.toString(),fit: BoxFit.fill,)),
            ),
            Column(
              spacing: 3,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(authController.currentUser?.displayName == null)
                  Text('Guest User',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 16),),
                if(authController.currentUser?.displayName != null)
                  Text('${authController.currentUser?.displayName}',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 16),),
                if(authController.currentUser?.displayName != null)
                  Text(authController.currentUser!.email.toString() ,style: TextStyle(color: AppColor.grayColor,fontWeight: FontWeight.w400,fontSize: 14),),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openUrl(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $url';
    }
  }


}

class ShareHelper {
  static void shareApp(String url) {
    final String playStoreLink = url; // <-- change this

    Share.share(
      "🚀 Check out this Cryptcore app!\n\nDownload now:\n$playStoreLink",
      subject: "Share My App",
    );
  }
}
