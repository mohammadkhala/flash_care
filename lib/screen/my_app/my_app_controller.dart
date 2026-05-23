import 'dart:io';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/screen/appointment_chat_screen/appointment_chat_screen_controller.dart';
import 'package:patient_flutter/screen/message_chat_screen/message_chat_screen_controller.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/update_res.dart';

class MyAppController extends GetxController {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  int notificationCount = 0;

  @override
  void onInit() {
    // saveTokenUpdate();
    if (!kIsWeb) AppBadgePlus.updateBadge(0);
    super.onInit();
  }

  void saveTokenUpdate() async {
    await FirebaseMessaging.instance.subscribeToTopic(ConstRes.subscribeTopic);

    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } else {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(sound: true, alert: true);
    }

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.max,
        showBadge: false);

    /// Required to display a heads up notification (For iOS)
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: false, sound: true);

    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const DarwinInitializationSettings(
        requestAlertPermission: true,
        requestSoundPermission: true,
        requestBadgePermission: false);
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        print('😀 :- ${details.payload}');
      },
    );

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        print('🐦‍🔥🐦‍🔥🐦‍🔥🐦‍🔥 Patient : ${message.toMap()}');

        if (message.data[nNotificationType] == '0') {
          if (message.data[nSenderId] != MessageChatScreenController.senderId) {
            showNotification(
                channel: channel,
                notification: message.data,
                remoteNotification: message.notification);
          }
          return;
        }
        if (message.data[nNotificationType] == '1') {
          if (message.data[nAppointmentId] !=
              AppointmentChatScreenController.appointmentId) {
            showNotification(
                channel: channel,
                notification: message.data,
                remoteNotification: message.notification);
          }
          return;
        }
        showNotification(
            channel: channel,
            notification: message.data,
            remoteNotification: message.notification);
      },
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void showNotification(
      {Map<String, dynamic>? notification,
      required AndroidNotificationChannel channel,
      required RemoteNotification? remoteNotification}) {
    flutterLocalNotificationsPlugin.show(
      1,
      notification?[nTitle] ?? remoteNotification?.title,
      notification?[nBody] ?? remoteNotification?.body,
      NotificationDetails(
        android: AndroidNotificationDetails(channel.id, channel.name,
            channelShowBadge: channel.showBadge,
            importance: channel.importance),
        iOS: const DarwinNotificationDetails(
            presentSound: true, presentAlert: true, presentBadge: false),
      ),
    );
  }
}
