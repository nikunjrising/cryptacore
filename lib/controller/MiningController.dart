import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../const/LoadingDialog.dart';

class MiningController extends GetxController {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  late String userId;

  RxDouble currentMining = 0.0.obs;
  RxInt remainingSeconds = 0.obs;
  RxInt totalSessionSeconds = 360.obs;
  RxBool isMining = false.obs;
  RxInt adsWatchedThisSession = 0.obs;

  Timer? _timer;

  double _baseMiningSpeed = 0.00001;
  double _perAdBoostFraction = 0.01;
  RxDouble earnedToday = 0.0.obs;

  RxDouble earnedBySpinWheel = 0.0.obs;
  RxDouble earnedByReward = 0.0.obs;



  @override
  void onInit() {
    super.onInit();

    final user = auth.currentUser;
    userId = user?.uid ?? "";

    if (userId.isEmpty) {
      print("User not logged in.");
      return;
    }
    _loadPreviousMining();  // 🔥 Load old mined value + old session
    loadEarnedBySpinWheel();
    loadEarnedByReward();
    getDynamicSessionSeconds();
  }

  Future<int> getDynamicSessionSeconds() async {
    final doc = await db.collection("config").doc("default").get();

    // if (!doc.exists) return 360;

    double hours = (doc.data()?["sessionHr"] ?? 1).toDouble();
    totalSessionSeconds.value = (hours * 3600).toInt();
    return (hours * 3600).toInt();
  }


  Future<void> _loadPreviousMining() async {
    final doc = await db.collection("users").doc(userId).get();
    if (!doc.exists) return;

    final data = doc.data() ?? {};

    // Load previously mined amount
    double previousTotal = (data["totalMined"] ?? 0).toDouble();
    currentMining.value = previousTotal;

    // If a mining session was active, restore it
    if (data["isMining"] == true) {
      int startAt = data["miningStartAt"] ?? 0;
      int sessionSeconds = data["sessionSeconds"] ?? 0;

      int elapsed = ((DateTime.now().millisecondsSinceEpoch - startAt) ~/ 1000);
      int remaining = sessionSeconds - elapsed;

      if (remaining > 0) {
        remainingSeconds.value = remaining;
        isMining.value = true;

        print("Resuming mining: $remaining seconds left");
        _startTimer();
      } else {
        // Mining already completed while user was offline
        await _stopTimerAndFinalize();
      }
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  double currentRatePerSecond() {
    final boostMultiplier = 1.0 + (adsWatchedThisSession.value * _perAdBoostFraction);
    return _baseMiningSpeed * boostMultiplier;
  }


  Future<void> startMining({required int sessionSeconds}) async {
    if(isMining.value){
    Fluttertoast.showToast(msg: 'Your session started already!!');
    return;
    }

    isMining.value = true;
    adsWatchedThisSession.value = 0;

    remainingSeconds.value = sessionSeconds;

    // DO NOT reset currentMining here (important!)
    // currentMining must continue from previous value

    _startTimer();

    await db.collection("users").doc(userId).update({
      "isMining": true,
      "miningStartAt": DateTime.now().millisecondsSinceEpoch,
      "sessionSeconds": sessionSeconds,
    });
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!isMining.value || remainingSeconds.value <= 0) {
        _stopTimerAndFinalize();
        return;
      }

      currentMining.value += currentRatePerSecond();
      earnedToday.value += currentRatePerSecond();
      remainingSeconds.value--;

      // Save progress every second
      await db.collection("users").doc(userId).update({
        "totalMined": currentMining.value,
        "earnedToday": earnedToday.value,   // NEW
      });

    });
  }


  Future<void> _stopTimerAndFinalize() async {
    _timer?.cancel();
    _timer = null;

    isMining.value = false;

    await db.collection("users").doc(userId).update({
      "isMining": false,
      "totalMined": currentMining.value,
      "earnedToday": earnedToday.value,
    });

    print("Mining session completed: ${currentMining.value}");
  }

  Future<bool> applyAdBoost() async {
    if (!isMining.value) return false;

    final ok = await _canWatchAdToday();
    if (!ok) return false;

    adsWatchedThisSession.value++;
    adsWatchedThisSession.refresh();


    await db.collection("users").doc(userId).update({
      "adsWatchedToday": FieldValue.increment(1),
    });

    return true;
  }


  Future<bool> _canWatchAdToday() async {
    final doc = await db.collection("users").doc(userId).get();
    if (!doc.exists) return false;

    final data = doc.data() ?? {};

    int watchAdsPerDay = data["watchAdsPerDay"] ?? 5;
    int adsWatchedToday = data["adsWatchedToday"] ?? 0;
    String lastDate = data["lastAdWatchDate"] ?? "";

    final today = DateTime.now().toString().substring(0, 10);

    if (today != lastDate) {
      await db.collection("users").doc(userId).update({
        "adsWatchedToday": 0,
        "lastAdWatchDate": today,
      });
      adsWatchedToday = 0;
    }

    return adsWatchedToday < watchAdsPerDay;
  }

  String formattedRemaining() {
    final s = remainingSeconds.value;
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;

    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${sec.toString().padLeft(2, '0')}';
  }

  void setConfig({
    required double baseSpeed,
    required double perAdBoostFraction,
  }) {
    _baseMiningSpeed = baseSpeed;
    _perAdBoostFraction = perAdBoostFraction;
  }

  Future<void> loadEarnedBySpinWheel() async {
    final doc = await db.collection("users").doc(userId).get();
    if (!doc.exists) {
      earnedBySpinWheel.value = 0.0;
      return;
    }

    earnedBySpinWheel.value = (doc.data()?["earnedBySpinWheel"] ?? 0.0).toDouble();
  }



  Future<void> setEarnedBySpinWheel(double amount) async {
    earnedBySpinWheel.value += amount;   // update UI instantly

    await db.collection("users").doc(userId).update({
      "earnedBySpinWheel": amount,
    });
    loadEarnedBySpinWheel();
  }

  Future<void> loadEarnedByReward() async {
    final doc = await db.collection("users").doc(userId).get();
    if (!doc.exists) {
      earnedByReward.value = 0.0;
      return;
    }

    earnedByReward.value = (doc.data()?["earnedByReward"] ?? 0.0).toDouble();
  }


  Future<void> setEarnedByReward(double amount) async {
    earnedByReward.value += amount;   // update UI instantly

    await db.collection("users").doc(userId).update({
      "earnedByReward": amount,
    });
    loadEarnedByReward();
  }



}
