import 'package:bounce/bounce.dart';
import 'package:cryptacore/const/app_images.dart';
import 'package:cryptacore/const/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../ad/admob/RewardAdController.dart';
import '../widget/DiagonalBorderPainter.dart';


class MiningBoosterDialog extends StatefulWidget {
  final Function() onTapButton;
  const MiningBoosterDialog({super.key, required this.onTapButton});

  @override
  State<MiningBoosterDialog> createState() => _MiningBoosterDialogState();
}

class _MiningBoosterDialogState extends State<MiningBoosterDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height,
      width: Get.width,
      color: Colors.black.withValues(alpha: 0.1),
      child: Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Center(
          child:Container(
            color: Colors.transparent,
            height:  350,
            width: 400,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  width: 350,
                  color: Colors.transparent,
                  padding: EdgeInsets.all( 40),
                  margin: EdgeInsets.only(top: 7),
                  child: CustomPaint(
                    painter: DiagonalBorderPainter(AppColor.greenGradient),
                    child: Container(
                      height: 200,
                      width: 200,
                      margin: const EdgeInsets.all(1), // Adjust based on border width
                      decoration: BoxDecoration(
                        color: AppColor.dialogBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        spacing: 15,
                        children: [
                          Text('Activate Mining\nBooster', textAlign:TextAlign.center,style: TextStyle(color: AppColor.greenColor,fontWeight: FontWeight.w400,fontSize: 28),),
                          Text(
                            'This booster increases your mining speed by 25%, Use it to maximize your earnings.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColor.grayColor,fontWeight: FontWeight.w400,fontSize: 14),),
                          Bounce(
                            onTap: () async {
                              Get.back();  // close dialog first

                              final rewardController = Get.find<RewardAdController>();

                              bool? result = await rewardController.showRewardAd();

                              if (result == null) {
                                Get.snackbar("Oops!", "Ad not available, please try again later.");
                                return;
                              }

                              if (result == true) {
                                widget.onTapButton();
                                Get.snackbar("Success!", "Boost Activated!");
                              }
                            },
                            child: Container(
                              width: 240,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: 13),
                              decoration: BoxDecoration(
                                color:  AppColor.greenColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                'Activate Speed Booster 25%',
                                style: TextStyle(color:  Colors.black),
                              ),
                            ),
                          ),

                          SizedBox(height: 10,),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  left: 0,height: 100,
                  child: SvgPicture.asset(AppSvg.boosterIcon),)
              ],
            ),
          ),
        ),
      ),
    );
  }
}





