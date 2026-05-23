// ignore_for_file: unnecessary_getters_setters

import 'package:patient_flutter/model/doctor/fetch_doctor.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/services/session_manager.dart';

class Reels {
  Reels({
    bool? status,
    String? message,
    List<Reel>? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  Reels.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Reel.fromJson(v));
      });
    }
  }

  bool? _status;
  String? _message;
  List<Reel>? _data;

  bool? get status => _status;

  String? get message => _message;

  List<Reel>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Reel {
  Reel(
      {int? id,
      num? doctorId,
      String? video,
      String? thumb,
      String? description,
      int? views,
      String? createdAt,
      String? updatedAt,
      int? commentsCount,
      int? likesCount,
      bool? isLiked,
      DoctorData? doctor}) {
    _id = id;
    _doctorId = doctorId;
    _video = video;
    _thumb = thumb;
    _description = description;
    _views = views;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _commentsCount = commentsCount;
    _likesCount = likesCount;
    _isLiked = isLiked;
    _doctor = doctor;
  }

  Reel.fromJson(dynamic json) {
    _id = json['id'];
    _doctorId = json['doctor_id'];
    _video = json['video'];
    _thumb = json['thumb'];
    _description = json['description'];
    _views = json['views'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _commentsCount = json['comments_count'];
    _likesCount = json['likes_count'];
    _isLiked = json['is_liked'];
    _doctor =
        json['doctor'] != null ? DoctorData.fromJson(json['doctor']) : null;
  }

  int? _id;
  num? _doctorId;
  String? _video;
  String? _thumb;
  String? _description;
  int? _views;
  String? _createdAt;
  String? _updatedAt;
  int? _commentsCount;
  int? _likesCount;
  bool? _isLiked;
  DoctorData? _doctor;

  int? get id => _id;

  num? get doctorId => _doctorId;

  String? get video => _video;

  String? get thumb => _thumb;

  String? get description => _description;

  int? get views => _views;

  set views(int? value) {
    _views = value;
  }

  String? get createdAt => _createdAt;

  String? get updatedAt => _updatedAt;

  int? get commentsCount => _commentsCount;

  set commentsCount(int? value) {
    _commentsCount = value;
  }

  int? get likesCount => _likesCount;

  set likesCount(int? value) {
    _likesCount = value;
  }

  bool? get isLiked => _isLiked;

  set isLiked(bool? value) {
    _isLiked = value;
  }

  DoctorData? get doctor => _doctor;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['doctor_id'] = _doctorId;
    map['video'] = _video;
    map['thumb'] = _thumb;
    map['description'] = _description;
    map['views'] = _views;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    map['comments_count'] = _commentsCount;
    map['likes_count'] = _likesCount;
    map['is_liked'] = _isLiked;
    if (_doctor != null) {
      map['doctor'] = _doctor?.toJson();
    }
    return map;
  }

  void increaseCommentCount(int count) {
    _commentsCount = (commentsCount ?? 0) + count;
  }

  bool get isSaved {
    return (SessionManager.instance
            .getUser()
            ?.savedReels
            ?.split(',')
            .contains('$id') ??
        false);
  }

  set isSaved(bool value) {
    UserData? user = SessionManager.instance.getUser();
    if (user == null) return;

    final savedList =
        user.savedReels?.split(',').where((e) => e.isNotEmpty).toList() ?? [];

    if (value) {
      // Add if not already saved
      if (!savedList.contains('$id')) {
        savedList.add('$id');
      }
    } else {
      // Remove if present
      savedList.remove('$id');
    }

    user.savedReels = savedList.join(',');
    SessionManager.instance.setUser(user);
  }

  void increaseViews() {
    views = (views ?? 0) + 1;
  }
}
