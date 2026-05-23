import 'package:patient_flutter/model/appointment/fetch_appointment.dart';

class FetchPatient {
  FetchPatient({
    bool? status,
    String? message,
    List<Patient>? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  FetchPatient.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Patient.fromJson(v));
      });
    }
  }

  bool? _status;
  String? _message;
  List<Patient>? _data;

  FetchPatient copyWith({
    bool? status,
    String? message,
    List<Patient>? data,
  }) =>
      FetchPatient(
        status: status ?? _status,
        message: message ?? _message,
        data: data ?? _data,
      );

  bool? get status => _status;

  String? get message => _message;

  List<Patient>? get data => _data;

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
