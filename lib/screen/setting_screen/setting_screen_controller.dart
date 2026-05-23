import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_flutter/common/common_fun.dart';
import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/chat/chat.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/screen/setting_screen/widget/delete_account_sheet.dart';
import 'package:doctor_flutter/screen/splash_screen/splash_screen.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:doctor_flutter/service/firebase_notification_manager.dart';
import 'package:doctor_flutter/service/session_manager.dart';
import 'package:doctor_flutter/utils/firebase_res.dart';
import 'package:doctor_flutter/utils/update_res.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SettingScreenController extends GetxController {
  RxBool isNotification = false.obs;
  RxBool isVacationMode = false.obs;
  DoctorData? doctorData;
  FirebaseFirestore db = FirebaseFirestore.instance;

  SettingScreenController(DoctorData? data) {
    doctorData = data;
    isNotification.value = doctorData?.isNotification == 1;
    isVacationMode.value = doctorData?.onVacation == 1;
  }

  Timer? _debounce;

  @override
  void onInit() {
    getDoctorProfile();
    super.onInit();
  }

  void onPushNotificationTap() {
    CommonFun.doctorBanned(() async {
      isNotification.value = !isNotification.value;

      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () async {
        Registration value = await ApiService.instance
            .updateDoctorDetails(notification: isNotification.value ? 1 : 0);
        CustomUi.snackBar(message: value.message);
        if (value.status == false) {
          isNotification.value = isNotification.value ? false : true;
        } else {
          doctorData = value.data;
          if (isNotification.value) {
            FirebaseNotificationManager.shared.subscribeToTopic();
          } else {
            FirebaseNotificationManager.shared.unsubscribeToTopic();
          }
        }
      });
    });
  }

  void onVacationModeTap() {
    CommonFun.doctorBanned(() async {
      isVacationMode.value = !isVacationMode.value;

      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () async {
        Registration value = await ApiService.instance
            .updateDoctorDetails(vacationMode: isVacationMode.value ? 1 : 0);
        CustomUi.snackBar(message: value.message);
        if (value.status == false) {
          isVacationMode.value = isVacationMode.value ? false : true;
        } else {
          doctorData = value.data;
          if (isVacationMode.value) {
            updateFirebaseProfile(
                isDeleted: true,
                deletedId: '${DateTime.now().millisecondsSinceEpoch}');
          } else {
            updateFirebaseProfile(isDeleted: false, deletedId: '0');
          }
        }
      });
    });
  }

  void updateFirebaseProfile(
      {required bool isDeleted, required String deletedId}) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DoctorData? doctorData = SessionManager.instance.getDoctor();
    String doctorIdentity = CommonFun.setDoctorId(doctorId: doctorData?.id);
    db
        .collection(FirebaseRes.userChatList)
        .doc(doctorIdentity)
        .collection(FirebaseRes.userList)
        .withConverter(
          fromFirestore: Conversation.fromFirestore,
          toFirestore: (Conversation value, options) {
            return value.toFirestore();
          },
        )
        .get()
        .then((value) {
      for (var element in value.docs) {
        db
            .collection(FirebaseRes.userChatList)
            .doc(element.id)
            .collection(FirebaseRes.userList)
            .doc(doctorIdentity)
            .withConverter(
              fromFirestore: Conversation.fromFirestore,
              toFirestore: (Conversation value, options) {
                return value.toFirestore();
              },
            )
            .get()
            .then((value) {
          db
              .collection(FirebaseRes.userChatList)
              .doc(element.id)
              .collection(FirebaseRes.userList)
              .doc(doctorIdentity)
              .update({
            FirebaseRes.isDeleted: isDeleted,
            FirebaseRes.deletedId: deletedId
          });
        });
      }
    });
  }

  void getDoctorProfile() {
    ApiService.instance.fetchMyDoctorProfile().then((value) {
      doctorData = value.data;
    });
  }

  void onLogoutContinueTap() {
    ApiService.instance.logOutDoctor().then((value) async {
      if (value.status == true) {
        CustomUi.snackBar(
          message: value.message,
        );
        FirebaseAuth.instance.signOut();
        SessionManager.instance.clearSomeKey();
        Get.offAll(() => const SplashScreen());
      } else {
        CustomUi.snackBar(message: value.message);
      }
    });
  }

  void deleteMyAccountTap() {
    if (doctorData?.identity != testingEmail) {
      Get.bottomSheet(
          DeleteAccountSheet(
            onDeleteContinueTap: onDeleteContinueTap,
            title: S.current.deleteMyAccount,
            description: S.current.doYouReallyWantToEtc,
          ),
          isScrollControlled: true);
    } else {
      CustomUi.snackBar(message: S.current.youCantDeleteAAccount);
    }
  }

  void onDeleteContinueTap() {
    CustomUi.loader();
    ApiService.instance.deleteDoctorAccount().then((value) async {
      if (value.status == true) {
        await deleteFirebaseUser();
        SessionManager.instance.clearSomeKey();
        Get.back();
        CustomUi.snackBar(message: value.message);
        Get.offAll(() => const SplashScreen());
      } else {
        Get.back();
        CustomUi.snackBar(
          message: value.message,
        );
      }
    });
  }

  Future<void> deleteFirebaseUser() async {
    String doctorIdentity = CommonFun.setDoctorId(doctorId: doctorData?.id);
    String time = DateTime.now().millisecondsSinceEpoch.toString();
    await db
        .collection(FirebaseRes.userChatList)
        .doc(doctorIdentity)
        .collection(FirebaseRes.userList)
        .get()
        .then((value) {
      for (var element in value.docs) {
        db
            .collection(FirebaseRes.userChatList)
            .doc(element.id)
            .collection(FirebaseRes.userList)
            .doc(doctorIdentity)
            .update({
          FirebaseRes.isDeleted: true,
          FirebaseRes.deletedId: time,
        });
        db
            .collection(FirebaseRes.userChatList)
            .doc(doctorIdentity)
            .collection(FirebaseRes.userList)
            .doc(element.id)
            .update({
          FirebaseRes.isDeleted: true,
          FirebaseRes.deletedId: time,
        });
      }
    });
  }

  void onLogoutTap() {
    Get.bottomSheet(
        DeleteAccountSheet(
          onDeleteContinueTap: onLogoutContinueTap,
          title: S.current.logout,
          description: S.current.doYouReallyWantToLogoutEtc,
        ),
        isScrollControlled: true);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
