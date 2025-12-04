// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'dart:io' show Platform;
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// @pragma('vm:entry-point')
// class FirebaseService {
//   static Future<void> initializeFirebase() async {
//     if (!kIsWeb && Platform.isAndroid) {
//       await Firebase.initializeApp();
//       await requestNotificationPermissions();
//       await setupFirebaseMessaging();
//       await _initializeLocalNotifications();
//     }
//   }

//   static Future<void> requestNotificationPermissions() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;

//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('✅ User granted permission');
//     } else {
//       print('❌ User declined permission');
//     }
//   }

//   static Future<void> setupFirebaseMessaging() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;

//     // Get device token
//     String? token = await messaging.getToken();
//     print("Device Token: $token");

//     // Foreground message listener
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print("Foreground Message: ${message.data}");
//       _handleMessage(message);
//     });

//     // Background message handler
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   }

//   @pragma('vm:entry-point')
//   static Future<void> _firebaseMessagingBackgroundHandler(
//       RemoteMessage message) async {
//     print("Background Message: ${message.data}");
//     _handleMessage(message);
//   }

//   static Future<void> _handleMessage(RemoteMessage message) async {
//     if (message.data.containsKey('count')) {
//       int counter = int.tryParse(message.data['count'] ?? '0') ?? 0;
//       print("🔢 Counter received: $counter");

//       if (counter % 2 == 1) {
//         print("🟢 Counter is ODD, showing notification...");
//         await _showLocalNotification(message);
//       } else {
//         print("🔴 Counter is EVEN, no notification displayed.");
//       }
//     }
//   }

//   static Future<void> _initializeLocalNotifications() async {
//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: androidSettings);

//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

//   static Future<void> _showLocalNotification(RemoteMessage message) async {
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       'high_importance_channel',
//       'High Importance Notifications',
//       importance: Importance.high,
//       priority: Priority.high,
//       showWhen: true,
//     );

//     const NotificationDetails notificationDetails =
//         NotificationDetails(android: androidDetails);

//     // Get title and body from data if they exist, otherwise fallback to notification payload
//     String title = message.data['title'] ??
//         message.notification?.title ??
//         "New Notification";
//     String body = message.data['body'] ??
//         message.notification?.body ??
//         "You have a new message";

//     await flutterLocalNotificationsPlugin.show(
//       DateTime.now().millisecondsSinceEpoch.remainder(100000), // Use unique ID // Notification ID
//       title,
//       body,
//       notificationDetails,
//     );
//   }
// }
