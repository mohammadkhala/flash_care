import 'package:patient_flutter/model/user/registration.dart';

class DoctorReview {
  DoctorReview({
    bool? status,
    String? message,
    List<DoctorReviewData>? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  DoctorReview.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(DoctorReviewData.fromJson(v));
      });
    }
  }

  bool? _status;
  String? _message;
  List<DoctorReviewData>? _data;

  DoctorReview copyWith({
    bool? status,
    String? message,
    List<DoctorReviewData>? data,
  }) =>
      DoctorReview(
        status: status ?? _status,
        message: message ?? _message,
        data: data ?? _data,
      );

  bool? get status => _status;

  String? get message => _message;

  List<DoctorReviewData>? get data => _data;

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

class DoctorReviewData {
  DoctorReviewData({
    int? id,
    int? userId,
    int? doctorId,
    int? appointmentId,
    int? rating,
    String? comment,
    String? createdAt,
    String? updatedAt,
    UserData? user,
  }) {
    _id = id;
    _userId = userId;
    _doctorId = doctorId;
    _appointmentId = appointmentId;
    _rating = rating;
    _comment = comment;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _user = user;
  }

  DoctorReviewData.fromJson(dynamic json) {
    _id = json['id'];
    _userId = json['user_id'];
    _doctorId = json['doctor_id'];
    _appointmentId = json['appointment_id'];
    _rating = json['rating'];
    _comment = json['comment'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _user = json['user'] != null ? UserData.fromJson(json['user']) : null;
  }

  int? _id;
  int? _userId;
  int? _doctorId;
  int? _appointmentId;
  int? _rating;
  String? _comment;
  String? _createdAt;
  String? _updatedAt;
  UserData? _user;

  DoctorReviewData copyWith({
    int? id,
    int? userId,
    int? doctorId,
    int? appointmentId,
    int? rating,
    String? comment,
    String? createdAt,
    String? updatedAt,
    UserData? user,
  }) =>
      DoctorReviewData(
        id: id ?? _id,
        userId: userId ?? _userId,
        doctorId: doctorId ?? _doctorId,
        appointmentId: appointmentId ?? _appointmentId,
        rating: rating ?? _rating,
        comment: comment ?? _comment,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        user: user ?? _user,
      );

  int? get id => _id;

  int? get userId => _userId;

  int? get doctorId => _doctorId;

  int? get appointmentId => _appointmentId;

  int? get rating => _rating;

  String? get comment => _comment;

  String? get createdAt => _createdAt;

  String? get updatedAt => _updatedAt;

  UserData? get user => _user;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['user_id'] = _userId;
    map['doctor_id'] = _doctorId;
    map['appointment_id'] = _appointmentId;
    map['rating'] = _rating;
    map['comment'] = _comment;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    return map;
  }
}
