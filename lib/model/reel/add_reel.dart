import 'package:doctor_flutter/model/reel/reels.dart';

class AddReel {
  AddReel({
    bool? status,
    String? message,
    Reel? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  AddReel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data = json['data'] != null ? Reel.fromJson(json['data']) : null;
  }

  bool? _status;
  String? _message;
  Reel? _data;

  bool? get status => _status;

  String? get message => _message;

  Reel? get data => _data;

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
