import 'package:doctor_flutter/model/reel/fetch_comment.dart';

class AddComment {
  AddComment({bool? status, String? message, Comment? data}) {
    _status = status;
    _message = message;
    _data = data;
  }

  AddComment.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data = json['data'] != null ? Comment.fromJson(json['data']) : null;
  }

  bool? _status;
  String? _message;
  Comment? _data;

  bool? get status => _status;

  String? get message => _message;

  Comment? get data => _data;

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
