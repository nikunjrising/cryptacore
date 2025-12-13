import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConfigController extends GetxController {
  Rx<ConfigModel> config = ConfigModel.defaultConfig().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    // setDefaultConfigInFirestore();
    fetchConfig();
  }

  final _configRef = FirebaseFirestore.instance.collection('config').doc('default');

  // ---------------- FETCH CONFIG ----------------
  Future<void> fetchConfig() async {
    try {
      DocumentSnapshot snapshot = await _configRef.get();

      if (snapshot.exists) {
        config.value = ConfigModel.fromMap(snapshot.data() as Map<String, dynamic>);
        print("✅ Config fetched from Firestore:");
        print(config.value.toMap());
      } else {
        await setDefaultConfigInFirestore();
      }
    } catch (e) {
      print("❌ Error fetching config: $e");
    }
  }

  // ---------------- SET DEFAULT CONFIG ----------------
  Future<void> setDefaultConfigInFirestore() async {
    try {
      // await _configRef.set(config.value.toMap());
      await _configRef.set(config.value.toMap(), SetOptions(merge: true));

      print("✅ Default config saved to Firestore!");
    } catch (e) {
      print("❌ Error saving default config: $e");
    }
  }
}


class ConfigModel {
  double miningSpeed;
  double baseMiningPerHour;
  double adsRewardRate;

  int sessionHr;
  int watchAdPerDay;
  int maxSessionPerDay;

  double minWithdraw;
  double withdrawFee;

  // Rewarded Ad Test IDs
  String rewardAndroidId;
  String rewardIosId;

 // New fields
  String intAndroidId;
  String intIosId;
  String bannerAndroidId;
  String bannerIosId;
  String nativeAndroidId;
  String nativeIosId;
  String appOpenAndroidId;
  String appOpenIosId;
  int spinWheelPerDay;


  double referralBonus;

  String termsConditionsUrl;
  String privacyPolicyUrl;
  String playStoreLink;
  String appStoreLink;
  String androidVersion;
  String iosVersion;
  bool forceUpdate;
  bool isShowAd;
  bool isShowAppOpenAd;

  String isAndroidAppKey;
  String isIosAppKey;
  String isINTAndroidAdUnitId;
  String isINTIosAdUnitId;
  String isREWARDAndroidAdUnitId;
  String isREWARDIosAdUnitId;

  ConfigModel({
    required this.miningSpeed,
    required this.baseMiningPerHour,
    required this.adsRewardRate,
    required this.sessionHr,
    required this.watchAdPerDay,
    required this.maxSessionPerDay,
    required this.minWithdraw,
    required this.withdrawFee,
    required this.rewardAndroidId,
    required this.rewardIosId,
    required this.intAndroidId,
    required this.intIosId,
    required this.spinWheelPerDay,
    required this.referralBonus,
    required this.androidVersion,
    required this.iosVersion,
    required this.forceUpdate,
    required this.privacyPolicyUrl,
    required this.termsConditionsUrl,
    required this.playStoreLink,
    required this.appStoreLink,
    required this.bannerAndroidId,
    required this.bannerIosId,
    required this.nativeAndroidId,
    required this.nativeIosId,
    required this.appOpenAndroidId,
    required this.appOpenIosId,
    required this.isShowAd,
    required this.isShowAppOpenAd,
    required this.isAndroidAppKey,
    required this.isIosAppKey,
    required this.isINTAndroidAdUnitId,
    required this.isINTIosAdUnitId,
    required this.isREWARDAndroidAdUnitId,
    required this.isREWARDIosAdUnitId,
  });

  // -------- DEFAULT CONFIG --------
  factory ConfigModel.defaultConfig() {
    return ConfigModel(
      miningSpeed: 0.0000012,
      baseMiningPerHour: 0.000024,
      adsRewardRate: 1.0000003,

      sessionHr: 2,
      watchAdPerDay: 8,
      maxSessionPerDay: 6,

      minWithdraw: 1.5,
      withdrawFee: 0.2,

      // Rewarded Ad Test IDs
      rewardAndroidId: "ca-app-pub-3940256099942544/5224354917",
      rewardIosId: "ca-app-pub-3940256099942544/1712485313",

      // New fields
      intAndroidId: "ca-app-pub-3940256099942544/5224354917",
      intIosId: "ca-app-pub-3940256099942544/1712485313",
      bannerAndroidId: 'ca-app-pub-3940256099942544/9214589741',
      bannerIosId: 'ca-app-pub-3940256099942544/2435281174',
      nativeAndroidId: 'ca-app-pub-3940256099942544/2247696110',
      nativeIosId: 'ca-app-pub-3940256099942544/3986624511',
      appOpenAndroidId: 'ca-app-pub-3940256099942544/9257395921',
      appOpenIosId: 'ca-app-pub-3940256099942544/5575463023',

      spinWheelPerDay: 2,

      referralBonus: 0.1,

      androidVersion: "1.0.0",
      iosVersion: "1.0.0",
      forceUpdate: false,
      privacyPolicyUrl: '',
      termsConditionsUrl: '',
      playStoreLink: '',
      appStoreLink: '',
      isShowAd: true,
      isShowAppOpenAd: true,


      isAndroidAppKey:"85460dcd",
      isIosAppKey:"8545d445",
      isINTAndroidAdUnitId:"aeyqi3vqlv6o8sh9",
      isINTIosAdUnitId:"wmgt0712uuux8ju4",
      isREWARDAndroidAdUnitId:"76yy3nay3ceui2a3",
      isREWARDIosAdUnitId:"qwouvdrkuwivay5q",
    );
  }

