import 'dart:convert';

import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
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

  Future initNotification() async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        Toast.show(
            message:
                "Please allow notification permission to receive notifications about your jobs.");
        return;
      }
      bool? grantedLocalPermission = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      if (grantedLocalPermission == false) {
        Toast.show(
            message:
                "Please allow notification permission to receive notifications about your jobs.");
        return;
      }
      await getToken();
      saveFcmToken();

      // Initialize local notification settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@drawable/notification_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
      );
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
    } catch (e) {}
  }

  Future<void> getToken() async {
    _fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $_fcmToken');
  }

  void _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: jsonEncode(message.data), // Pass data as payload
    );
  }

  Future<void> _handleNotificationTap(String? payload) async {
    if (payload == null) return;
    final data = jsonDecode(payload);
    _navigateToScreenFromData(data);
  }

  Future<void> _navigateToScreenFromData(Map<String, dynamic> data) async {
    // if (data['job_id'] != null) {
    //   int jobId = int.parse(data['job_id']);
    //   int? status;
    //   if (data['status'] != null) {
    //     status = int.parse(data['status']);
    //   }
    //   Job? job = await assessmentController.getJob(jobId);
    //   await Future.delayed(const Duration(seconds: 500));
    //   if (job != null) {
    //     homeController.checkAssess(
    //       job,
    //       status ?? job.jobMobileStatus?.first.jobId,
    //     );
    //   }
    // }
  }

  Future<void> saveFcmToken() async {
    // try {
    //   await postApi(
    //     saveFcmTokenApi,
    //     json.encode({'fcm_token': fcmToken}),
    //   );
    // } catch (e, s) {
    //   print("FCM ERR_______${e}_____$s");
    // }
  }

  Future<void> clearFcmToken() async {
    _fcmToken = null;
    // try {
    //   await postApi(
    //     saveFcmTokenApi,
    //     json.encode({'fcm_token': _fcmToken}),
    //   );
    // } catch (e, s) {
    //   print("FCM ERR_______${e}_____$s");
    // }
  }
}
