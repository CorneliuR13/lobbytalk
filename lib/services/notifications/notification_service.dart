import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:lobbytalk/pages/chat_page.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Channel ID for Android notifications
  static const String _channelId = 'hotel_chat_channel';
  static const String _channelName = 'Hotel Chat Notifications';
  static const String _channelDescription = 'Notifications for LobbyTalk app';

  // FCM server key - Get this from Firebase Console > Project Settings > Cloud Messaging
  static const String _fcmServerKey =
      'YOUR_SERVER_KEY_HERE'; // Replace with your actual server key

  Future<void> initialize(BuildContext context) async {
    print('Initializing notification service...');

    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: true,
    );

    print('Notification permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');

      // Get FCM token
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');

      // Set foreground notification presentation options
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Initialize Android notification channel
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Initialize iOS notification settings
      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        requestCriticalPermission: true,
      );

      // Combined initialization settings
      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Initialize local notifications plugin
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('Notification tapped: ${response.payload}');
          _handleNotificationTap(response.payload, context);
        },
      );

      // Create notification channel for Android
      await _createNotificationChannel();

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Received foreground message: ${message.messageId}');
        print('Message data: ${message.data}');
        print('Message notification: ${message.notification?.title}');
        _showNotification(message);
      });

      // Handle when app is opened from notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('App opened from notification: ${message.messageId}');
        print('Message data: ${message.data}');
        _handleNotificationTap(json.encode(message.data), context);
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Save current device token to Firestore
      await saveDeviceToken();
    } else {
      print('User declined or has not accepted notification permission');
    }
  }

  // Create Android notification channel
  Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid) {
      print('Creating Android notification channel...');
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
        enableVibration: true,
        enableLights: true,
        playSound: true,
        showBadge: true,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      print('Android notification channel created');
    }
  }

  // Save device FCM token to Firestore
  Future<void> saveDeviceToken() async {
    String? token = await _firebaseMessaging.getToken();
    String? userId = _auth.currentUser?.uid;

    print('Saving device token. User ID: $userId, Token: $token');

    if (token != null && userId != null) {
      await _firestore.collection('users_tokens').doc(userId).set({
        'token': token,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('Device token saved successfully');
    } else {
      print('Failed to save device token: token or userId is null');
    }
  }

  // Show local notification
  Future<void> _showNotification(RemoteMessage message) async {
    print('Showing notification...');
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      print('Notification title: ${notification.title}');
      print('Notification body: ${notification.body}');

      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        enableLights: true,
        playSound: true,
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.message,
      );

      DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: 1,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformChannelSpecifics,
        payload: json.encode(message.data),
      );
      print('Local notification shown successfully');
    } else {
      print('Failed to show notification: notification is null');
    }
  }

  // Handle notification tap
  void _handleNotificationTap(String? payload, BuildContext context) {
    if (payload != null) {
      try {
        Map<String, dynamic> data = json.decode(payload);

        if (data.containsKey('type') && data['type'] == 'chat') {
          String? senderId = data['senderId'];
          String? senderEmail = data['senderEmail'];

          if (senderId != null && senderEmail != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  receiverID: senderId,
                  receiveEmail: senderEmail,
                ),
              ),
            );
          }
        }

        if (data.containsKey('type') && data['type'] == 'check_in') {
          // Handle check-in notifications
          // You can add navigation logic here
        }
      } catch (e) {
        print('Error handling notification tap: $e');
      }
    }
  }

  // Send chat notification using FCM HTTP v1 API
  Future<bool> sendChatNotification({
    required String receiverId,
    required String receiverEmail,
    required String message,
    required String senderName,
  }) async {
    print('Sending chat notification...');
    print('Receiver ID: $receiverId');
    print('Message: $message');

    try {
      // Get recipient's FCM token
      DocumentSnapshot tokenDoc =
          await _firestore.collection('users_tokens').doc(receiverId).get();

      if (tokenDoc.exists) {
        final data = tokenDoc.data() as Map<String, dynamic>;
        String? token = data['token'];
        print('Recipient token: $token');

        if (token != null) {
          // Prepare notification data
          final notificationData = {
            'message': {
              'token': token,
              'notification': {
                'title': 'Message from $senderName',
                'body': message.length > 50
                    ? '${message.substring(0, 47)}...'
                    : message,
              },
              'android': {
                'notification': {
                  'channel_id': _channelId,
                  'priority': 'high',
                  'sound': 'default',
                  'default_sound': true,
                  'default_vibrate_timings': true,
                  'default_light_settings': true,
                },
              },
              'apns': {
                'payload': {
                  'aps': {
                    'sound': 'default',
                    'badge': 1,
                    'content-available': 1,
                  },
                },
              },
              'data': {
                'type': 'chat',
                'senderId': _auth.currentUser?.uid,
                'senderEmail': _auth.currentUser?.email,
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              },
            },
          };

          print('Sending FCM notification with data: $notificationData');

          // Send FCM notification using HTTP v1 API
          final response = await http.post(
            Uri.parse(
                'https://fcm.googleapis.com/v1/projects/lobbytalk-91e63/messages:send'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_fcmServerKey',
            },
            body: json.encode(notificationData),
          );

          print('FCM Response status: ${response.statusCode}');
          print('FCM Response body: ${response.body}');

          if (response.statusCode == 200) {
            print('Notification sent successfully');
            return true;
          } else {
            print(
                'Failed to send notification. Status: ${response.statusCode}, Body: ${response.body}');

            // Try legacy FCM endpoint if v1 API fails
            return await _sendLegacyFCMNotification(token, senderName, message);
          }
        }
      }

      print('No valid token found for recipient: $receiverId');
      return false;
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }

  // Fallback to legacy FCM endpoint
  Future<bool> _sendLegacyFCMNotification(
      String token, String senderName, String message) async {
    try {
      final legacyNotificationData = {
        'notification': {
          'title': 'Message from $senderName',
          'body':
              message.length > 50 ? '${message.substring(0, 47)}...' : message,
          'sound': 'default',
          'badge': '1',
          'priority': 'high',
        },
        'data': {
          'type': 'chat',
          'senderId': _auth.currentUser?.uid,
          'senderEmail': _auth.currentUser?.email,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'priority': 'high',
        },
        'to': token,
        'priority': 'high',
      };

      print('Trying legacy FCM endpoint...');
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_fcmServerKey',
        },
        body: json.encode(legacyNotificationData),
      );

      print('Legacy FCM Response status: ${response.statusCode}');
      print('Legacy FCM Response body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Error sending legacy notification: $e');
      return false;
    }
  }

  // Send check-in status notification
  Future<bool> sendCheckInStatusNotification({
    required String clientId,
    required bool approved,
    required String hotelName,
  }) async {
    try {
      // Get recipient's FCM token
      DocumentSnapshot tokenDoc =
          await _firestore.collection('users_tokens').doc(clientId).get();

      if (tokenDoc.exists) {
        final data = tokenDoc.data() as Map<String, dynamic>;
        String? token = data['token'];

        if (token != null) {
          final status = approved ? 'approved' : 'rejected';
          final title = approved ? 'Check-In Approved' : 'Check-In Rejected';

          // Prepare notification data
          final notificationData = {
            'notification': {
              'title': title,
              'body': 'Your check-in request for $hotelName has been $status',
              'sound': 'default',
            },
            'data': {
              'type': 'check_in',
              'status': status,
              'hotelName': hotelName,
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
            'to': token,
          };

          // Send FCM notification
          final response = await http.post(
            Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'key=$_fcmServerKey',
            },
            body: json.encode(notificationData),
          );

          if (response.statusCode == 200) {
            print('Check-in notification sent successfully');
            return true;
          } else {
            print(
                'Failed to send check-in notification. Status: ${response.statusCode}, Body: ${response.body}');
            return false;
          }
        }
      }

      print('No valid token found for client: $clientId');
      return false;
    } catch (e) {
      print('Error sending check-in notification: $e');
      return false;
    }
  }
}

// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
  print('Background message data: ${message.data}');
  print('Background message notification: ${message.notification?.title}');

  // Show local notification for background messages
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  RemoteNotification? notification = message.notification;
  if (notification != null) {
    print('Showing background notification...');
    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'hotel_chat_channel',
          'Hotel Chat Notifications',
          channelDescription: 'Notifications for LobbyTalk app',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
    print('Background notification shown successfully');
  } else {
    print('Failed to show background notification: notification is null');
  }
}
