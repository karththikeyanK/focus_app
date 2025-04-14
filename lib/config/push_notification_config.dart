import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> handleBackgroundMsg(RemoteMessage message) async {
  print('📥 Handling background message: ${message.notification?.title}, ${message.notification?.body}');
  // You can handle navigation or logic here if needed
}

class PushNotificationConfig {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initialise() async {
    // Request permission for iOS
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Print FCM token
    final fcmToken = await _fcm.getToken();
    print('📡 FCM Token: $fcmToken');

    // Initialize local notifications
    _initializeLocalNotifications();

    // Foreground message handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📲 Foreground message: ${message.notification?.title}, ${message.notification?.body}');
      print('📦 Data: ${message.data}');
      _showNotification(message);
    });

    // App opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🚀 Notification tapped: ${message.notification?.title}');
      _handleNavigation(message.data); // leave empty logic
    });

    // Background message handler
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMsg);
  }

  void _initializeLocalNotifications() {
    const androidInitSettings = AndroidInitializationSettings('@drawable/ico');

    const initSettings = InitializationSettings(
      android: androidInitSettings,
    );

    _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          Map<String, dynamic> data = jsonDecode(response.payload!);
          _handleNavigation(data); // leave empty logic
        }
      },
    );
  }

  static void _showNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel', // Channel ID
      'High Importance Notifications', // Channel name
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ico',
      largeIcon: DrawableResourceAndroidBitmap('ico'),
      styleInformation: BigTextStyleInformation(''),
    );

    const platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotificationsPlugin.show(
      0, // Notification ID
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? 'You have a new message',
      platformDetails,
      payload: jsonEncode(message.data),
    );
  }

  void _handleNavigation(Map<String, dynamic> data) {
    // Leave this empty for now
    print('🧭 Handle navigation here with data: $data');
  }

  Future<String?> getFCMToken() {
    return _fcm.getToken();
  }
}
