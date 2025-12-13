import 'package:bounce/bounce.dart';
import 'package:cryptacore/const/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';

import '../../ad/admob/NativeAdExample.dart';
import '../../const/RewardService.dart';
import '../../const/app_images.dart';
import '../../controller/MiningController.dart';
import '../../utils/utils.dart';
import '../widget/AppSnackBar.dart';
import 'RewardController.dart';

class OnRewardView extends StatefulWidget {
  final String selectedCard;
  final String rewardType; // scratch / wheel / mystery
  final int cardIndex;


  const OnRewardView({
    super.key,
    required this.selectedCard,
    required this.rewardType, required this.cardIndex,
  });

  @override
  State<OnRewardView> createState() => _OnRewardViewState();
}

class _OnRewardViewState extends State<OnRewardView> {
  final MiningController miningController = Get.find();
  final rewardController = Get.find<RewardController>();

  double? rewardAmount;
  bool revealed = false;
  bool loading = true;


  @override
  void initState() {
    super.initState();
    _generateReward();
  }

  Future<void> _generateReward() async {
    rewardAmount = await RewardService.generateReward();
    await Future.delayed(const Duration(seconds: 1));
    setState(() => loading = false);
  }

  // ─────────────────────────────────────────────────────────────
  // DIALOG BEFORE REVEAL
  // ─────────────────────────────────────────────────────────────
  void _showRevealAdDialog() {
    Get.defaultDialog(
      title: "Watch Ad",
      middleText: "Watch a short ad to reveal your reward.",
      titleStyle: TextStyle(color: AppColor.skyColor),
      barrierDismissible: false,
      backgroundColor: AppColor.dialogBgColor,
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            Get.back();

            // final rewardController = Get.find<RewardAdController>();
            //
            // bool? result = await rewardController.showRewardAd();
            //
            // if (result == true) {
            //   setState(() => revealed = true);
            // } else {
            //   Fluttertoast.showToast(msg: "Better luck next time 😊");
            // }

            ShowRewardAd().show(
                onReward: () async {
                  setState(() => revealed = true);
                },
                onFailed: () {
                  AppSnackBar.show(
                      title: 'Ad Failed',
                      subtitle: 'Try after some time',
                      backgroundColor: Colors.red.withValues(alpha: 0.5)
                  );
                }
            );
          },
          child: const Text("Watch Ad"),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CLAIM LOGIC
  // ─────────────────────────────────────────────────────────────
  Future<void> _claimReward() async {
    if (rewardAmount == null) {
      Fluttertoast.showToast(msg: "Better luck next time 😊");
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    miningController.setEarnedByReward(rewardAmount!.toDouble());
    await rewardController.setClaimed(widget.cardIndex);

    // await RewardService.addRewardToUser(uid, rewardAmount!);
    if (rewardAmount == null) {
      Fluttertoast.showToast(msg: "Better luck next time 😊");
    } else {
      Fluttertoast.showToast(msg: "Reward Received: ${rewardAmount!.toStringAsFixed(6)}");
    }
    Get.back();
  }

  // ─────────────────────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(AppImages.bgApp), fit: BoxFit.fill)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leadingWidth: 48,
            leading: Bounce(
              onTap: () => Get.back(),
              child: Padding(
                padding: const EdgeInsets.only(left: 15, top: 5),
                child: SvgPicture.asset(AppSvg.backBtn),
              ),
            ),
            title: Text('Rewards', style: TextStyle(color: AppColor.skyColor)),
            centerTitle: true,
          ),
          body: loading
              ? Center(child: CircularProgressIndicator())
              : Center(
              child: SingleChildScrollView(
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Total Reward : ',style: TextStyle(fontSize: 20),),
                          Obx(() {
                            return Text(miningController.earnedByReward.toString(),style: TextStyle(fontSize: 20),);
                          },),
                        ],
                      ),

                      SizedBox(height: 25,),
                
                     _rewardContent(),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 25),
                        child: NativeAdExample(),
                      )
                ]),
              )
          ),
        ),
      ),
    );
  }

  Widget _rewardContent() {
    // BEFORE REVEAL
    if (!revealed) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
          alignment: Alignment.center,
            children: [
          Image.asset(widget.selectedCard,height: 30.h, fit: BoxFit.fill,),
              if(!revealed)
          Center(
            child: Opacity(
              opacity: 0.7,
              child: Lottie.asset(
                'assets/json/reward_light_effect.json', // Replace with your file path
                width: 250,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ]),
          SizedBox(height: 30),
          Bounce(
            // onTap: _showRevealAdDialog, // 👈 IMPORTANT CHANGE
            onTap: () {
              ShowRewardAd().show(
                  onReward: () async {
                    setState(() => revealed = true);
                  },
                  onFailed: () {
                    AppSnackBar.show(
                        title: 'Ad Failed',
                        subtitle: 'Try after some time',
                        backgroundColor: Colors.red.withValues(alpha: 0.5)
                    );
                  }
              );
            }, // 👈 IMPORTANT CHANGE
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColor.skyGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text("Reveal Reward",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ),
          if(revealed)
            Lottie.asset(
              'assets/json/reward_got.json', // Replace with your file path
              width: 400,
              height: 200,
              fit: BoxFit.cover,
            ),
        ],
      );
    }

    // AFTER REVEAL
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (rewardAmount == null)
          Column(
            children: [
              Text("Better Luck Next Time!",
                  style: TextStyle(color: Colors.redAccent, fontSize: 22)),
            ],
          )
        else
          Column(
            children: [
              Text("You Won!",
                  style: TextStyle(color: AppColor.skyColor, fontSize: 28)),
              SizedBox(height: 10),
              Text("${rewardAmount!.toStringAsFixed(6)} SOL",
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ],
          ),
        SizedBox(height: 40),
        Bounce(
          onTap: _claimReward,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppColor.skyGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text("Collect Reward",
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ),
        Lottie.asset(
            'assets/json/reward_got.json', // Replace with your file path
            width: 400,
            height: 200,
            fit: BoxFit.cover,
          ),
      ],
    );
  }
}
