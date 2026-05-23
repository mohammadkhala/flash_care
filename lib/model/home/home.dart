import 'package:patient_flutter/model/appointment/fetch_appointment.dart';
import 'package:patient_flutter/model/doctor/fetch_doctor.dart';

class Home {
  Home({
    bool? status,
    String? message,
    List<Categories>? categories,
    List<AppointmentData>? appointments,
  }) {
    _status = status;
    _message = message;
    _categories = categories;
    _appointments = appointments;
  }

  Home.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['categories'] != null) {
      _categories = [];
      json['categories'].forEach((v) {
        _categories?.add(Categories.fromJson(v));
      });
    }
    if (json['appointments'] != null) {
      _appointments = [];
      json['appointments'].forEach((v) {
        _appointments?.add(AppointmentData.fromJson(v));
      });
    }
  }

  bool? _status;
  String? _message;
  List<Categories>? _categories;
  List<AppointmentData>? _appointments;

  Home copyWith({
    bool? status,
    String? message,
    List<Categories>? categories,
    List<AppointmentData>? appointments,
  }) =>
      Home(
        status: status ?? _status,
        message: message ?? _message,
        categories: categories ?? _categories,
        appointments: appointments ?? _appointments,
      );

  bool? get status => _status;

  String? get message => _message;

  List<Categories>? get categories => _categories;

  List<AppointmentData>? get appointments => _appointments;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_categories != null) {
      map['categories'] = _categories?.map((v) => v.toJson()).toList();
    }
    if (_appointments != null) {
      map['appointments'] = _appointments?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Categories {
  Categories({
    int? id,
    String? title,
    String? image,
    int? isDeleted,
    String? createdAt,
    String? updatedAt,
    List<DoctorData>? doctors,
  }) {
    _id = id;
    _title = title;
    _image = image;
    _isDeleted = isDeleted;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _doctors = doctors;
  }

  Categories.fromJson(dynamic json) {
    _id = json['id'];
    _title = json['title'];
    _image = json['image'];
    _isDeleted = json['is_deleted'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    if (json['doctors'] != null) {
      _doctors = [];
      json['doctors'].forEach((v) {
        _doctors?.add(DoctorData.fromJson(v));
      });
    }
  }

  int? _id;
  String? _title;
  String? _image;
  int? _isDeleted;
  String? _createdAt;
  String? _updatedAt;
  List<DoctorData>? _doctors;

  Categories copyWith({
    int? id,
    String? title,
    String? image,
    int? isDeleted,
    String? createdAt,
    String? updatedAt,
    List<DoctorData>? doctors,
  }) =>
      Categories(
        id: id ?? _id,
        title: title ?? _title,
        image: image ?? _image,
        isDeleted: isDeleted ?? _isDeleted,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        doctors: doctors ?? _doctors,
      );

  int? get id => _id;

  String? get title => _title;

  String? get image => _image;

  int? get isDeleted => _isDeleted;

  String? get createdAt => _createdAt;

  String? get updatedAt => _updatedAt;

  List<DoctorData>? get doctors => _doctors;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['title'] = _title;
    map['image'] = _image;
    map['is_deleted'] = _isDeleted;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    if (_doctors != null) {
      map['doctors'] = _doctors?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
