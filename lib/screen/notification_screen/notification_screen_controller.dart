import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/model/notification/notification.dart';
import 'package:patient_flutter/services/api_service.dart';

class NotificationScreenController extends GetxController {
  List<NotificationData> notifications = [];
  bool isLoading = false;
  ScrollController scrollController = ScrollController();
  int start = 0;

  @override
  void onInit() {
    notificationApiCall();
    fetchScrollData();
    super.onInit();
  }

  void notificationApiCall() {
    isLoading = true;
    ApiService.instance
        .fetchNotification(start: notifications.length)
        .then((value) {
      notifications.addAll(value.data ?? []);
      isLoading = false;
      update();
    }).catchError((e) {
      isLoading = false;
      update();
    });
  }

  fetchScrollData() {
    scrollController.addListener(
      () {
        if (scrollController.offset ==
            scrollController.position.maxScrollExtent) {
          if (!isLoading) {
            notificationApiCall();
          }
        }
      },
    );
  }
}
