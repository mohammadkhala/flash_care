import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:doctor_flutter/model/reel/add_reel.dart';
import 'package:doctor_flutter/screen/appointment_chat_screen/appointment_chat_screen_controller.dart';
import 'package:doctor_flutter/screen/appointment_detail_screen/appointment_detail_screen.dart';
import 'package:doctor_flutter/screen/message_chat_screen/message_chat_screen_controller.dart';
import 'package:doctor_flutter/screen/reels_screen/reels_screen.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:doctor_flutter/service/session_manager.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:doctor_flutter/utils/update_res.dart';
import 'package:doctor_flutter/utils/urls.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class FirebaseNotificationManager {
  static var shared = FirebaseNotificationManager();
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'doctor', // id
      appName, // title
      playSound: true,
      enableLights: true,
      enableVibration: true,
      showBadge: false,
      importance: Importance.max);

  NotificationDetails notificationDetails = const NotificationDetails(
    android: AndroidNotificationDetails('doctor', appName,
        playSound: true,
        priority: Priority.max,
        category: AndroidNotificationCategory.reminder,
        channelShowBadge: false),
    iOS: DarwinNotificationDetails(
        presentSound: true,
        presentAlert: true,
        presentBadge: false,
        presentBanner: false),
  );

  String? messageId;

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
        alert: true,
        badge: false,
        sound: true,
      );
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
          Payload payload = Payload.fromJson(jsonDecode(details.payload!));
          onNotificationTap(payload);
        }
      },
    );

    // FirebaseMessaging.instance.onTokenRefresh.listen(
    //   (event) {
    //     debugPrint('👉 Token Refresh$event');
    //   },
    // );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('🐦‍🔥🐦‍🔥🐦‍🔥🐦‍🔥 onMessage ${message.toMap()}');
      if (messageId == message.messageId) return;
      messageId = message.messageId;
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
    if (Platform.isAndroid) {
      debugPrint(
          'Show Flutter Local Notification ${message.toMap()}\nNotification: ${message.notification?.toMap()}');
      flutterLocalNotificationsPlugin.show(
        1,
        message.data['title'] ?? message.notification?.title,
        message.data['body'] ?? message.notification?.body,
        notificationDetails,
        payload: jsonEncode(message.data),
      );
    }
  }

  void getNotificationToken(Function(String token) completion) async {
    try {
      await firebaseMessaging.getToken().then((value) {
        log(
          'DeviceToken : $value',
        );
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
        url: Urls.fetchReelByIdDoctor,
        param: {
          pReelId: payload.id,
          pDoctorId: SessionManager.instance.getDoctorId()
        },
        completion: (response) {
          AddReel data = AddReel.fromJson(response);
          if (data.status == true && data.data != null) {
            Get.to(() => ReelsScreen(
                  reels: [data.data!].obs,
                  position: 0,
                ));
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
            Get.to(() => AppointmentDetailScreen(appointmentData: value.data));
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
