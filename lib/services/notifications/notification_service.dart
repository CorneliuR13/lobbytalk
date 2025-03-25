import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lobbytalk/pages/chat_page.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize(BuildContext context) async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _handleNotificationTap(response.payload, context);
        },
      );

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationTap(json.encode(message.data), context);
      });

      saveDeviceToken();
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<void> saveDeviceToken() async {
    String? token = await _firebaseMessaging.getToken();
    String? userId = _auth.currentUser?.uid;

    if (token != null && userId != null) {
      await _firestore.collection('users_tokens').doc(userId).set({
        'token': token,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> _showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'hotel_chat_channel',
        'Hotel Chat Notifications',
        channelDescription: 'Notifications for LobbyTalk app',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
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
    }
  }

  void _handleNotificationTap(String? payload, BuildContext context) {
    if (payload != null) {
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

      if (data.containsKey('type') && data['type'] == 'check_in') {}
    }
  }

  Future<void> sendChatNotification({
    required String receiverId,
    required String receiverEmail,
    required String message,
    required String senderName,
  }) async {
    try {
      DocumentSnapshot tokenDoc =
          await _firestore.collection('users_tokens').doc(receiverId).get();

      if (tokenDoc.exists) {
        final data = tokenDoc.data() as Map<String, dynamic>;
        String? token = data['token'];

        if (token != null) {
          final notificationData = {
            'to': token,
            'notification': {
              'title': 'Message from $senderName',
              'body': message.length > 50
                  ? '${message.substring(0, 47)}...'
                  : message,
              'sound': 'default',
            },
            'data': {
              'type': 'chat',
              'senderId': _auth.currentUser?.uid,
              'senderEmail': _auth.currentUser?.email,
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
          };

          print('Would send notification: $notificationData');
        }
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> sendCheckInStatusNotification({
    required String clientId,
    required bool approved,
    required String hotelName,
  }) async {
    try {
      DocumentSnapshot tokenDoc =
          await _firestore.collection('users_tokens').doc(clientId).get();

      if (tokenDoc.exists) {
        final data = tokenDoc.data() as Map<String, dynamic>;
        String? token = data['token'];

        if (token != null) {
          final status = approved ? 'approved' : 'rejected';
          final title = approved ? 'Check-In Approved' : 'Check-In Rejected';

          final notificationData = {
            'to': token,
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
          };

          print('Would send notification: $notificationData');
        }
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
