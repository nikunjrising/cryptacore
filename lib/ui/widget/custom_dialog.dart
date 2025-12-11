import 'package:bounce/bounce.dart';
import 'package:cryptacore/const/app_images.dart';
import 'package:cryptacore/const/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'DiagonalBorderPainter.dart';

class CustomDialog extends StatelessWidget {
  final String? message;
  final String? title;
  final String? image;
  final String? btnName;
  final LinearGradient? gradient;
  final Color? color;
  final bool isBooster;
  final Function() onTapButton;

  const CustomDialog({this.message, super.key, this.title, this.image, this.btnName, this.gradient, this.color, required this.isBooster, required this.onTapButton});

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
                    painter: DiagonalBorderPainter(gradient!),
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
                          Text(title!,textAlign:TextAlign.center,style: TextStyle(color: color,fontWeight: FontWeight.w400,fontSize: 28),),
                          Text(
                            message!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColor.grayColor,fontWeight: FontWeight.w400,fontSize: 14),),
                          Bounce(
                            onTap: () {
                              onTapButton();
                              Get.back();
                            },
                            child: Container(
                              width: 240,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: 13),
                              decoration: BoxDecoration(
                                color: isBooster ? AppColor.greenColor : AppColor.skyColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(btnName!,style: TextStyle(color: isBooster ?Colors.black : Colors.white),),
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
                    child: SvgPicture.asset(image!),)
              ],
            ),
          ),
        ),
      ),
    );
  }
}





