// ignore_for_file: unnecessary_getters_setters

import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  String? _conversationId;
  String? _deletedId;
  bool? _isDeleted;
  String? _lastMsg;
  String? _time;
  int? _deviceToken;
  int? _inTheChat;
  ChatUser? _user;

  Conversation({
    String? conversationId,
    String? deletedId,
    bool? isDeleted,
    String? lastMsg,
    String? time,
    int? deviceToken,
    int? inTheChat,
    ChatUser? user,
  }) {
    _conversationId = conversationId;
    _deletedId = deletedId;
    _isDeleted = isDeleted;
    _lastMsg = lastMsg;
    _time = time;
    _deviceToken = deviceToken;
    _inTheChat = inTheChat;
    _user = user;
  }

  factory Conversation.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Conversation(
      conversationId: data?['conversationId'],
      deletedId: data?['deletedId'],
      isDeleted: data?['isDeleted'],
      lastMsg: data?['lastMsg'],
      time: data?['time'],
      deviceToken: data?['deviceToken'],
      inTheChat: data?['inTheChat'],
      user: data?['user'] != null ? ChatUser.fromJson(data?['user']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (conversationId != null) "conversationId": _conversationId,
      if (deletedId != null) "deletedId": _deletedId,
      if (isDeleted != null) "isDeleted": _isDeleted,
      if (lastMsg != null) "lastMsg": _lastMsg,
      if (time != null) "time": _time,
      if (user != null) "user": _user,
      if (deviceToken != null) "deviceToken": _deviceToken,
      if (inTheChat != null) "inTheChat": _inTheChat,
    };
  }

  Conversation.fromJson(Map<String, dynamic> json) {
    _conversationId = json["conversationId"];
    _deletedId = json["deletedId"];
    _isDeleted = json["isDeleted"];
    _lastMsg = json["lastMsg"];
    _time = json["time"];
    _deviceToken = json["deviceToken"];
    _inTheChat = json["inTheChat"];
    _user = json["user"] != null ? ChatUser.fromJson(json["user"]) : null;
  }

  Map<String, Object?> toJson() {
    return {
      "conversationId": _conversationId,
      "deletedId": _deletedId,
      "isDeleted": _isDeleted,
      "lastMsg": _lastMsg,
      "time": _time,
      "deviceToken": _deviceToken,
      "inTheChat": _inTheChat,
      "user": _user?.toJson(),
    };
  }

  ChatUser? get user => _user;

  String? get time => _time;

  String? get lastMsg => _lastMsg;

  bool? get isDeleted => _isDeleted;

  String? get deletedId => _deletedId;

  String? get conversationId => _conversationId;

  int? get deviceToken => _deviceToken;

  int? get inTheChat => _inTheChat;

  void setConversationId(String? value) {
    _conversationId = value;
  }
}

class ChatUser {
  int? _userid;
  String? _userIdentity;
  String? _userMail;
  String? _username;
  String? _image;
  String? _age;
  String? _gender;
  String? _designation;
  int? _msgCount;
  int? _deviceToken;
  int? _inTheChat;

  ChatUser({
    int? userid,
    String? userIdentity,
    String? userMail,
    String? username,
    String? image,
    String? age,
    String? gender,
    String? designation,
    int? msgCount,
    int? deviceToken,
    int? inTheChat,
  }) {
    _userid = userid;
    _userIdentity = userIdentity;
    _userMail = userMail;
    _username = username;
    _image = image;
    _age = age;
    _gender = gender;
    _designation = designation;
    _msgCount = msgCount;
    _deviceToken = deviceToken;
    _inTheChat = inTheChat;
  }

  Map<String, dynamic> toJson() {
    return {
      "userid": _userid,
      "userIdentity": _userIdentity,
      "userMail": _userMail,
      "username": _username,
      "image": _image,
      "age": _age,
      "gender": _gender,
      "designation": _designation,
      "msgCount": _msgCount,
      "deviceToken": _deviceToken,
      "inTheChat": _inTheChat,
    };
  }

  ChatUser.fromJson(Map<String, dynamic> json) {
    _userid = json['userid'];
    _userIdentity = json['userIdentity'];
    _userMail = json['userMail'];
    _username = json['username'];
    _image = json['image'];
    _age = json['age'];
    _gender = json['gender'];
    _designation = json['designation'];
    _msgCount = json['msgCount'];
    _deviceToken = json['deviceToken'];
    _inTheChat = json['inTheChat'];
  }

  int? get msgCount => _msgCount;

  set msgCount(int? value) {
    _msgCount = value;
  }

  String? get designation => _designation;

  String? get age => _age;

  String? get image => _image;

  String? get username => _username;

  String? get userIdentity => _userIdentity;

  String? get userMail => _userMail;

  int? get userid => _userid;

  int? get deviceToken => _deviceToken;

  int? get inTheChat => _inTheChat;

  String? get gender => _gender;

  set designation(String? value) {
    _designation = value;
  }

  set userid(int? value) {
    _userid = value;
  }

  set image(String? value) {
    _image = value;
  }

  set username(String? value) {
    _username = value;
  }
}

class ChatMessage {
  String? _id;
  String? _msgType;
  String? _image;
  String? _video;
  String? _msg;
  ChatUser? _senderUser;
  List<String>? _notDeletedIdentities;

  ChatMessage(
      {String? id,
      String? image,
      String? video,
      String? msg,
      String? msgType,
      ChatUser? senderUser,
      List<String>? notDeletedIdentities}) {
    _id = id;
    _image = image;
    _video = video;
    _msg = msg;
    _msgType = msgType;
    _senderUser = senderUser;
    _notDeletedIdentities = notDeletedIdentities;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": _id,
      "image": _image,
      "video": _video,
      "msg": _msg,
      "msgType": _msgType,
      "senderUser": _senderUser?.toJson(),
      "not_deleted_identities": _notDeletedIdentities?.map((v) => v).toList()
    };
  }

  ChatMessage.fromJson(Map<String, dynamic>? json) {
    _id = json?["id"];
    _image = json?["image"];
    _video = json?["video"];
    _msg = json?["msg"];
    _msgType = json?["msgType"];
    _senderUser = json?["senderUser"] != null ? ChatUser.fromJson(json!["senderUser"]) : null;
    if (json?['not_deleted_identities'] != null) {
      _notDeletedIdentities = [];
      json?['not_deleted_identities'].forEach((v) {
        _notDeletedIdentities?.add(v);
      });
    }
  }

  factory ChatMessage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    List<String> notDeletedIdentities = [];
    data?['not_deleted_identities']?.forEach((v) {
      notDeletedIdentities.add(v);
    });
    return ChatMessage(
      image: data?['image'],
      video: data?['video'],
      id: data?['id'],
      msg: data?['msg'],
      msgType: data?['msgType'],
      notDeletedIdentities: notDeletedIdentities,
      senderUser: data?["senderUser"] != null
          ? ChatUser.fromJson(data!["senderUser"])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) "id": _id,
      if (image != null) "image": _image,
      if (video != null) "video": _video,
      if (msg != null) "msg": _msg,
      if (msgType != null) "msgType": _msgType,
      if (senderUser != null) "senderUser": _senderUser,
      if (notDeletedIdentities != null) "not_deleted_identities": _notDeletedIdentities?.map((v) => v).toList()
    };
  }

  String? get video => _video;

  List<String>? get notDeletedIdentities => _notDeletedIdentities;

  ChatUser? get senderUser => _senderUser;

  String? get msgType => _msgType;

  String? get msg => _msg;

  String? get image => _image;

  String? get id => _id;
}
