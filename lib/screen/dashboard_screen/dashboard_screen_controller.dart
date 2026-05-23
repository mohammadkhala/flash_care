import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/chat/chat.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/model/doctor_category/doctor_category.dart';
import 'package:doctor_flutter/model/reel/reels.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:doctor_flutter/service/firebase_notification_manager.dart';
import 'package:doctor_flutter/service/session_manager.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/firebase_res.dart';
import 'package:doctor_flutter/utils/urls.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class DashboardScreenController extends GetxController {
  RxInt currentIndex = 0.obs;

  Color inactiveColor = ColorRes.grey;

  DoctorData? doctorData;

  static bool isPlayController = false;
  Function(int index)? onBottomIndexChanged;

  FirebaseFirestore db = FirebaseFirestore.instance;

  RxList<Reel> reels = <Reel>[].obs;
  RxList<int> unReadMessages = <int>[].obs;
  RxList<DoctorCategoryData> doctorCategoryData =
      [DoctorCategoryData(id: 0, title: 'Mix')].obs;

  @override
  void onInit() {
    prefData();
    super.onInit();
  }

  void onItemSelected(int value) {
    if (value == 2) {
      isPlayController = true;
    } else {
      isPlayController = false;
    }
    onBottomIndexChanged?.call(value);

    if (currentIndex.value == value) return;
    if (doctorData?.status == 2) {
      HapticFeedback.heavyImpact();
      if ([1, 2, 3].any((element) {
        return element == value;
      })) {
        CustomUi.snackBar(message: S.current.doctorBlockByAdmin);
        return;
      }
    }
    currentIndex.value = value;
    update();
  }

  Future<void> prefData() async {
    doctorData = SessionManager.instance.getDoctor();
    initChatCount(doctorData);
    fetchReelsDoctorApp();
    fetchDoctorCategory();
    getBackgroundNotificationTap();
  }

  void fetchReelsDoctorApp() {
    ApiService.instance.call(
      url: Urls.fetchReelsDoctorApp,
      param: {pDoctorId: doctorData?.id},
      completion: (response) {
        Reels data = Reels.fromJson(response);
        if (data.status == true) {
          reels.addAll(data.data ?? []);
        }
      },
    );
  }

  void initChatCount(DoctorData? doctorData) async {
    db
        .collection(FirebaseRes.userChatList)
        .doc('${doctorData?.id}D')
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

  void fetchDoctorCategory() {
    ApiService.instance.call(
      url: Urls.fetchDoctorCategories,
      completion: (response) {
        DoctorCategory data = DoctorCategory.fromJson(response);
        if (data.status == true) {
          doctorCategoryData.addAll(data.data ?? []);
        }
      },
    );
  }

  void getBackgroundNotificationTap() {
    if (!kIsWeb && Platform.isAndroid) {
      FlutterLocalNotificationsPlugin()
          .getNotificationAppLaunchDetails()
          .then((value) {
        if (value?.notificationResponse == null) return;
        debugPrint('✅ getNotificationAppLaunchDetails');
        try {
          final payload = value?.notificationResponse?.payload ?? '';
          if (payload.isEmpty) return;
          Payload p = Payload.fromJson(jsonDecode(payload));
          FirebaseNotificationManager.shared.onNotificationTap(p);
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
      Payload payload = Payload.fromJson(value.data);
      FirebaseNotificationManager.shared.onNotificationTap(payload);
    });

    // when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      Payload payload = Payload.fromJson(event.data);
      debugPrint('✅ onMessageOpenedApp');
      FirebaseNotificationManager.shared.onNotificationTap(payload);
    });
  }
}
