import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class RewardService {
  static double _randomReward() {
    final List<double> rewards = [
      0.00012,
      0.00035,
      0.00251,
      0.00589,
      0.00318,
      0.00442,
      0.00159,
      0.00087,
    ];

    rewards.shuffle();
    return rewards.first;
  }

  static bool _isLose() {
    return Random().nextInt(5) == 0; // 20% lose chance
  }

  static Future<double?> generateReward() async {
    if (_isLose()) {
      return null; // better luck next time
    }
    return _randomReward();
  }

  // static Future<void> addRewardToUser(String uid, double amount) async {
  //   await FirebaseFirestore.instance.collection("users").doc(uid).update({
  //     "walletBalance": FieldValue.increment(amount),
  //   });
  // }

}
