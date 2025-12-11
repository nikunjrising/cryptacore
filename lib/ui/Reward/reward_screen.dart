import 'package:bounce/bounce.dart';
import 'package:cryptacore/const/app_images.dart';
import 'package:cryptacore/ui/Reward/OnRewardView.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../ad/admob/InterstitialAdService.dart';
import '../../const/color.dart';
import '../widget/DiagonalBorderPainter.dart';
import 'RewardController.dart';


class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  final rewardController = Get.find<RewardController>();
  final InterstitialAdService interstitialAdService = InterstitialAdService();

  final List<String> cardBg = [
    AppImages.rewardBg1,
    AppImages.rewardBg2,
    AppImages.rewardBg3,
    AppImages.rewardBg4,
    AppImages.rewardBg5,
  ];

  @override
  void initState() {
    super.initState();
    interstitialAdService.loadAd();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Reward',style: TextStyle(fontSize: 24,fontWeight: FontWeight.w400,color: AppColor.skyColor),),
        centerTitle: true,
      ),
      body: CustomPaint(
        painter: DiagonalBorderPainter(AppColor.skyGradient),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(horizontal: 15,vertical: 20),
          alignment: Alignment.center,

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Scratch and Win',style: TextStyle(color: AppColor.skyColor,fontSize: 24),),
              Expanded(child: Center(child: rewardView())),
            ],
          ),
        ),
      ),
    );
  }


  Widget rewardView() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 25),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        // Repeat images every 5
        final bgImage = cardBg[index % cardBg.length];
        return  Obx(() {
          bool claimed = rewardController.claimedCards[index];

          return Bounce(
            onTap: () {
              if (claimed) {
                Fluttertoast.showToast(msg: "You already received this reward 😊");
                return;
              }

              int rewardIndex = index % 3;

              String rewardType = rewardIndex == 1 ? "scratch"
                  : rewardIndex == 2 ? "wheel"
                  : "mystery";

              interstitialAdService.show(
                onClose: () {
                  Get.to(() => OnRewardView(
                    selectedCard: bgImage,
                    rewardType: rewardType,
                    cardIndex: index,
                  ));
                },
                onUnavailable: () {
                  Get.to(() => OnRewardView(
                    selectedCard: bgImage,
                    rewardType: rewardType,
                    cardIndex: index,
                  ));
                },
              );
            },
            child: Stack(
              children: [
                Image.asset(bgImage, fit: BoxFit.cover),
                if (claimed)
                  Center(
                    child: Text(
                      'Rewarded',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
              ],
            ),
          );
        });
      },
    );
  }
}
