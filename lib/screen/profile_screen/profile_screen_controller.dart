import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/common_fun.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/screen/edit_profile_screen/edit_profile_screen.dart';
import 'package:patient_flutter/screen/splash_screen/splash_screen.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/services/session_manager.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/firebase_res.dart';
import 'package:patient_flutter/utils/update_res.dart';

class ProfileScreenController extends GetxController {
  bool isNotification = false;
  UserData? userData;
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void onInit() {
    fetchPatientApiCall();
    prefData();
    super.onInit();
  }

  void onNotificationTap() {
    CustomUi.loader();
    ApiService.instance
        .updateUserDetails(isNotification: isNotification ? 0 : 1)
        .then((value) {
      isNotification = value.data?.isNotification == 1;
      if (isNotification) {
        FirebaseMessaging.instance.subscribeToTopic(ConstRes.subscribeTopic);
      } else {
        FirebaseMessaging.instance
            .unsubscribeFromTopic(ConstRes.subscribeTopic);
      }
      Get.back();
      update([kNotificationUpdate]);
    });
  }

  void prefData() async {
    userData = SessionManager.instance.getUser();
    isNotification = userData?.isNotification == 1;
    update([kProfileUpdate, kNotificationUpdate]);
  }

  void onEditProfileNavigate() {
    Get.to(() => const EditProfileScreen())?.then((value) {
      userData = SessionManager.instance.getUser();
      update([kProfileUpdate]);
    });
  }

  void onLogoutTap() {
    ApiService.instance.logOut().then((value) async {
      if (value.status == true) {
        SessionManager.instance.clear();
        CustomUi.snackBar(
          message: value.message,
        );
        Get.offAll(() => const SplashScreen());
      } else {
        CustomUi.snackBar(message: value.message);
      }
    });
  }

  void fetchPatientApiCall() {
    ApiService.instance.fetchPatient();
  }

  void onDeleteContinueTap() {
    CustomUi.loader();
    ApiService.instance.deleteUserAccount().then((value) async {
      if (value.status == true) {
        await deleteFirebaseUser();
        SessionManager.instance.clear();
        Get.back();
        CustomUi.snackBar(
          message: value.message ?? '',
        );
        Get.offAll(() => const SplashScreen());
      } else {
        Get.back();
        CustomUi.snackBar(
          message: value.message ?? '',
        );
      }
    });
  }

  Future<void> deleteFirebaseUser() async {
    String patientId = CommonFun.setPatientId(patientId: userData?.id);
    String time = DateTime.now().millisecondsSinceEpoch.toString();
    await db
        .collection(FirebaseRes.userChatList)
        .doc(patientId)
        .collection(FirebaseRes.userList)
        .get()
        .then((value) {
      for (var element in value.docs) {
        db
            .collection(FirebaseRes.userChatList)
            .doc(element.id)
            .collection(FirebaseRes.userList)
            .doc(patientId)
            .update({FirebaseRes.isDeleted: true, FirebaseRes.deletedId: time});
        db
            .collection(FirebaseRes.userChatList)
            .doc(patientId)
            .collection(FirebaseRes.userList)
            .doc(element.id)
            .update({FirebaseRes.isDeleted: true, FirebaseRes.deletedId: time});
      }
    });
  }
}
