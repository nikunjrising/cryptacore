import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local =
  FlutterLocalNotificationsPlugin();

  /// INITIALIZE NOTIFICATIONS
  static Future<void> initialize() async {
    await requestPermission();

    /// Android
    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    /// iOS
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    /// Combine both
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _local.initialize(initSettings);

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  }

  /// PERMISSION REQUEST (Android + iOS)
  static Future<void> requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print("🔔 Notification Permission: ${settings.authorizationStatus}");
  }

  /// GET TOKEN
  static Future<String?> getToken() async {
    String? token = await _messaging.getToken();
    print("📲 FCM Token: $token");
    return token;
  }

  /// FOREGROUND HANDLER
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print("📩 Foreground Message: ${message.notification?.title}");

    if (message.notification != null) {
      _showLocalNotification(
        title: message.notification!.title ?? "New Notification",
        body: message.notification!.body ?? "",
      );
    }
  }

  /// APP OPENED FROM BACKGROUND
  static void _handleOpenedMessage(RemoteMessage message) {
    print("📲 Notification Clicked: ${message.notification?.title}");
  }

  /// LOCAL NOTIFICATION
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      "high_importance_channel",
      "High Importance Notifications",
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _local.show(
      DateTime.now().microsecond,
      title,
      body,
      details,
    );
  }
}

/// BACKGROUND HANDLER
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  print("🛜 Background Message: ${message.notification?.title}");
}
