import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/common_fun.dart';
import 'package:patient_flutter/common/confirmation_dialog.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/chat/chat.dart';
import 'package:patient_flutter/model/global/global_setting.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/services/session_manager.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/firebase_res.dart';

class MessageScreenController extends GetxController {
  FirebaseFirestore db = FirebaseFirestore.instance;
  RxList<Conversation> userList = <Conversation>[].obs;
  RxBool isLoading = false.obs;
  StreamSubscription<QuerySnapshot<Conversation>>? subscription;
  UserData? userData;
  String firebaseUserId = '';

  GlobalSettingData? settingData;

  @override
  void onInit() {
    getChatUsers();
    super.onInit();
  }

  void getChatUsers() async {
    settingData = SessionManager.instance.getSettings();
    userData = SessionManager.instance.getUser();
    firebaseUserId = CommonFun.setPatientId(patientId: userData?.id);

    if (settingData?.enableChatbot == 1) {
      userList.insert(
          0,
          Conversation(
              isDeleted: false,
              conversationId: defaultChatGptName,
              deletedId: '',
              lastMsg: defaultChatGptDescription,
              time: DateTime.now().millisecondsSinceEpoch.toString(),
              user: ChatUser(
                image: settingData?.chatbotThumb,
                age: '0',
                designation: '',
                gender: '0',
                msgCount: 0,
                userid: 0,
                userIdentity: CommonFun.setDoctorId(doctorId: 0),
                userMail: settingData?.chatgptToken,
                username: settingData?.chatbotName,
              )));
    } else {
      print('object');
      db.collection(FirebaseRes.chat).doc(defaultChatGptName).delete();
    }

    isLoading.value = true;
    subscription = db
        .collection(FirebaseRes.userChatList)
        .doc(firebaseUserId)
        .collection(FirebaseRes.userList)
        .orderBy(FirebaseRes.time, descending: true)
        .where(FirebaseRes.isDeleted, isEqualTo: false)
        .withConverter(
            fromFirestore: Conversation.fromFirestore,
            toFirestore: (Conversation value, options) => value.toFirestore())
        .snapshots()
        .listen((element) {
      final conversationIds =
          userList.map((user) => user.conversationId).toSet();

      for (var doc in element.docs) {
        final data = doc.data();
        if (!conversationIds.contains(data.conversationId)) {
          userList.add(data);
          conversationIds.add(data.conversationId);
        }
      }

      isLoading.value = false;
    });
  }

  void onLongPress(Conversation? conversation) {
    HapticFeedback.vibrate();
    Get.dialog(
      ConfirmationDialog(
        aspectRatio: 1.4,
        positiveText: S.current.delete,
        title1: S.current.deleteChat,
        title2: S.current.areYouSureYouWantToDeleteThisChatThis,
        onPositiveTap: () {
          db
              .collection(FirebaseRes.userChatList)
              .doc(firebaseUserId)
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
