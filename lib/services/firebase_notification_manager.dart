import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/model/reels/add_reel.dart';
import 'package:patient_flutter/screen/appointment_chat_screen/appointment_chat_screen_controller.dart';
import 'package:patient_flutter/screen/appointment_detail_screen/appointment_detail_screen.dart';
import 'package:patient_flutter/screen/message_chat_screen/message_chat_screen_controller.dart';
import 'package:patient_flutter/screen/reels_screen/reels_screen.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/services/session_manager.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/update_res.dart';
import 'package:patient_flutter/utils/urls.dart';

class FirebaseNotificationManager {
  static var shared = FirebaseNotificationManager();
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String? messageId;

  AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'patient', // id
      appName, // title
      playSound: true,
      enableLights: true,
      enableVibration: true,
      showBadge: false,
      importance: Importance.max);
  NotificationDetails notificationDetails = const NotificationDetails(
    android: AndroidNotificationDetails('patient', appName,
        playSound: true,
        priority: Priority.max,
        category: AndroidNotificationCategory.reminder,
        channelShowBadge: true,
        showWhen: true),
    iOS: DarwinNotificationDetails(
        presentSound: true,
        presentAlert: true,
        presentBadge: true,
        presentBanner: true),
  );

  FirebaseNotificationManager() {
    init();
  }

  void init() async {
    if (kIsWeb) return; // Local notifications not supported on web
    subscribeToTopic();
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } else {
      await firebaseMessaging.requestPermission(
          alert: true, badge: false, sound: true, announcement: true);

      await firebaseMessaging.setForegroundNotificationPresentationOptions(
          alert: true, badge: false, sound: true);
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      debugPrint('APNS Token: $apnsToken');
    }

    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettingsIOS = const DarwinInitializationSettings(
        defaultPresentAlert: true,
        defaultPresentSound: true,
        defaultPresentBadge: false);

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('✅ onDidReceiveNotificationResponse');
        if (details.payload != null) {
          try {
            Payload payload = Payload.fromJson(jsonDecode(details.payload!));
            onNotificationTap(payload);
          } catch (e) {
            debugPrint('Notification payload parse error: $e');
          }
        }
      },
    );

    FirebaseMessaging.instance.onTokenRefresh.listen((event) {
      debugPrint('Token Refresh : $event');
    });

    // Handle notification tap when app is in the background (not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🔔 onMessageOpenedApp : ${message.data}');
      try {
        Payload payload = Payload.fromJson(message.data);
        onNotificationTap(payload);
      } catch (e) {
        debugPrint('onMessageOpenedApp payload error: $e');
      }
    });

    // Handle notification tap when app was terminated
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('🔔 getInitialMessage : ${message.data}');
        Future.delayed(const Duration(seconds: 1), () {
          try {
            Payload payload = Payload.fromJson(message.data);
            onNotificationTap(payload);
          } catch (e) {
            debugPrint('getInitialMessage payload error: $e');
          }
        });
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (messageId == message.messageId) return;
      messageId = message.messageId;

      debugPrint('🐦‍🔥🐦‍🔥🐦‍🔥🐦‍🔥 onMessage : ${message.toMap()}');

      if (message.data[nNotificationType] == '0') {
        if (message.data[nSenderId] != MessageChatScreenController.senderId) {
          showNotification(message);
        }
        return;
      }
      if (message.data[nNotificationType] == '1') {
        if (message.data[nAppointmentId] !=
            AppointmentChatScreenController.appointmentId) {
          showNotification(message);
        }
        return;
      }
      showNotification(message);
    });

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void showNotification(RemoteMessage message) {
    final String title =
        message.data['title'] ?? message.notification?.title ?? appName;
    final String body =
        message.data['body'] ?? message.notification?.body ?? '';
    flutterLocalNotificationsPlugin.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        iOS: const DarwinNotificationDetails(
            presentSound: true,
            presentAlert: true,
            presentBadge: true,
            presentBanner: true),
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void getNotificationToken(Function(String token) completion) async {
    try {
      await FirebaseMessaging.instance.getToken().then((value) {
        debugPrint('DeviceToken : $value');
        completion(value ?? 'No Token');
      });
    } catch (e) {
      log(e.toString());
    }
  }

  void unsubscribeToTopic({String? topic}) async {
    await firebaseMessaging.unsubscribeFromTopic(ConstRes.subscribeTopic);
  }

  void subscribeToTopic({String? topic}) async {
    await firebaseMessaging.subscribeToTopic(ConstRes.subscribeTopic);
  }

  void onNotificationTap(Payload payload) {
    if (payload.type == 1) {
      ApiService.instance.call(
        url: Urls.fetchReelByIdPatient,
        param: {
          pReelId: payload.id,
          pUserId: SessionManager.instance.getUserID()
        },
        completion: (response) {
          AddReel data = AddReel.fromJson(response);
          if (data.status == true) {
            if (data.data != null) {
              Get.to(() => ReelsScreen(reels: [data.data!].obs, position: 0));
            }
          }
        },
      );

      return;
    }
    if (payload.type == 0) {
      ApiService.instance
          .fetchAppointmentDetails(appointmentId: payload.id)
          .then(
        (value) {
          if (value.status == true) {
            Get.to(() => const AppointmentDetailScreen(),
                arguments: value.data);
          }
        },
      );
    }
  }
}

class Payload {
  int? id;
  int? type;

  Payload({this.id, this.type});

  Payload.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id']);
    type = int.parse(json['type']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    return data;
  }
}
