import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_flutter/common/common_fun.dart';
import 'package:doctor_flutter/common/confirmation_dialog.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/chat/chat.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/service/session_manager.dart';
import 'package:doctor_flutter/utils/firebase_res.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class MessageScreenController extends GetxController {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Conversation?> userList = [];
  bool isLoading = false;
  StreamSubscription<QuerySnapshot<Conversation>>? subscription;
  DoctorData? doctorData;
  String firebaseDoctorIdentity = '';

  @override
  void onInit() {
    getChatUsers();
    super.onInit();
  }

  void getChatUsers() async {
    doctorData = SessionManager.instance.getDoctor();
    firebaseDoctorIdentity = CommonFun.setDoctorId(doctorId: doctorData?.id);
    isLoading = true;
    subscription = db
        .collection(FirebaseRes.userChatList)
        .doc(firebaseDoctorIdentity)
        .collection(FirebaseRes.userList)
        .orderBy(FirebaseRes.time, descending: true)
        .where(FirebaseRes.isDeleted, isEqualTo: false)
        .withConverter(
            fromFirestore: Conversation.fromFirestore,
            toFirestore: (Conversation value, options) => value.toFirestore())
        .snapshots()
        .listen((element) {
      userList = [];
      for (int i = 0; i < element.docs.length; i++) {
        userList.add(element.docs[i].data());
      }
      isLoading = false;
      update();
    });
  }

  void onLongPress(Conversation? conversation) {
    HapticFeedback.vibrate();
    Get.dialog(
      ConfirmationDialog(
        aspectRatio: 1.5,
        title1: S.current.deleteChat,
        title2: S.current.areYouSureYouWantToDeleteThisChatAll,
        positiveText: S.current.delete,
        onPositiveTap: () {
          db
              .collection(FirebaseRes.userChatList)
              .doc(firebaseDoctorIdentity)
              .collection(FirebaseRes.userList)
              .doc(conversation?.user?.userIdentity)
              .update({
            FirebaseRes.isDeleted: true,
            FirebaseRes.deletedId: '${DateTime.now().millisecondsSinceEpoch}',
          });
        },
      ),
    );
    update();
  }

  @override
  void onClose() {
    subscription?.cancel();
    super.onClose();
  }
}
