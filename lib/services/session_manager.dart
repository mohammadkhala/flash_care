import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:patient_flutter/common/common_fun.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/chat/chat.dart';
import 'package:patient_flutter/model/custom/countries.dart';
import 'package:patient_flutter/model/global/global_setting.dart';
import 'package:patient_flutter/model/home/home.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/firebase_res.dart';
import 'package:patient_flutter/utils/update_res.dart';

class SessionManager {
  static var instance = SessionManager();
  var storage = GetStorage('patient');
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

  void setUser(UserData? user) {
    if (user != null) {
      // Convert the object to a JSON map and set 'stories' to null
      Map<String, dynamic> json = user.toJson();

      // Re-create the User object from the modified JSON map
      UserData newUser = UserData.fromJson(json);

      // Log the updated user object and store it
      // Loggers.success(user.toJson());
      storage.write(SessionKeys.user, newUser);
    }
  }

  UserData? getUser() {
    var user = storage.read(SessionKeys.user);

    if (user == null || user is UserData?) {
      return user;
    } else if (user is Map<String, dynamic>) {
      return UserData.fromJson(user);
    } else {
      return null;
    }
  }

  int getUserID() {
    return (getUser()?.id ?? 0).toInt();
  }

  String getIdentity() {
    return getUser()?.identity ?? '';
  }

  String getCurrency() {
    return getSettings()?.currency ?? defaultCurrencyIcon;
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

  List<Categories> getCategories() {
    try {
      final String jsonString = getString(key: kDoctorCategory) ?? '';
      if (jsonString.isEmpty || jsonString == 'null') return [];
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Categories.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  Countries? getCountries() {
    return Countries.fromJson(jsonDecode(getString(key: kCountries) ?? ''));
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

  void updateFirebaseProfile(UserData? userData) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String patientId = CommonFun.setPatientId(patientId: userData?.id);
    db
        .collection(FirebaseRes.userChatList)
        .doc(patientId)
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
            .doc(patientId)
            .withConverter(
              fromFirestore: Conversation.fromFirestore,
              toFirestore: (Conversation value, options) {
                return value.toFirestore();
              },
            )
            .get()
            .then((value) {
          ChatUser? user = value.data()?.user;
          user?.username = userData?.fullname ?? S.current.unKnown;
          user?.image = userData?.profileImage;
          user?.userid = userData?.id;
          user?.gender = userData?.gender == 1 ? 'Male' : 'Female';
          user?.age = '${userData?.age}';

          db
              .collection(FirebaseRes.userChatList)
              .doc(element.id)
              .collection(FirebaseRes.userList)
              .doc(patientId)
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
    storage.remove(SessionKeys.authToken);
    storage.remove(SessionKeys.password);
    storage.remove(SessionKeys.notifyCount);
    storage.remove(SessionKeys.fallbackLang);
    storage.remove(SessionKeys.lang);
  }
}

class SessionKeys {
  static const isLogin = "login";
  static const shouldOpenEULA = "should_open_eula";
  static const fallbackLang = "fallback_lang";
  static const lang = "lang";
  static const setting = "setting";
  static const user = "user";
  static const authToken = "authToken";
  static const password = "password";
  static const notifyCount = "notify_count";
}
