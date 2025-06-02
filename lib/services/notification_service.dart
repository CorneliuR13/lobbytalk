import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// Call this early in your app (e.g., in main or your main widget's initState)
  static Future<void> initialize(BuildContext context) async {
    if (_initialized) return;
    _initialized = true;

    // Android initialization
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    // Request notification permissions
    await FirebaseMessaging.instance.requestPermission();

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'Default',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  /// Get the FCM token for this device (call after user logs in)
  static Future<String?> getFcmToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  /// Optionally, call this to handle background messages
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // You can handle background messages here if needed
    // For example, show a local notification
  }
}
