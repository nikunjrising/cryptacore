class UserModel {
  String uid;
  String name;
  String email;
  String phone;
  String imageUrl;

  double totalMined;          // lifetime mined amount
  double currentMining;       // running mining amount
  double miningSpeed;         // user-level mining speed (can be boosted)
  double earnedToday;

  double earnedByReward;
  double earnedBySpinWheel;

  bool isMining;              // is mining session active
  int miningSessionHr;        // session hours from config
  DateTime? sessionStart;     // session start time
  DateTime? sessionEnd;       // session end time

  int sessionsUsedToday;      // how many sessions used today
  int adsWatchedToday;        // ad reward use per day

  String referralCode;        // user's own referral code
  String referredBy;          // who referred this user
  int referralCount;          // how many users he referred

  double walletBalance;       // withdrawable balance

  DateTime createdAt;
  DateTime lastActive;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.imageUrl,

    required this.totalMined,
    required this.currentMining,
    required this.miningSpeed,
    required this.earnedToday,

    required this.earnedByReward,
    required this.earnedBySpinWheel,

    required this.isMining,
    required this.miningSessionHr,
    this.sessionStart,
    this.sessionEnd,

    required this.sessionsUsedToday,
    required this.adsWatchedToday,

    required this.referralCode,
    required this.referredBy,
    required this.referralCount,

    required this.walletBalance,

    required this.createdAt,
    required this.lastActive,
  });

  // ---------------- FROM FIRESTORE ----------------
  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      uid: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      imageUrl: map['imageUrl'] ?? '',

      totalMined: (map['totalMined'] ?? 0.0).toDouble(),
      currentMining: (map['currentMining'] ?? 0.0).toDouble(),
      miningSpeed: (map['miningSpeed'] ?? 0.0000012).toDouble(),
      earnedToday: (map['earnedToday'] ?? 0.0).toDouble(),

      earnedByReward: (map['earnedByReward'] ?? 0.0).toDouble(),
      earnedBySpinWheel: (map['earnedBySpinWheel'] ?? 0.0).toDouble(),

      isMining: map['isMining'] ?? false,
      miningSessionHr: (map['miningSessionHr'] ?? 4).toInt(),

      sessionStart: map['sessionStart'] != null
          ? DateTime.parse(map['sessionStart'])
          : null,
      sessionEnd: map['sessionEnd'] != null
          ? DateTime.parse(map['sessionEnd'])
          : null,

      sessionsUsedToday: (map['sessionsUsedToday'] ?? 0).toInt(),
      adsWatchedToday: (map['adsWatchedToday'] ?? 0).toInt(),

      referralCode: map['referralCode'] ?? '',
      referredBy: map['referredBy'] ?? '',
      referralCount: (map['referralCount'] ?? 0).toInt(),

      walletBalance: (map['walletBalance'] ?? 0.0).toDouble(),

      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      lastActive: map['lastActive'] != null
          ? DateTime.parse(map['lastActive'])
          : DateTime.now(),
    );
  }

  // ---------------- TO FIRESTORE ----------------
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'imageUrl': imageUrl,

      'totalMined': totalMined,
      'currentMining': currentMining,
      'miningSpeed': miningSpeed,
      'earnedToday': earnedToday,

      'earnedByReward': earnedByReward,
      'earnedBySpinWheel': earnedBySpinWheel,


      'isMining': isMining,
      'miningSessionHr': miningSessionHr,

      'sessionStart': sessionStart?.toIso8601String(),
      'sessionEnd': sessionEnd?.toIso8601String(),

      'sessionsUsedToday': sessionsUsedToday,
      'adsWatchedToday': adsWatchedToday,

      'referralCode': referralCode,
      'referredBy': referredBy,
      'referralCount': referralCount,

      'walletBalance': walletBalance,

      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
    };
  }
}

/*SpinWheel / reward logic?
now only we fucus on spin wheel,

first im  explaing my query than i will give my code okay,

first off all, in a day use can
we got from config   int spinWheelPerDay; so in 24 hours use can only enable thes   int spinWheelPerDay times right, this is you can manage by preferanse like above,

after after spin wheel,
add earnedreward in earnedBySpinWheel, and also dont forget to ad in total mining,*/