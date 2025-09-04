import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBgHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class PushNotifications {
  static final _fcm = FirebaseMessaging.instance;
  static final _local = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Channel for important notifications.',
    importance: Importance.max,
  );

  static Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseBgHandler);

    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) async {},
    );

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    FirebaseMessaging.onMessage.listen((RemoteMessage msg) async {
      final notif = msg.notification;
      if (notif != null && !Platform.isIOS) {
        await _local.show(
          notif.hashCode,
          notif.title,
          notif.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              priority: Priority.max,
              importance: Importance.max,
            ),
          ),
          payload: msg.data.toString(),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {});

    final initialMsg = await _fcm.getInitialMessage();
    if (initialMsg != null) {}
  }

  static Future<String?> getTokenAndPrint() async {
    final token = await _fcm.getToken();
    debugPrint('FCM TOKEN: $token');
    return token;
  }

  static Future<void> subscribeRole(String role) =>
      _fcm.subscribeToTopic('role-$role');

  static Future<void> subscribeAll() => _fcm.subscribeToTopic('all');
}
