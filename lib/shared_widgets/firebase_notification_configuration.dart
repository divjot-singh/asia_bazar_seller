import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:asia_bazar_seller/repository/authentication.dart';
import 'package:asia_bazar_seller/utils/local_notifications.dart';
import 'package:asia_bazar_seller/utils/navigator_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ConfigureNotification {
  static Future<FirebaseApp> initializeApp() async {
    if (Firebase.apps.length == 0)
      return await Firebase.initializeApp();
    else {
      return Firebase.apps[0];
    }
  }

  static FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static int notificationId = 0;
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    //await ConfigureNotification.initializeApp();
    print('Handling a background message ${message.messageId}');
  }

  static Future<void> setUpFCMToken() async {
    AuthRepo authRepo = new AuthRepo();
    String userId = FirebaseAuth.instance.currentUser.uid;
    String firebaseToken = await _fcm.getToken();
    _fcm.onTokenRefresh.listen((token) {
      authRepo.setUpFcm(userId: userId, token: firebaseToken);
    });
    await authRepo.setUpFcm(userId: userId, token: firebaseToken);
  }

  static void configureNotifications() async {
    final androidInitializationSettings = AndroidInitializationSettings(
      '@drawable/launch_background',
    );
    final iosInitializationSettings = IOSInitializationSettings();
    final initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'Messages', // title
      'This channel is used for displaying messages.', // description
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onForegroundNotificationClick,
    );
    RemoteMessage initialMessage = await _fcm.getInitialMessage();
    // log(initialMessage.toString());
    if (initialMessage != null) {
      await onBackgroundNotificationClick(initialMessage.data);
    }
    //handle background messages
    FirebaseMessaging.onBackgroundMessage(
        ConfigureNotification._firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //RemoteNotification notification = message.notification;
      print('message recieved');
      onForegroundNotification(message.data);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print('A new onMessageOpenedApp event was published!');
      await onBackgroundNotificationClick(message.data);
    });

    if (Platform.isIOS) {
      _fcm.requestPermission(
        sound: true,
        badge: true,
        alert: true,
        provisional: true,
      );
    }
  }

  static Future<void> onForegroundNotificationClick(String payload) async {
    if (payload != null) {
      var payloadJson = json.decode(payload);

      var redirectPath = payloadJson['redirectPath'];
      //var arguments = payloadJson['arguments'];
      locator<NavigationService>().navigateTo(redirectPath);
    }
  }

  static void onForegroundNotification(Map<String, dynamic> message) {
    print(message);
    var operatingSystem = Platform.operatingSystem;
    var localNotification = getLocalNotification(
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      notificationMessage: message,
      notificationId: notificationId,
      operatingSystem: operatingSystem,
    );
    if (localNotification == null) {
      print("Operating system not supported!");
      return;
    }

    localNotification.showNotificationOnTray();
    notificationId += 1;
  }

  static Future<void> onBackgroundNotificationClick(
    Map<String, dynamic> message,
  ) async {
    print('inside bg click');
    var operatingSystem = Platform.operatingSystem;
    var localNotification = getLocalNotification(
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      notificationMessage: message,
      notificationId: notificationId,
      operatingSystem: operatingSystem,
    );
    if (localNotification == null) {
      print("Operating system not supported!");
      return;
    }

    notificationId += 1;
    var redirectPath = localNotification.getRedirectPath();
    //var arguments = await localNotification.getArguments();
    locator<NavigationService>().navigateTo(redirectPath);
  }

  static dynamic getLocalNotification({
    Map<String, dynamic> notificationMessage,
    BuildContext context,
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    String operatingSystem,
    int notificationId,
  }) {
    if (operatingSystem == 'android') {
      return LocalNotificationAndroid(
        flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
        notificationMessage: notificationMessage,
        operatingSystem: operatingSystem,
        notificationId: notificationId,
      );
    } else if (operatingSystem == 'ios') {
      return LocalNotificationIos(
        flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
        notificationMessage: notificationMessage,
        operatingSystem: operatingSystem,
        notificationId: notificationId,
      );
    }
    return null;
  }
}
