import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/model/user/fetch_user_detail.dart';

class FetchComment {
  FetchComment({
    bool? status,
    String? message,
    List<Comment>? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  FetchComment.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Comment.fromJson(v));
      });
    }
  }

  bool? _status;
  String? _message;
  List<Comment>? _data;

  bool? get status => _status;

  String? get message => _message;

  List<Comment>? get data => _data;

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

class Comment {
  Comment({
    num? id,
    num? reelId,
    int? userId,
    num? doctorId,
    num? commentBy,
    String? comment,
    String? createdAt,
    String? updatedAt,
    User? user,
    DoctorData? doctor,
  }) {
    _id = id;
    _reelId = reelId;
    _userId = userId;
    _doctorId = doctorId;
    _commentBy = commentBy;
    _comment = comment;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _user = user;
    _doctor = doctor;
  }

  Comment.fromJson(dynamic json) {
    _id = json['id'];
    _reelId = json['reel_id'];
    _userId = json['user_id'];
    _doctorId = json['doctor_id'];
    _commentBy = json['comment_by'];
    _comment = json['comment'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];

    _user = json['user'] != null ? User.fromJson(json['user']) : null;
    _doctor =
        json['doctor'] != null ? DoctorData.fromJson(json['doctor']) : null;
  }

  num? _id;
  num? _reelId;
  int? _userId;
  num? _doctorId;
  num? _commentBy;
  String? _comment;
  String? _createdAt;
  String? _updatedAt;
  User? _user;
  DoctorData? _doctor;

  num? get id => _id;

  num? get reelId => _reelId;

  int? get userId => _userId;

  num? get doctorId => _doctorId;

  num? get commentBy => _commentBy;

  String? get comment => _comment;

  String? get createdAt => _createdAt;

  String? get updatedAt => _updatedAt;

  User? get user => _user;

  DoctorData? get doctor => _doctor;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['reel_id'] = _reelId;
    map['user_id'] = _userId;
    map['doctor_id'] = _doctorId;
    map['comment_by'] = _commentBy;
    map['comment'] = _comment;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    if (_doctor != null) {
      map['doctor'] = _doctor?.toJson();
    }
    return map;
  }
}
