import 'package:patient_flutter/model/doctor/fetch_doctor.dart';

class SearchDoctor {
  SearchDoctor({
    bool? status,
    String? message,
    List<DoctorData>? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  SearchDoctor.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(DoctorData.fromJson(v));
      });
    }
  }

  bool? _status;
  String? _message;
  List<DoctorData>? _data;

  SearchDoctor copyWith({
    bool? status,
    String? message,
    List<DoctorData>? data,
  }) =>
      SearchDoctor(
        status: status ?? _status,
        message: message ?? _message,
        data: data ?? _data,
      );

  bool? get status => _status;

  String? get message => _message;

  List<DoctorData>? get data => _data;

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
