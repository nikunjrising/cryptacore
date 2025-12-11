import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityController extends GetxController {
  var isConnected = true.obs;
  late StreamSubscription<InternetStatus> _subscription;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();

    _subscription = InternetConnection().onStatusChange.listen((status) {
      isConnected.value = (status == InternetStatus.connected);
    });

    // Add listener here
    ever(isConnected, (connected) {
      if (!connected) {
        NoInternetDialog.show();
      } else {
        NoInternetDialog.close();
      }
    });
  }

  void _checkInitialConnection() async {
    bool result = await InternetConnection().hasInternetAccess;
    isConnected.value = result;
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}



class NoInternetDialog {
  static bool _isDialogOpen = false;

  static void show() {
    if (_isDialogOpen) return;

    _isDialogOpen = true;

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // disable back button
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            children: [
              Icon(Icons.wifi_off, size: 50, color: Colors.red),
              const SizedBox(height: 10),
              const Text("No Internet Connection"),
            ],
          ),
          content: const Text(
            "Please check your connection and try again.",
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Retry: try to dismiss if connection is back
                  if (Get.find<ConnectivityController>().isConnected.value) {
                    close();
                  }
                },
                child: const Text("Retry"),
              ),
            )
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void close() {
    if (_isDialogOpen) {
      _isDialogOpen = false;
      Get.back(); // close dialog
    }
  }
}
