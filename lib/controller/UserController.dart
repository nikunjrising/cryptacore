import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../model/UserModel.dart';
import 'ConfigController.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Observable user model
  Rx<UserModel?> userModel = Rx<UserModel?>(null);

  // ---------------------- FETCH USER ----------------------
  Future<void> fetchUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    DocumentSnapshot snapshot =
    await _db.collection("users").doc(uid).get();

    if (snapshot.exists) {
      userModel.value = UserModel.fromMap(uid, snapshot.data() as Map<String, dynamic>);
    }
  }

  // ---------------------- CREATE USER (FINAL VERSION) ----------------------
  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    required String imageUrl,
    required String fcmToken,
    required bool isGuest,
  }) async {
    final docRef = _db.collection("users").doc(uid);

    DocumentSnapshot snapshot = await docRef.get();

    // If user already exists → load & return
    if (snapshot.exists) {
      userModel.value = UserModel.fromMap(uid, snapshot.data() as Map<String, dynamic>);
      return;
    }

    // Get config
    final config = Get.find<ConfigController>().config.value;

    // Referral code
    String referralCode = uid.substring(0, 6).toUpperCase();

    // New user object
    UserModel newUser = UserModel(
      uid: uid,
      name: name,
      email: email,
      phone: "",
      imageUrl: imageUrl,

      totalMined: 0.0,
      currentMining: 0.0,
      miningSpeed: config.miningSpeed,
      earnedToday: 0.0,
      earnedByReward: 0.0,
      earnedBySpinWheel: 0.0,

      isMining: false,
      miningSessionHr: config.sessionHr,
      sessionStart: null,
      sessionEnd: null,

      sessionsUsedToday: 0,
      adsWatchedToday: 0,

      referralCode: referralCode,
      referredBy: "",
      referralCount: 0,

      walletBalance: 0.0,

      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
    );

    await docRef.set(newUser.toMap(), SetOptions(merge: true));

    userModel.value = newUser;
  }

  // ---------------------- UPDATE USER ----------------------
  Future<void> updateUser(Map<String, dynamic> data) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await _db.collection("users").doc(uid).update(data);

    // Refresh local user
    await fetchUser();
  }
}
