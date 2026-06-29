import 'dart:convert';
import 'dart:developer';

import 'package:efiling_balochistan/firebase_options.dart';
import 'package:efiling_balochistan/repository/notifications/notification_repo.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_new_badger/flutter_new_badger.dart';

// Must be a top-level function — runs in a separate isolate when app is
// background or killed.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final badge = _extractBadgeCount(message);
    if (badge > 0) {
      await FlutterNewBadger.setBadge(badge);
    }
  } catch (e, s) {}
}

int _extractBadgeCount(RemoteMessage message) {
  final androidCount = message.notification?.android?.count;
  if (androidCount != null && androidCount > 0) return androidCount;
  final iosBadge = int.tryParse(message.notification?.apple?.badge ?? '');
  if (iosBadge != null && iosBadge > 0) return iosBadge;
  return 0;
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
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );
      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _handleNotificationTap(response.payload);
        },
      );

      // Required for iOS to show alerts/badges while the app is in the foreground
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
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
      final badge = _extractBadgeCount(message);
      if (badge > 0) {
        await FlutterNewBadger.setBadge(badge);
      }

      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'your_channel_id',
            'your_channel_name',
            channelDescription: 'your_channel_description',
            importance: Importance.max,
            priority: Priority.high,
            number: badge,
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
