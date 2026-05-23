import 'package:patient_flutter/model/appointment/fetch_appointment.dart';
import 'package:patient_flutter/model/user/registration.dart';

class FetchPrescription {
  FetchPrescription({
    bool? status,
    String? message,
    List<PrescriptionData>? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  FetchPrescription.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(PrescriptionData.fromJson(v));
      });
    }
  }

  bool? _status;
  String? _message;
  List<PrescriptionData>? _data;

  FetchPrescription copyWith({
    bool? status,
    String? message,
    List<PrescriptionData>? data,
  }) =>
      FetchPrescription(
        status: status ?? _status,
        message: message ?? _message,
        data: data ?? _data,
      );

  bool? get status => _status;

  String? get message => _message;

  List<PrescriptionData>? get data => _data;

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

class PrescriptionData {
  PrescriptionData({
    int? id,
    int? appointmentId,
    int? userId,
    String? medicine,
    String? createdAt,
    String? updatedAt,
    UserData? user,
    AppointmentData? appointment,
  }) {
    _id = id;
    _appointmentId = appointmentId;
    _userId = userId;
    _medicine = medicine;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _user = user;
    _appointment = appointment;
  }

  PrescriptionData.fromJson(dynamic json) {
    _id = json['id'];
    _appointmentId = json['appointment_id'];
    _userId = json['user_id'];
    _medicine = json['medicine'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _user = json['user'] != null ? UserData.fromJson(json['user']) : null;
    _appointment = json['appointment'] != null
        ? AppointmentData.fromJson(json['appointment'])
        : null;
  }

  int? _id;
  int? _appointmentId;
  int? _userId;
  String? _medicine;
  String? _createdAt;
  String? _updatedAt;
  UserData? _user;
  AppointmentData? _appointment;

  PrescriptionData copyWith({
    int? id,
    int? appointmentId,
    int? userId,
    String? medicine,
    String? createdAt,
    String? updatedAt,
    UserData? user,
    AppointmentData? appointment,
  }) =>
      PrescriptionData(
        id: id ?? _id,
        appointmentId: appointmentId ?? _appointmentId,
        userId: userId ?? _userId,
        medicine: medicine ?? _medicine,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        user: user ?? _user,
        appointment: appointment ?? _appointment,
      );

  int? get id => _id;

  int? get appointmentId => _appointmentId;

  int? get userId => _userId;

  String? get medicine => _medicine;

  String? get createdAt => _createdAt;

  String? get updatedAt => _updatedAt;

  UserData? get user => _user;

  AppointmentData? get appointment => _appointment;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['appointment_id'] = _appointmentId;
    map['user_id'] = _userId;
    map['medicine'] = _medicine;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    if (_appointment != null) {
      map['appointment'] = _appointment?.toJson();
    }
    return map;
  }
}
