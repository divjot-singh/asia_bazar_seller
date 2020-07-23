import 'dart:convert';

import 'package:asia_bazar_seller/utils/constants.dart';
import 'package:asia_bazar_seller/utils/local_notification_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification {
  final Map<String, dynamic> notificationMessage;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final String operatingSystem;
  final int notificationId;

  LocalNotification({
    @required this.flutterLocalNotificationsPlugin,
    @required this.notificationMessage,
    @required this.operatingSystem,
    @required this.notificationId,
  });
}

class LocalNotificationAndroid extends LocalNotification {
  LocalNotificationAndroid({
    final Map<String, dynamic> notificationMessage,
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    final String operatingSystem,
    final int notificationId,
  }) : super(
          flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
          notificationMessage: notificationMessage,
          operatingSystem: operatingSystem,
          notificationId: notificationId,
        );

  String getTitle() {
    return notificationMessage['notification']["title"];
  }

  String getBody() {
    return notificationMessage['notification']["body"];
  }

  String getIcon() {
    return notificationMessage['data']["icon"];
  }

  String getRedirectPath() {
    var data = notificationMessage['data']["extra_data"];
    Map extraData = {...json.decode(data)};
    return NotificationTypes.fetchNotificationRoute(extraData);
  }

  // Future<Map<String, dynamic>> getArguments() async {
  //   var notificationData = notificationMessage["data"];
  //   if (notificationData.containsKey("arguments")) {
  //     var arguments = json.decode(notificationData["arguments"]);

  //     return arguments;
  //   }
  //   return {};
  // }

  showNotificationOnTray() async {
    showOngoingNotification(
      flutterLocalNotificationsPlugin,
      title: getTitle(),
      body: getBody(),
      id: notificationId,
      payload: {
        "redirectPath": getRedirectPath(),
        'icon': getIcon(),
        // "serverNotificationId": getServerNotificationId(),
        // "isAdminNotification": isAdminNotification(),
        // "arguments": await getArguments(),
      },
    );
  }
}

class LocalNotificationIos extends LocalNotification {
  LocalNotificationIos({
    final Map<String, dynamic> notificationMessage,
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    final String operatingSystem,
    final int notificationId,
  }) : super(
          flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
          notificationMessage: notificationMessage,
          operatingSystem: operatingSystem,
          notificationId: notificationId,
        );

  String getTitle() {
    return notificationMessage['notification']["title"];
  }

  String getBody() {
    return notificationMessage['notification']["body"];
  }

  String getIcon() {
    return notificationMessage["icon"];
  }

  String getRedirectPath() {
    var data = notificationMessage["extra_data"];
    Map extraData = {...json.decode(data)};
    return NotificationTypes.fetchNotificationRoute(extraData);
  }

  // Future<Map<String, dynamic>> getArguments() async {
  //   var notificationData = notificationMessage["data"];
  //   if (notificationData.containsKey("arguments")) {
  //     var arguments = json.decode(notificationData["arguments"]);

  //     return arguments;
  //   }
  //   return {};
  // }

  showNotificationOnTray() async {
    showOngoingNotification(
      flutterLocalNotificationsPlugin,
      title: getTitle(),
      body: getBody(),
      id: notificationId,
      payload: {
        "redirectPath": getRedirectPath(),
        'icon': getIcon(),
        // "serverNotificationId": getServerNotificationId(),
        // "isAdminNotification": isAdminNotification(),
        // "arguments": await getArguments(),
      },
    );
  }
}

dynamic getLocalNotification({
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

class NotificationTypes {
  static Map routeMap = {
    'ORDER_PLACED_NOTIFICATION': Constants.ORDER_DETAILS,
    'OUT_OF_STOCK_NOTIFICATION': Constants.CATEGORY_LISTING
  };
  static String fetchNotificationRoute(Map notificationData) {
    Map data = {...notificationData};
    String route = routeMap[data['notification_type']];
    if (route == null) return null;
    if (data['parameters'] is Map) {
      Map params = data['parameters'];
      params.forEach((key, value) {
        route = route.replaceAll(":$key", value);
      });
    }
    return route;
  }
}
