import 'package:bounce/bounce.dart';
import 'package:cryptacore/const/app_images.dart';
import 'package:cryptacore/const/color.dart';
import 'package:cryptacore/ui/mining/mining_booster_dialog.dart';
import 'package:cryptacore/ui/mining/spin_wheel_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../const/AnimatedFlipperText.dart';
import '../../controller/AuthController.dart';
import '../../controller/MiningController.dart';
import '../../service/PreferenceHelper.dart';
import '../spin_wheel/SpinningWheelPage.dart';
import '../widget/DiagonalBorderPainter.dart';

class MiningScreen extends StatefulWidget {
  const MiningScreen({super.key});

  @override
  State<MiningScreen> createState() => _MiningScreenState();
}

class _MiningScreenState extends State<MiningScreen> {
  final AuthController authController = Get.find();
  final MiningController miningController = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _showSpinWheelOncePerDay();
    });
  }

  Future<void> _showSpinWheelOncePerDay() async {
    final prefs = PreferenceHelper();

    final lastSpinMillis = prefs.getInt(PreferenceKeys.lastSpinTime);
    final now = DateTime.now();

    if (lastSpinMillis != null) {
      final lastSpin = DateTime.fromMillisecondsSinceEpoch(lastSpinMillis);
      final difference = now.difference(lastSpin);

      if (difference.inHours < 24) {
        // less than 24 hours, don't show
        return;
      }
    }

    // Show the SpinWheel dialog
    Get.dialog(
      SpinWheelDialog(onTapButton: () {
        Get.back();
        Get.to(SpinningWheelPage());
      }),
      barrierDismissible: true,
    );

    // Save current timestamp
    await prefs.setInt(PreferenceKeys.lastSpinTime, now.millisecondsSinceEpoch);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          spacing: 20,
          children: [
            profileSection(),
            balanceSection(),
            miningBooster(),
            inviteFRDSection(),
            miningActivated(),
            SizedBox(height: 50,)
          ],
        ),
      ),
    );
  }

  profileSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 15,
      children: [
        Container(
          height: 45,
          width: 45,
          margin: EdgeInsets.only(top: 25),
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
        if(authController.currentUser!.isAnonymous)
        Padding(
          padding:  EdgeInsets.only(top: 35),
          child: Text('Guest User',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 16),),
        ),

        if(!authController.currentUser!.isAnonymous)
        Padding(
          padding:  EdgeInsets.only(top: 27),
          child: Column(
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
        ),
        Spacer(),
        Bounce(
          onTap: () {
            Get.to(SpinningWheelPage());

            // Fluttertoast.showToast(msg: 'Available soon....!🚀');
          },
          child: Container(
            height: 50,
            width: 50,
            alignment: Alignment.center,
            child: Lottie.asset(
              'assets/json/spin_wheel.json', // Replace with your file path
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget balanceSection(){
    return Obx( () {
      return  CustomPaint(
        painter: DiagonalBorderPainter(AppColor.skyGradient),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(horizontal: 15,vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 15,
            children: [
              Text('Current Balance',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 14),),
            AnimatedFlipperText(
              value: miningController.currentMining.value.toStringAsFixed(6),
              fractionDigits: 8,
              fontSize: 25,
              color: AppColor.skyColor,
            ),
              // Text('0.000005 USDT',style: TextStyle(color: AppColor.skyColor,fontWeight: FontWeight.w400,fontSize: 25),),
              Container(
                  padding: EdgeInsets.symmetric(vertical: 8,horizontal: 11),
                  decoration: BoxDecoration(
                      border: Border.all(color: AppColor.skyColor,width: 1),
                      borderRadius: BorderRadius.circular(30)
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 5,
                    children: [
                      Text('Remaining Time:',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 10),),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    miningController.formattedRemaining(),
                    key: ValueKey(miningController.formattedRemaining()),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),

                ],
                  )),
                  // child: Text('Earning Rate +0.000005 USDT/HR',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 10),)),
              CustomPaint(
                painter: DiagonalBorderPainter(AppColor.skyGradient),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 5,
                        children: [
                          Text('Mining Rate / Sec:',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 12),),
                          AnimatedFlipperText(
                            value: miningController.currentRatePerSecond().toStringAsFixed(8),
                            fractionDigits: 8,
                            fontSize: 13,
                            color: AppColor.skyColor,
                          ),
                        ],
                      ),
                      SvgPicture.asset(AppSvg.dividerSky),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 5,

                        children: [
                          Text('Mining Rate / Day:',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 12),),
                          AnimatedFlipperText(
                            value: (miningController.currentRatePerSecond() * 86400).toStringAsFixed(6),
                            fractionDigits: 8,
                            fontSize: 13,
                            color: AppColor.skyColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    );
  }

  Widget miningBooster(){
    return CustomPaint(
      painter: DiagonalBorderPainter(AppColor.greenGradient),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SvgPicture.asset(AppSvg.icBoosterIconBoarder),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mining Booster',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 12),),
                    Text('BOOST SPEED',style: TextStyle(color: AppColor.greenColor,fontWeight: FontWeight.w400,fontSize: 18),),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Increase rate by ",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: "25%",
                            style: TextStyle(
                              color: AppColor.greenColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )

                  ],
                ),
              ],
            ),
            Bounce(
              onTap: () {

                // miningController.isMining.value ? miningController.applyAdBoost : null;
                Get.dialog(
                  MiningBoosterDialog(
                    onTapButton: () async {
                      if (miningController.isMining.value) {
                        bool ok = await miningController.applyAdBoost();

                        if (ok) {
                          Fluttertoast.showToast(msg: "Boost Applied!");
                          setState(() {}); // refresh speed UI
                        } else {
                          Fluttertoast.showToast(msg: "Daily limit reached");
                        }
                      }
                    },
                  )
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 13,horizontal: 70),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.skyColor,width: 1),
                    borderRadius: BorderRadius.circular(30),
                    color: AppColor.greenColor
                  ),
                  child: Text('Booster Activated',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400,fontSize: 17),)),
            ),
          ],
        ),
      ),
    );
  }

  inviteFRDSection() {
    return Bounce(
      onTap: () {
        Fluttertoast.showToast(msg: 'Available soon..');
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(AppImages.bgReferal)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColor.purpleColor,width: 1)
        ),
        padding: EdgeInsets.all(5),
        child: ListTile(
           leading: SvgPicture.asset(AppSvg.icFriends),
          title: Text('Invite Friends',style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w500),),
          subtitle: Text('Earn more extra by inviting friends',style: TextStyle(color: AppColor.grayColor,fontSize: 14,fontWeight: FontWeight.w400),),

        ),
      ),
    );
  }

  Widget miningActivated(){
    return Obx(() {

      final total = miningController.totalSessionSeconds.value;

      final remaining = miningController.remainingSeconds.value;

      double percent = total == 0 ? 0 : (total - remaining) / total * 100;

      return CustomPaint(
        painter: DiagonalBorderPainter(AppColor.skyGradient),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(horizontal: 15,vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 15,
            children: [
              CircularPercentIndicator(
                radius: 120.0,
                lineWidth: 13.0,
                animation: true,
                percent: miningController.totalSessionSeconds.value == 0
                    ? 0
                    : (miningController.totalSessionSeconds.value -
                    miningController.remainingSeconds.value) /
                    miningController.totalSessionSeconds.value,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        miningController.formattedRemaining(),
                        key: ValueKey(miningController.formattedRemaining()),
                        style: const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    Text("Time Remaining", style:  TextStyle(fontWeight: FontWeight.w400, fontSize: 20.0),),
                  ],
                ),
                footer: Padding(
                  padding: const EdgeInsets.only(top:10),
                  child: Text("${percent.toStringAsFixed(2)}%", style:  TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),),
                ),

                circularStrokeCap: CircularStrokeCap.round,
                progressColor: AppColor.skyColor,
              ),
              CustomPaint(
                painter: DiagonalBorderPainter(AppColor.skyGradient),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 5,
                        children: [
                          Text('Total Earning',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 12),),
                          AnimatedFlipperText(
                            value: miningController.currentMining.value.toStringAsFixed(6),
                            fractionDigits: 8,
                            fontSize: 13,
                            color: AppColor.skyColor,
                          ),                      ],
                      ),
                      SvgPicture.asset(AppSvg.dividerSky),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 5,
                        children: [
                          Text('Mining Rate / Hour:',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 12),),
                          AnimatedFlipperText(
                            value: (miningController.currentRatePerSecond() * 3600).toStringAsFixed(6),
                            fractionDigits: 8,
                            fontSize: 13,
                            color: AppColor.skyColor,
                          ),                      ],
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      );
    },);
  }

}
