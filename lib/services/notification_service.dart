import 'dart:convert';
import 'dart:developer';

import 'package:efiling_balochistan/firebase_options.dart';
import 'package:efiling_balochistan/repository/notifications/notification_repo.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_new_badger/flutter_new_badger.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _badgeCountKey = 'notification_badge_count';

// Must be a top-level function — runs in a separate isolate when app is
// background or killed. SharedPreferences is used because the singleton
// is not available across isolates.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();
  final count = (prefs.getInt(_badgeCountKey) ?? 0) + 1;
  await prefs.setInt(_badgeCountKey, count);
  await FlutterNewBadger.setBadge(count);
}

class NotificationService {
  final NotificationRepo notificationRepo = NotificationRepo();
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  Future initNotification(int? userDesgId) async {
    try {
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            badge: true,
            provisional: false,
            sound: true,
          );
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        Toast.show(
          message:
              "Please allow notification permission to receive notifications about your jobs.",
        );
        return;
      }
      bool? grantedLocalPermission = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      if (grantedLocalPermission == false) {
        Toast.show(
          message:
              "Please allow notification permission to receive notifications about your jobs.",
        );
        return;
      }
      await getToken();
      saveFcmToken(userDesgId);

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@drawable/notification_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _handleNotificationTap(response.payload);
        },
      );

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _navigateToScreenFromData(message.data);
      });
    } catch (e, s) {
      log("Failed Init Notifications________${e}_______$s");
    }
  }

  Future<void> clearBadge() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_badgeCountKey, 0);
      await FlutterNewBadger.removeBadge();
    } catch (e) {
      log("Badge clear error: $e");
    }
  }

  Future<void> getToken() async {
    _fcmToken = await _firebaseMessaging.getToken();
    log("FCM_________$_fcmToken");
  }

  void _showNotification(RemoteMessage message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = (prefs.getInt(_badgeCountKey) ?? 0) + 1;
      await prefs.setInt(_badgeCountKey, count);
      await FlutterNewBadger.setBadge(count);

      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'your_channel_id',
            'your_channel_name',
            channelDescription: 'your_channel_description',
            importance: Importance.max,
            priority: Priority.high,
            number: count,
          );
      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        platformChannelSpecifics,
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      log("Show notification error: $e");
    }
  }

  Future<void> _handleNotificationTap(String? payload) async {
    if (payload == null) return;
    final data = jsonDecode(payload);
    _navigateToScreenFromData(data);
  }

  Future<void> _navigateToScreenFromData(Map<String, dynamic> data) async {}

  Future<void> saveFcmToken(int? desgId) async {
    try {
      await notificationRepo.storeNotificationToken(desgId, _fcmToken);
    } catch (e, s) {
      log("SAVE FCM ERR_______${e}_____$s");
    }
  }

  Future<void> clearFcmToken() async {
    _fcmToken = null;
  }
}
