import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_flutter/common/common_fun.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/chat/chat.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/model/doctor_category/doctor_category.dart';
import 'package:doctor_flutter/model/global/global_setting.dart';
import 'package:doctor_flutter/utils/firebase_res.dart';
import 'package:doctor_flutter/utils/update_res.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SessionManager {
  static var instance = SessionManager();
  var storage = GetStorage('doctor');
  var conversationId = '';
  RxInt notifyCount = 0.obs;
  RxInt isModerator = 0.obs;

  void setString({required String key, required String value}) {
    storage.write(key, value);
  }

  String? getString({required String key}) {
    return storage.read(key);
  }

  void setPassword(String? password) {
    storage.write(SessionKeys.password, password);
  }

  String? getPassword() {
    return storage.read(SessionKeys.password);
  }

  void setDoctor(DoctorData? user) {
    if (user != null) {
      // Convert the object to a JSON map and set 'stories' to null
      Map<String, dynamic> json = user.toJson();

      // Re-create the User object from the modified JSON map
      DoctorData newUser = DoctorData.fromJson(json);

      // Log the updated user object and store it
      // Loggers.success(user.toJson());
      storage.write(SessionKeys.user, newUser);
    }
  }

  DoctorData? getDoctor() {
    var user = storage.read(SessionKeys.user);

    if (user == null || user is DoctorData?) {
      return user;
    } else if (user is Map<String, dynamic>) {
      return DoctorData.fromJson(user);
    } else {
      return null;
    }
  }

  int getDoctorId() {
    return (getDoctor()?.id ?? 0).toInt();
  }

  String getIdentity() {
    return getDoctor()?.identity ?? '';
  }

  String getCurrency() {
    return getSettings()?.currency ?? dollar;
  }

  void setSettings(GlobalSettingData? settings) {
    storage.write(SessionKeys.setting, settings?.toJson());
  }

  GlobalSettingData? getSettings() {
    var data = storage.read(SessionKeys.setting);
    if (data is Map<String, dynamic>) {
      return GlobalSettingData.fromJson(data);
    } else if (data is GlobalSettingData) {
      return data;
    }
    return null;
  }

  bool isLogin() {
    return storage.read(SessionKeys.isLogin) ?? false;
  }

  void setLogin(bool isLog) {
    storage.write(SessionKeys.isLogin, true);
  }

  bool get shouldOpenEULASheet {
    return storage.read(SessionKeys.shouldOpenEULA) ?? true;
  }

  Future<void> setOpenEulaSheet(bool isLog) async {
    await storage.write(SessionKeys.shouldOpenEULA, isLog);
  }

  List<DoctorCategoryData> getCategories() {
    try {
      String jsonString = getString(key: kDoctorCategory) ?? '';
      if (jsonString.isEmpty) return [];
      List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => DoctorCategoryData.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  void updateFirebaseProfile() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DoctorData? doctorData = getDoctor();
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
          ChatUser? user = value.data()?.user;
          user?.username = doctorData?.name ?? S.current.unKnown;
          user?.image = doctorData?.image;
          user?.designation = doctorData?.designation;
          user?.userid = doctorData?.id;
          db
              .collection(FirebaseRes.userChatList)
              .doc(element.id)
              .collection(FirebaseRes.userList)
              .doc(doctorIdentity)
              .update({FirebaseRes.user: user?.toJson()});
        });
      }
    });
  }

  void clear() {
    storage.erase();
  }

  void clearSomeKey() {
    storage.remove(SessionKeys.isLogin);
    storage.remove(SessionKeys.user);
    storage.remove(SessionKeys.password);
  }
}

class SessionKeys {
  static const isLogin = "login";
  static const shouldOpenEULA = "should_open_eula";
  static const fallbackLang = "fallback_lang";
  static const lang = "lang";
  static const setting = "setting";
  static const user = "user";
  static const password = "password";
}
