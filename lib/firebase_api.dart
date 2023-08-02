import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notification/homescreen.dart';
import 'package:push_notification/message.dart';
import 'package:push_notification/notification.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotification = FlutterLocalNotificationsPlugin();

  Future initNotification(BuildContext context) async {
    await _firebaseMessaging.requestPermission();

    _firebaseMessaging.getToken().then((value) {
      print("><><><><<>${value}");
    });

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((event) {
      final notification = event.notification;
      if (notification == null) return;
      _localNotification.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            color: Colors.blue,
            icon: "@mipmap/ic_launcher",
            priority:  Priority.max
          ),
        ),
        payload: jsonEncode(event.toMap()),
      );
      initLocalNotification(context,event);
    });
  }

  Future<void> initLocalNotification(BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    var iosInitializationSettings = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings
    );
    await _localNotification.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload){
        handleMessage (context, message);
      }
    );
  }

  Future<void> setUpInterectMessage(BuildContext context) async {

    //When App kill or terminated
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if(initialMessage != null){
      handleMessage(context,initialMessage);
    }

    //When App background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("><><>title<><<>${message.notification?.title}");
  print("><><>Body<><<>${message.notification?.body}");
  print("><><>Payload<><<>${message.data}");
}

const _channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications',
  description: "This channel is used for important notifications.",
  importance: Importance.defaultImportance,
  showBadge: true,
);

void handleMessage(BuildContext context ,RemoteMessage? message) {
  if (message?.data["type"] == "message")
    {
      Navigator.push(context, MaterialPageRoute(builder:
      (context) => const MessageWidget()));
    }
  else if(message?.data["type"] == "notification"){
    Navigator.push(context, MaterialPageRoute(builder:
        (context) => const NotificationWidget()));
  }
  else if(message?.data["type"] == "home"){
    Navigator.push(context, MaterialPageRoute(builder:
        (context) => const HomeScreen()));
  }
}