  // -------- FROM MAP --------
  factory ConfigModel.fromMap(Map<String, dynamic> map) {
    return ConfigModel(
      miningSpeed: (map['miningSpeed'] ?? 0.0000012).toDouble(),
      baseMiningPerHour: (map['baseMiningPerHour'] ?? 0.000024).toDouble(),
      adsRewardRate: (map['adsRewardRate'] ?? 1.0000003).toDouble(),

      sessionHr: (map['sessionHr'] ?? 1).toInt(),
      watchAdPerDay: (map['watchAdPerDay'] ?? 8).toInt(),
      maxSessionPerDay: (map['maxSessionPerDay'] ?? 6).toInt(),

      minWithdraw: (map['minWithdraw'] ?? 1.5).toDouble(),
      withdrawFee: (map['withdrawFee'] ?? 0.2).toDouble(),

      rewardAndroidId: map['rewardAndroidId'] ?? "ca-app-pub-3940256099942544/5224354917",
      rewardIosId: map['rewardIosId'] ?? "ca-app-pub-3940256099942544/1712485313",
      bannerAndroidId: map['bannerAndroidId'] ?? "ca-app-pub-3940256099942544/9214589741",
      bannerIosId: map['bannerIosId'] ?? "ca-app-pub-3940256099942544/2435281174",
      nativeAndroidId: map['nativeAndroidId'] ?? "ca-app-pub-3940256099942544/2247696110",
      nativeIosId: map['nativeIosId'] ?? "ca-app-pub-3940256099942544/3986624511",
      appOpenAndroidId: map['appOpenAndroidId'] ?? "ca-app-pub-3940256099942544/9257395921",
      appOpenIosId: map['appOpenIosId'] ?? "ca-app-pub-3940256099942544/5575463023",


      intAndroidId: (map['intAndroidId'] ?? ''),
      intIosId: (map['intIosId'] ?? ''),
      spinWheelPerDay: (map['spinWheelPerDay'] ?? 2),

      referralBonus: (map['referralBonus'] ?? 0.1).toDouble(),

      androidVersion: map['androidVersion'] ?? '1.0.0',
      iosVersion: map['iosVersion'] ?? '1.0.0',
      forceUpdate: map['forceUpdate'] ?? false,
      termsConditionsUrl: map['termsConditionsUrl'] ?? '',
      privacyPolicyUrl: map['privacyPolicyUrl'] ?? '',
      playStoreLink: map['playStoreLink'] ?? '',
      appStoreLink: map['appStoreLink'] ?? '',
      isShowAd: map['isShowAd'] ?? true,
      isShowAppOpenAd: map['isShowAppOpenAd'] ?? true,


      isAndroidAppKey: map['isAndroidAppKey'] ?? "85460dcd",
      isIosAppKey: map['isIosAppKey'] ?? "8545d445",
      isINTAndroidAdUnitId: map['isINTAndroidAdUnitId'] ?? "aeyqi3vqlv6o8sh9",
      isINTIosAdUnitId: map['isINTIosAdUnitId'] ?? "wmgt0712uuux8ju4",
      isREWARDAndroidAdUnitId: map['isREWARDAndroidAdUnitId'] ?? "76yy3nay3ceui2a3",
      isREWARDIosAdUnitId: map['isREWARDIosAdUnitId'] ?? "qwouvdrkuwivay5q",
    );
  }

  // -------- TO MAP --------
  Map<String, dynamic> toMap() {
    return {
      'miningSpeed': miningSpeed,
      'baseMiningPerHour': baseMiningPerHour,
      'adsRewardRate': adsRewardRate,

      'sessionHr': sessionHr,
      'watchAdPerDay': watchAdPerDay,
      'maxSessionPerDay': maxSessionPerDay,

      'minWithdraw': minWithdraw,
      'withdrawFee': withdrawFee,

      'rewardAndroidId': rewardAndroidId,
      'rewardIosId': rewardIosId,
      'bannerAndroidId': bannerAndroidId,
      'bannerIosId': bannerIosId,
      'nativeAndroidId': nativeAndroidId,
      'nativeIosId': nativeIosId,
      'appOpenAndroidId': appOpenAndroidId,
      'appOpenIosId': appOpenIosId,

      'intAndroidId': intAndroidId,
      'intIosId': intIosId,
      'spinWheelPerDay': spinWheelPerDay,

      'referralBonus': referralBonus,

      'androidVersion': androidVersion,
      'iosVersion': iosVersion,
      'forceUpdate': forceUpdate,
      'termsConditionsUrl': termsConditionsUrl,
      'privacyPolicyUrl': privacyPolicyUrl,
      'playStoreLink': playStoreLink,
      'appStoreLink': appStoreLink,
      'isShowAd': isShowAd,
      'isShowAppOpenAd': isShowAppOpenAd,

      'isAndroidAppKey': isAndroidAppKey,
      'isIosAppKey': isIosAppKey,
      'isINTAndroidAdUnitId': isINTAndroidAdUnitId,
      'isINTIosAdUnitId': isINTIosAdUnitId,
      'isREWARDAndroidAdUnitId': isREWARDAndroidAdUnitId,
      'isREWARDIosAdUnitId': isREWARDIosAdUnitId,
    };
  }
}
