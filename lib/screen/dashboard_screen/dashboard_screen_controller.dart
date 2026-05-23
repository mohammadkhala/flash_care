import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/model/chat/chat.dart';
import 'package:patient_flutter/model/reels/reels.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/services/firebase_notification_manager.dart';
import 'package:patient_flutter/services/session_manager.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/firebase_res.dart';
import 'package:patient_flutter/utils/urls.dart';

class DashboardScreenController extends GetxController {
  RxInt currentIndex = 0.obs;
  final inactiveColor = ColorRes.grey;
  FirebaseFirestore db = FirebaseFirestore.instance;
  UserData? userData;
  RxList<Reel> reels = <Reel>[].obs;
  RxList<int> unReadMessages = <int>[].obs;
  Function(int index)? onBottomIndexChanged;

  static RxBool isPlayController = false.obs;

  void onItemSelected(int value) {
    if (value == 3) {
      isPlayController.value = true;
    } else {
      isPlayController.value = false;
    }
    currentIndex.value = value;
    onBottomIndexChanged?.call(value);

    update();
  }

  @override
  void onInit() {
    super.onInit();
    prefData();
  }

  Future<void> prefData() async {
    userData = SessionManager.instance.getUser();
    initChatCount(userData);
    fetchReelsPatientApp();
    getBackgroundNotificationTap();
  }

  void initChatCount(UserData? userData) async {
    db
        .collection(FirebaseRes.userChatList)
        .doc('${userData?.id}P')
        .collection(FirebaseRes.userList)
        .withConverter(
            fromFirestore: (snapshot, options) =>
                Conversation.fromJson(snapshot.data()!),
            toFirestore: (Conversation value, options) {
              return value.toJson();
            })
        .snapshots()
        .listen((event) {
      unReadMessages.value = [];
      for (int i = 0; i < event.docs.length; i++) {
        if ((event.docs[i].data().user?.msgCount ?? 0) > 0) {
          unReadMessages.add(i);
        }
      }
    });
  }

  void fetchReelsPatientApp() {
    ApiService.instance.call(
      url: Urls.fetchReelsPatientApp,
      param: {pUserId: userData?.id},
      completion: (response) {
        Reels data = Reels.fromJson(response);
        if (data.status == true) {
          reels.addAll(data.data ?? []);
        }
      },
    );
  }

  void getBackgroundNotificationTap() {
    if (kIsWeb) return; // FCM background/tap not applicable on web

    if (Platform.isAndroid) {
      FlutterLocalNotificationsPlugin()
          .getNotificationAppLaunchDetails()
          .then((value) {
        if (value?.notificationResponse == null) return;
        if (value?.notificationResponse?.payload == null) return;
        debugPrint('✅ getNotificationAppLaunchDetails');
        try {
          Payload payload = Payload.fromJson(
              jsonDecode(value?.notificationResponse?.payload ?? ''));
          FirebaseNotificationManager.shared.onNotificationTap(payload);
        } catch (e) {
          debugPrint('Notification payload parse error: $e');
        }
      });
    }

    // a terminated state.
    FirebaseMessaging.instance.getInitialMessage().then((value) {
      if (value == null) return;
      if (value.data.isEmpty) return;
      debugPrint('✅ getInitialMessage');
      try {
        Payload payload = Payload.fromJson(value.data);
        FirebaseNotificationManager.shared.onNotificationTap(payload);
      } catch (e) {
        debugPrint('getInitialMessage payload error: $e');
      }
    });

    // when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      debugPrint('✅ onMessageOpenedApp');
      try {
        Payload payload = Payload.fromJson(event.data);
        FirebaseNotificationManager.shared.onNotificationTap(payload);
      } catch (e) {
        debugPrint('onMessageOpenedApp payload error: $e');
      }
    });
  }
}
