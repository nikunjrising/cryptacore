// iron_source_service.dart
import 'dart:io';
import 'package:get/get.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';

class IronSourceService extends GetxService {
  final RxBool isInitialized = false.obs;

  // App Keys from your demo
  final String androidAppKey = '85460dcd';
  final String iosAppKey = '8545d445';

  @override
  Future<void> onInit() async {
    super.onInit();
    await initializeSDK();
  }

  Future<void> initializeSDK() async {
    try {
      print('Initializing IronSource SDK...');

      // Set Flutter version
      LevelPlay.setFlutterVersion('3.32.7');

      // For iOS14 IDFA access
      if (Platform.isIOS) {
        final currentStatus = await ATTrackingManager.getTrackingAuthorizationStatus();
        print('ATT Status: $currentStatus');
        if (currentStatus == ATTStatus.NotDetermined) {
          final returnedStatus = await ATTrackingManager.requestTrackingAuthorization();
          print('ATT Status returned: $returnedStatus');
        }
      }

      // Enable debug mode
      await LevelPlay.setAdaptersDebug(true);
      LevelPlay.validateIntegration();

      // Initialize with app key
      final appKey = Platform.isAndroid ? androidAppKey : iosAppKey;
      final initRequest = LevelPlayInitRequest.builder(appKey).build();

      await LevelPlay.init(
        initRequest: initRequest,
        initListener: _InitListener(),
      );

      isInitialized.value = true;
      print('IronSource SDK initialized successfully');

    } catch (e) {
      print('IronSource initialization failed: $e');
      isInitialized.value = false;
    }
  }
}

class _InitListener implements LevelPlayInitListener {
  @override
  void onInitFailed(LevelPlayInitError error) {
    print('IronSource init failed: $error');
  }

  @override
  void onInitSuccess(LevelPlayConfiguration configuration) {
    print('IronSource init success: $configuration');
  }
}