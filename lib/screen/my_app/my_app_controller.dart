import 'dart:developer';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:doctor_flutter/utils/update_res.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class MyAppController extends GetxController {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String languageCode = 'en';

  @override
  void onInit() {
    log('onInit');
    fetchSettingData();
    if (!kIsWeb) AppBadgePlus.updateBadge(0);
    super.onInit();
  }

  void fetchSettingData() {
    ApiService.instance.fetchGlobalSettings().then((value) {
      dollar = value.data?.currency == null || value.data!.currency!.isEmpty
          ? '\$'
          : (value.data?.currency ?? '\$');
    });
  }
}
