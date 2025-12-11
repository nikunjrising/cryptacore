import 'dart:async';
import 'dart:math';
import 'dart:math' as math;

import 'package:bounce/bounce.dart';
import 'package:cryptacore/const/color.dart';
import 'package:cryptacore/controller/MiningController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../ad/admob/NativeAdExample.dart';
import '../../ad/admob/RewardAdController.dart';
import '../../const/app_images.dart';
import '../../service/PreferenceHelper.dart';
import '../widget/AppSnackBar.dart';

class SpinningWheelPage extends StatefulWidget {
  const SpinningWheelPage({super.key});

  @override
  SpinningWheelPageState createState() => SpinningWheelPageState();
}

class SpinningWheelPageState extends State<SpinningWheelPage> {
  final MiningController miningController = Get.find();
  StreamController<int> selected = StreamController<int>();
  String spinBtnName = 'Spin the wheel';
  bool isRewardGenerated = false;
  String rewardName = '';
  double rewardAmount = 0.0;

  @override
  void dispose() {
    selected.close();
    super.dispose();
  }


  MySpinController mySpinController = MySpinController();

  final  List<SpinItem>  itemList = [
    SpinItem(label: '0.00125 ',rewardAmount : 0.00125, labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), color:  Colors.black),
    SpinItem(label: '0.00150 ',rewardAmount : 0.00150, labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), color: const Color(0xff9e00ff)),
    SpinItem(label: '0.00175 ',rewardAmount : 0.00175, labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), color: const Color(0xff00a0ff)),
    SpinItem(label: '0.00100 ',rewardAmount : 0.00100, labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold), color: const Color(0xffffe000)),
    SpinItem(label: 'Next Time',rewardAmount : 0.0, labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold), color: Colors.white),
    SpinItem(label: '0.00105 ', rewardAmount : 0.00105, labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), color: const Color(0xffde0000)),
    SpinItem(label: '0.00225 ',rewardAmount : 0.00225, labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), color: const Color(0xff41d849)),
    SpinItem(label: '0.00325 ',rewardAmount : 0.00325, labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), color: const Color(0xffff9c00)),
    // SpinItem(label: 'Eggplant', color: Colors.redAccent),
    // SpinItem(label: 'Flower', color: Colors.lightBlueAccent),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/onb_bg_1.png'),fit: BoxFit.fill)
        ),
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
            title: Text('Fortune Games', style: TextStyle(color: AppColor.skyColor,fontSize: 20)),
            centerTitle: true,
            actions: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 0),
                decoration: BoxDecoration(
                  color: AppColor.grayColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Obx(() {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(miningController.earnedBySpinWheel.toString(),style: TextStyle(color: AppColor.skyColor,fontSize: 18),),
                      Lottie.asset(
                        'assets/json/gold_coin.json', // Replace with your file path
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                      ),
                    ],
                  );
                },),
              ),
              SizedBox(width: 15,)
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 20,),
                if(rewardName != '')
                Shimmer(
                    gradient: LinearGradient(colors: [AppColor.purpleColor,Colors.white,Colors.amber,AppColor.grayColor,Colors.greenAccent]),
                    child: Text('Reward Amount : $rewardAmount',style: TextStyle(fontSize: 22,color: Colors.white,fontWeight: FontWeight.w600),)),
                SizedBox(height: 20,),

                Stack(
                  children: [
                    MySpinner(
                      mySpinController: mySpinController,
                      wheelSize: Get.width * 0.8,
                      itemList: itemList,
                      onFinished: (index) {
                        SpinItem item = itemList[index - 1]; // or index depending on your mapping

                        print("Reward: ${item.label}");
                        AppSnackBar.show(
                            title: 'Successfully Got reward',
                            subtitle: 'Earned ${item.label}'
                        );
                        setState(() {
                          isRewardGenerated = true;
                          rewardName = item.label;
                          rewardAmount = item.rewardAmount;
                        });
                        miningController.setEarnedBySpinWheel(item.rewardAmount);

                        Future.delayed(const Duration(seconds: 3), () {
                          if (mounted) {
                            setState(() {
                              isRewardGenerated = false;
                            });
                          }
                        });


                        // Example: show dialog
                      },

                    ),
                    if(isRewardGenerated)
                    Lottie.asset(
                      'assets/json/reward_got.json', // Replace with your file path
                      width: 400,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
                const SizedBox(height: 30,),

                Bounce(
                  onTap: () async {
                    final allowed = await checkAndUseSpin();

                    if (!allowed) {
                      AppSnackBar.show(
                        title: "You have used all 2 spins for today.",
                        subtitle: "Try Later",
                      );
                      return;
                    }


                    setState(() {
                      spinBtnName = 'Opening Ad';
                    });
                    await Future.delayed(Duration(microseconds: 2));
                    final rewardController = Get.find<RewardAdController>();

                    bool? result = await rewardController.showRewardAd();
                    setState(() {
                      spinBtnName = 'Spin the wheel';
                    });

                    if (result == true) {
                      int rdm = Random().nextInt(6);
                      await mySpinController.spinNow(luckyIndex: rdm+1,totalSpin: 10,baseSpinDuration: 20);
                    } else {
                      AppSnackBar.show(
                          title: 'Ad Failed',
                          subtitle: 'Try after some time',
                        backgroundColor: Colors.red.withValues(alpha: 0.5)

                      );
                    }


                  },
                  child: Container(
                    width: 70.w,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [AppColor.skyColor, AppColor.purpleColor],
                      ),
                    ),
                    child: Shimmer(
                      gradient: LinearGradient(colors: [Colors.white,AppColor.pinkColor]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 10,
                        children: [
                          Text(
                            spinBtnName,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Icon(Icons.lock)
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 25),
                  child: NativeAdExample(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> checkAndUseSpin() async {
    final prefs = PreferenceHelper();

    await _resetIfNewDay();

    int count = prefs.getInt(PreferenceKeys.todaySpinCount) ?? 0;

    if (count >= 2) return false; // not allowed

    // use one spin
    await prefs.setInt(PreferenceKeys.todaySpinCount, count + 1);

    return true;
  }

}
Future<void> _resetIfNewDay() async {
  final prefs = PreferenceHelper();

  String? lastDate = prefs.getString(PreferenceKeys.lastSpinDate);
  String today = DateTime.now().toString().substring(0, 10); // yyyy-mm-dd

  if (lastDate != today) {
    await prefs.setString(PreferenceKeys.lastSpinDate, today);
    await prefs.setInt(PreferenceKeys.todaySpinCount, 0);
  }
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class SpinItem {
  double rewardAmount;
  String label;
  TextStyle labelStyle;
  Color color;

  SpinItem({
    required this.rewardAmount,
    required this.label,
    required this.color,
    required this.labelStyle
  });
}

class MySpinner extends StatefulWidget {
  final MySpinController mySpinController;
  final List<SpinItem> itemList;
  final double wheelSize;
  final void Function(int luckyIndex) onFinished;
  const MySpinner({
    Key? key,
    required this.mySpinController,
    required this.onFinished,
    required this.itemList,
    required this.wheelSize,
  }) : super(key: key);

  @override
  State<MySpinner> createState() => _MySpinnerState();
}

class _MySpinnerState extends State<MySpinner> with TickerProviderStateMixin{

  @override
  void initState() {
    super.initState();
    widget.mySpinController.initLoad(
      tickerProvider: this,
      itemList: widget.itemList,
      onFinished: widget.onFinished,
    );
  }

  @override
  void dispose() {
    super.dispose();
    null;
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      //alignment: Alignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 15),
          alignment: Alignment.center,
          child: AnimatedBuilder(
            animation: widget.mySpinController._baseAnimation,
            builder: (context, child) {
              double value = widget.mySpinController._baseAnimation.value;
              double rotationValue = (360 * value);
              return RotationTransition(
                turns: AlwaysStoppedAnimation( rotationValue / 360 ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    RotatedBox(
                      quarterTurns: 3,
                      child: Container(
                          width: widget.wheelSize,
                          height: widget.wheelSize,
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black,Colors.white,Colors.black, Colors.white,Colors.black], // Define the colors for the gradient
                                begin: Alignment.topLeft, // Define the starting point of the gradient
                                end: Alignment.bottomRight, // Define the ending point of the gradient
                                // You can also define more stops and their positions if needed
                                // stops: [0.2, 0.7],
                                // tileMode: TileMode.clamp,
                              ),
                              //color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle
                            ),

                            padding: const EdgeInsets.all(5),
                            child: CustomPaint(
                              painter: SpinWheelPainter(
                                  items: widget.itemList
                              ),
                            ),
                          )
                      ),
                    ),
                    ...widget.itemList.map((each) {
                      int index = widget.itemList.indexOf(each);
                      double rotateInterval = 360 / widget.itemList.length;
                      double rotateAmount = (index + 0.5) * rotateInterval;
                      return RotationTransition(
                        turns: AlwaysStoppedAnimation(rotateAmount/360),
                        child: Transform.translate(
                          offset: Offset(0,-widget.wheelSize/4),
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Text(each.label,style: each.labelStyle),
                          ),
                        ),
                      );
                    }),
                    Container(
                      alignment: Alignment.center,
                      width: 25,
                      height: 25,
                      decoration: const BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
        Container(
            alignment: Alignment.topCenter,
            padding:  EdgeInsets.all(0),
            child: Shimmer(gradient: LinearGradient(colors: [AppColor.skyColor,Colors.amber, Colors.white,Colors.greenAccent,Colors.pinkAccent,AppColor.purpleColor]),
            child: const Icon(Icons.location_on_sharp,size: 50,color: AppColor.skyColor,))),
      ],
    );
  }
}

class MySpinController{
  late void Function(int luckyIndex) _onFinished;

  late AnimationController _baseAnimation;
  late TickerProvider _tickerProvider;
  bool _xSpinning = false;
  List<SpinItem> _itemList = [];

  Future<void> initLoad({
    required TickerProvider tickerProvider,
    required List<SpinItem> itemList,
    required void Function(int luckyIndex) onFinished,
  }) async{
    _tickerProvider = tickerProvider;
    _itemList = itemList;
    _onFinished = onFinished;
    await setAnimations(_tickerProvider);
  }

  Future<void> setAnimations(TickerProvider tickerProvider) async{
    _baseAnimation = AnimationController(
      vsync: tickerProvider,
      duration: const Duration(milliseconds: 200),
    );
  }

  Future<void> spinNow({
    required int luckyIndex,
    int totalSpin = 10,
    int baseSpinDuration = 100
  }) async{

    //getWhereToStop
    int itemsLength = _itemList.length;
    int factor = luckyIndex % itemsLength;
    if(factor == 0) factor = itemsLength;
    double spinInterval = 1 / itemsLength;
    double target = 1 - ( (spinInterval * factor) - (spinInterval/2));

    if(!_xSpinning){
      _xSpinning = true;

      int spinCount = 0;

      do{
        _baseAnimation.reset();
        _baseAnimation.duration = Duration(milliseconds: baseSpinDuration);
        if(spinCount == totalSpin){
          await _baseAnimation.animateTo(target);
        }
        else{
          await _baseAnimation.forward();
        }
        baseSpinDuration = baseSpinDuration + 50;
        _baseAnimation.duration = Duration(milliseconds: baseSpinDuration);
        spinCount++;
      }
      while(spinCount <= totalSpin);

      _xSpinning = false;
      _onFinished(luckyIndex);

    }
  }

}

class SpinWheelPainter extends CustomPainter {
  final List<SpinItem> items;

  SpinWheelPainter({required this.items});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final paint = Paint()
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25) // Adjust the shadow color and opacity as needed
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0); // Adjust the blur radius as needed

    const spaceBetweenItems = 0.05; // Adjust this value to set the desired space between items
    final totalSections = items.length;
    const totalAngle = 2 * math.pi;
    final sectionAngleWithSpace = (totalAngle - (totalSections * spaceBetweenItems)) / totalSections;
    const spaceOnBothSides = spaceBetweenItems / 2;

    for (var i = 0; i < items.length; i++) {
      final startAngle = i * (sectionAngleWithSpace + spaceBetweenItems) + spaceOnBothSides;

      paint.color = items[i].color;

      // Draw shadow before drawing the arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngleWithSpace,
        true,
        shadowPaint,
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngleWithSpace,
        true,
        paint,
      );
    }

    // Draw a circle at the center of the wheel
    final centerCircleRadius = radius * 0.05; // Adjust the radius of the center circle as needed
    final centerCirclePaint = Paint()..color = Colors.white; // Adjust the color of the center circle as needed
    canvas.drawCircle(center, centerCircleRadius, centerCirclePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
