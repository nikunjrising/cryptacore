import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/UserModel.dart';


class PreferenceKeys {
  static const user = "user_data";
  static const onboardingDone = "onboarding_done";
  static const lastSpinTime = "last_spin_time";
  static const String lastSpinDate = "lastSpinDate";
  static const String todaySpinCount = "todaySpinCount";
}

class PreferenceHelper {
  // Singleton pattern
  static final PreferenceHelper _instance = PreferenceHelper._internal();
  factory PreferenceHelper() => _instance;
  PreferenceHelper._internal();

  SharedPreferences? _prefs;

  // await PreferenceHelper().saveUser(userModel);


  /// Initialize only once — call in main()
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ---------------------- SETTERS ----------------------

  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  Future<void> setStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }

  // ---------------------- GETTERS ----------------------

  String? getString(String key) => _prefs?.getString(key);

  int? getInt(String key) => _prefs?.getInt(key);

  bool? getBool(String key) => _prefs?.getBool(key);

  double? getDouble(String key) => _prefs?.getDouble(key);

  List<String>? getStringList(String key) => _prefs?.getStringList(key);

  // ---------------------- REMOVE & CLEAR ----------------------

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  Future<void> clear() async {
    await _prefs?.clear();
  }
}



extension UserPreference on PreferenceHelper {

  // Future<void> saveUser(UserModel user) async {
  //   final jsonString = jsonEncode(user.toJson());
  //   await setString(PreferenceKeys.user, jsonString);
  // }

  // UserModel? getUser() {
  //   final jsonString = getString(PreferenceKeys.user);
  //   if (jsonString == null) return null;
  //
  //   final jsonMap = jsonDecode(jsonString);
  //   return UserModel.fromJson(jsonMap);
  // }

  Future<void> removeUser() async {
    await remove(PreferenceKeys.user);
  }
}
