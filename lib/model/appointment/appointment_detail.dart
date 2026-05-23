import 'package:patient_flutter/model/appointment/fetch_appointment.dart';

class Appointment {
  Appointment({
    bool? status,
    String? message,
    AppointmentData? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  Appointment.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data =
        json['data'] != null ? AppointmentData.fromJson(json['data']) : null;
  }

  bool? _status;
  String? _message;
  AppointmentData? _data;

  Appointment copyWith({
    bool? status,
    String? message,
    AppointmentData? data,
  }) =>
      Appointment(
        status: status ?? _status,
        message: message ?? _message,
        data: data ?? _data,
      );

  bool? get status => _status;

  String? get message => _message;

  AppointmentData? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }
}
