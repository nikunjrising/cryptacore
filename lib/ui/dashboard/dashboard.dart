import 'package:bounce/bounce.dart';
import 'package:cryptacore/const/app_images.dart';
import 'package:cryptacore/const/color.dart';
import 'package:cryptacore/ui/widget/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../controller/MiningController.dart';
import '../../main.dart';
import '../../utils/AppPermissionService.dart';
import '../../utils/utils.dart';
import '../Reward/reward_screen.dart';
import '../mining/mining_screen.dart';
import '../profile/profile_screen.dart';
import '../wallet/wallet_screen.dart';
import '../widget/AppSnackBar.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with WidgetsBindingObserver{
  final MiningController miningController = Get.find();

  bool _isInitialized = false;

  int currentIndex = 0;

  final List<Widget> screens = [
    MiningScreen(),
    WalletScreen(),
    RewardScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
    AppPermissionService.requestNotificationPermission();
  }

  Future<void> _initializeApp() async {
    if (_isInitialized) return;

    debugPrint("🚀 Initializing app...");

    // Request permissions
    await AppPermissionService.requestNotificationPermission();

    // Load ad
    debugPrint("📱 Loading AppOpenAd...");
    await appOpenAdManager.loadAd();

    // Show ad after 2 seconds (cold start)
    Future.delayed(const Duration(seconds: 2), () {
      debugPrint("🕒 Showing cold start ad...");
      appOpenAdManager.showAdIfAvailable();
    });

    _isInitialized = true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("📱 Lifecycle state: $state");

    // FIX: If the App Open Ad is currently showing,
    // ignore these system events (because the Ad overlay causes them)
    if (appOpenAdManager.isShowingAd) {
      debugPrint("✋ Lifecycle Ignored: Ad is showing");
      return;
    }

    if (state == AppLifecycleState.paused) {
      appOpenAdManager.recordAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      // Show ad after coming from background
      Future.delayed(Duration(milliseconds: 1000), () {
        debugPrint("🔄 App resumed - showing ad if available");
        appOpenAdManager.showAdIfAvailable();
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(AppImages.bgApp),fit: BoxFit.fill)
        ),
        child: Column(
          children: [
            if(currentIndex == 0) SizedBox(height: MediaQuery.of(context).padding.top - 10),
            Expanded(
              child: Padding(padding: EdgeInsets.symmetric(horizontal: 15),
              child: screens[currentIndex]),
            ),
            bottomBar(),
            if(MediaQuery.of(context).padding.bottom > 0)
              Container(color: Colors.white.withValues(alpha: 0.05),height: MediaQuery.of(context).padding.bottom,)
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Obx(() {
       return Bounce(
          onTap: () {
            if(miningController.isMining.value){
              AppSnackBar.show(
                title: "Your Mining session is Running",
                subtitle: "",
              );
              return;
            }

            Get.dialog( CustomDialog(
                title: 'Start Mining',
                btnName: 'Start Mining',
                image: AppSvg.miningIcon,
                message: 'Activate your mining session to begin generating SOL rewards. Mining runs in the background.',
                gradient: AppColor.skyGradient,
                isBooster: false,

                onTapButton: () async {
                  // isRewardAdController.onReward = (reward) async {
                  //   int seconds = await miningController.getDynamicSessionSeconds();
                  //   miningController.startMining(sessionSeconds: seconds);
                  //
                  //   AppSnackBar.show(
                  //     title: "Mining session Start",
                  //     subtitle: "",
                  //   );
                  // };
                  // isRewardAdController.showRewardAd();

                  // final rewardController = Get.find<RewardAdController>();
                  //
                  // await rewardController.showRewardAd();
                  // int seconds = await miningController.getDynamicSessionSeconds();
                  // miningController.startMining(sessionSeconds: seconds);
                  ShowRewardAd().show(
                    onReward: () async {
                      // 1. Calculate seconds
                      int seconds = await miningController.getDynamicSessionSeconds();

                      // 2. Start Mining
                      miningController.startMining(sessionSeconds: seconds);

                      // 3. Show Success
                      AppSnackBar.show(
                        title: "Mining session Start",
                        subtitle: "",
                      );
                    },
                    onFailed: () {
                      AppSnackBar.show(
                        title: "Ad Not Ready",
                        subtitle: "Please try again in a moment",
                      );
                    },
                  );
                }


            ));
          },
          child: miningController.isMining.value
              ? Container(
              padding: EdgeInsets.only(bottom: 15),
              child: SvgPicture.asset(AppSvg.miningIcon)
          )
              : Lottie.asset(
            'assets/json/mining.json', // Replace with your file path
            width: 110,
            height: 110,
            fit: BoxFit.cover,
          ),
        );
      },),
    );
  }
  
  Widget bottomBar(){
    return SizedBox(
      height: 70,
      child:Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppImages.bottomBarBG,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: bottomItem(title: 'Mining', image: AppSvg.mining, index: 0)),
              Expanded(child: bottomItem(title: 'Wallet', image: AppSvg.wallet, index: 1)),
              SizedBox(width: 100),
              Expanded(child: bottomItem(title: 'Reward', image: AppSvg.reward, index: 2)),
              Expanded(child: bottomItem(title: 'Profile', image: AppSvg.profile, index: 3)),
            ],
          ),
        ],
      ),
    );
  }
  Widget bottomItem({
    required String title,
    required String image,
    required int index,
  }) {
    return Bounce(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 7,
          children: [
            SvgPicture.asset(
              image,
              colorFilter: ColorFilter.mode(
                currentIndex == index ? AppColor.skyColor : AppColor.grayColor,
                BlendMode.srcIn,
              ),
            ),
            Text(title, style: TextStyle(color: currentIndex == index ? AppColor.skyColor : AppColor.grayColor,)),
          ],
        ),
      ),
    );
  }
}
