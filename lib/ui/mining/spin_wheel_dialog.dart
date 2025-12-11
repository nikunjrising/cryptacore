import 'package:bounce/bounce.dart';
import 'package:cryptacore/const/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../widget/DiagonalBorderPainter.dart';


class SpinWheelDialog extends StatefulWidget {
  final Function() onTapButton;
  const SpinWheelDialog({super.key, required this.onTapButton});

  @override
  State<SpinWheelDialog> createState() => _SpinWheelDialogState();
}

class _SpinWheelDialogState extends State<SpinWheelDialog> {
  bool showClose = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          showClose = true;
        });
      }
    });
  }

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
            child: Container(
              width: 350,
              color: Colors.transparent,
              padding: EdgeInsets.all( 40),
              margin: EdgeInsets.only(top: 7),
              child: CustomPaint(
                painter: DiagonalBorderPainter(AppColor.greenGradient),
                child: Container(
                  margin: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: AppColor.dialogBgColor,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Stack(
                    children: [
                    Positioned(
                    top: 5,
                    right: 5,
                    child: showClose
                        ? Bounce(
                      onTap: () {
                        Get.back();
                      },
                      child: const Icon(Icons.close, color: Colors.white),
                    )
                        : const SizedBox(),
                  ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 15,
                          children: [
                            Lottie.asset(
                              'assets/json/spin_wheel.json', // Replace with your file path
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(height: 15,),
                            Text('Get Reward', textAlign:TextAlign.center,style: TextStyle(color: AppColor.greenColor,fontWeight: FontWeight.w400,fontSize: 28),),
                            Bounce(
                              onTap: widget.onTapButton,
                              child: Container(
                                width: 180,
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(vertical: 13),
                                decoration: BoxDecoration(
                                  color:  AppColor.greenColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  'SPIN WHEEL',
                                  style: TextStyle(color:  Colors.black),
                                ),
                              ),
                            ),

                            SizedBox(height: 10,),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}





