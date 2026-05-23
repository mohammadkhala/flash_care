// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentChat {
  String? _id;
  String? _image;
  String? _video;
  String? _audio;
  String? _file;
  String? _fileName;
  String? _msg;
  String? _msgType;
  VideoCall? _videoCall;
  AppointmentUser? _senderUser;

  AppointmentChat({
    String? id,
    String? image,
    String? video,
    String? audio,
    String? file,
    String? fileName,
    String? msg,
    String? msgType,
    VideoCall? videoCall,
    AppointmentUser? senderUser,
  }) {
    _id = id;
    _image = image;
    _video = video;
    _audio = audio;
    _file = file;
    _fileName = fileName;
    _msg = msg;
    _msgType = msgType;
    _videoCall = videoCall;
    _senderUser = senderUser;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": _id,
      "image": _image,
      "video": _video,
      "audio": _audio,
      "file": _file,
      "fileName": _fileName,
      "msg": _msg,
      "msgType": _msgType,
      "videoCall": _videoCall?.toJson(),
      "senderUser": _senderUser?.toJson(),
    };
  }

  AppointmentChat.fromJson(Map<String, dynamic>? json) {
    _id = json?["id"];
    _image = json?["image"];
    _video = json?["video"];
    _audio = json?["audio"];
    _file = json?["file"];
    _fileName = json?["fileName"];
    _msg = json?["msg"];
    _msgType = json?["msgType"];
    _videoCall = VideoCall.fromJson(json?["videoCall"]);
    _senderUser = AppointmentUser.fromJson(json?["senderUser"]);
  }

  factory AppointmentChat.fromFireStore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return AppointmentChat(
      image: data?['image'],
      video: data?['video'],
      audio: data?['audio'],
      file: data?['file'],
      fileName: data?['fileName'],
      id: data?['id'],
      msg: data?['msg'],
      msgType: data?['msgType'],
      videoCall: VideoCall.fromJson(data?['videoCall']),
      senderUser: AppointmentUser.fromJson(data?["senderUser"]),
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      if (id != null) "id": _id,
      if (image != null) "image": _image,
      if (video != null) "video": _video,
      if (audio != null) "audio": _audio,
      if (file != null) "file": _file,
      if (fileName != null) "fileName": _fileName,
      if (msg != null) "msg": _msg,
      if (msgType != null) "msgType": _msgType,
      if (videoCall != null) "videoCall": _videoCall,
      if (senderUser != null) "senderUser": _senderUser,
    };
  }

  AppointmentUser? get senderUser => _senderUser;

  String? get msgType => _msgType;

  String? get msg => _msg;

  String? get video => _video;

  String? get audio => _audio;

  String? get file => _file;

  String? get fileName => _fileName;

  String? get image => _image;

  VideoCall? get videoCall => _videoCall;

  String? get id => _id;
}

class VideoCall {
  String? _time;
  bool? _isStarted;
  String? _patientName;
  int? _patientAge;
  String? _patientImage;
  String? _channelId;
  String? _token;

  VideoCall(
      {String? time,
      bool? isStarted,
      String? patientName,
      int? patientAge,
      String? patientImage,
      String? channelId,
      String? token}) {
    if (time != null) {
      _time = time;
    }
    if (isStarted != null) {
      _isStarted = isStarted;
    }
    if (patientName != null) {
      _patientName = patientName;
    }
    if (patientAge != null) {
      _patientAge = patientAge;
    }
    if (patientImage != null) {
      _patientImage = patientImage;
    }
    if (channelId != null) {
      _channelId = channelId;
    }
    if (token != null) {
      _token = token;
    }
  }

  String? get time => _time;

  set time(String? time) => _time = time;

  bool? get isStarted => _isStarted;

  set isStarted(bool? isStarted) => _isStarted = isStarted;

  String? get patientName => _patientName;

  set patientName(String? patientName) => _patientName = patientName;

  int? get patientAge => _patientAge;

  set patientAge(int? patientAge) => _patientAge = patientAge;

  String? get patientImage => _patientImage;

  set patientImage(String? patientImage) => _patientImage = patientImage;

  String? get channelId => _channelId;

  set channelId(String? channelId) => _channelId = channelId;

  String? get token => _token;

  set token(String? token) => _token = token;

  VideoCall.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    _time = json['time'];
    _isStarted = json['isStarted'];
    _patientName = json['patientName'];
    _patientAge = json['patientAge'];
    _patientImage = json['patientImage'];
    _channelId = json['channelId'];
    _token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['time'] = _time;
    data['isStarted'] = _isStarted;
    data['patientName'] = _patientName;
    data['patientAge'] = _patientAge;
    data['patientImage'] = _patientImage;
    data['channelId'] = _channelId;
    data['token'] = _token;
    return data;
  }
}

class AppointmentUser {
  int? _userId;
  String? _name;
  String? _dob;
  String? _image;
  String? _identity;

  AppointmentUser({
    int? userId,
    String? name,
    int? age,
    String? dob,
    String? image,
    String? identity,
  }) {
    _userId = userId;
    _name = name;
    _dob = dob;
    _image = image;
    _identity = identity;
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': _userId,
      'name': _name,
      'dob': _dob,
      'image': _image,
      'identity': _identity,
    };
  }

  AppointmentUser.fromJson(Map<String, dynamic>? json) {
    // Use (as num?)?.toInt() to safely handle int/double/num from Firestore Web
    _userId = (json?['userId'] as num?)?.toInt();
    _name = json?['name'];
    _dob = json?['dob'];
    _image = json?['image'];
    _identity = json?['identity'];
  }

  String? get identity => _identity;

  String? get image => _image;

  String? get dob => _dob;

  String? get name => _name;

  int? get userId => _userId;
}
