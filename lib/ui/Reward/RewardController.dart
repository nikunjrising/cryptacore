import 'package:get/get.dart';

import '../../service/PreferenceHelper.dart';

class RewardController extends GetxController {
  RxList<bool> claimedCards = List.generate(10, (index) => false).obs;

  @override
  void onInit() {
    super.onInit();
    loadTodayStatus();
  }

  Future<void> loadTodayStatus() async {
    final prefs = PreferenceHelper();
    String today = DateTime.now().toIso8601String().substring(0, 10);

    for (int index = 0; index < claimedCards.length; index++) {
      String? date = prefs.getString("reward_card_${index}_claimed_date");
      bool? claimed = prefs.getBool("reward_card_${index}_claimed_status");

      claimedCards[index] = (date == today && claimed == true);
    }

    update(); // notify UI
  }

  Future<void> setClaimed(int index) async {
    final prefs = PreferenceHelper();
    String today = DateTime.now().toIso8601String().substring(0, 10);

    await prefs.setString("reward_card_${index}_claimed_date", today);
    await prefs.setBool("reward_card_${index}_claimed_status", true);

    claimedCards[index] = true;
    update();
  }
}
