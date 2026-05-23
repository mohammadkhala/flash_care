class Coupon {
  Coupon({
    bool? status,
    String? message,
    List<CouponData>? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  Coupon.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(CouponData.fromJson(v));
      });
    }
  }
  bool? _status;
  String? _message;
  List<CouponData>? _data;
  Coupon copyWith({
    bool? status,
    String? message,
    List<CouponData>? data,
  }) =>
      Coupon(
        status: status ?? _status,
        message: message ?? _message,
        data: data ?? _data,
      );
  bool? get status => _status;
  String? get message => _message;
  List<CouponData>? get data => _data;

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

class CouponData {
  CouponData({
    int? id,
    String? coupon,
    int? percentage,
    int? maxDiscountAmount,
    String? heading,
    String? description,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _coupon = coupon;
    _percentage = percentage;
    _maxDiscountAmount = maxDiscountAmount;
    _heading = heading;
    _description = description;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  CouponData.fromJson(dynamic json) {
    _id = json['id'];
    _coupon = json['coupon'];
    _percentage = json['percentage'];
    _maxDiscountAmount = json['max_discount_amount'];
    _heading = json['heading'];
    _description = json['description'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }

  int? _id;
  String? _coupon;
  int? _percentage;
  int? _maxDiscountAmount;
  String? _heading;
  String? _description;
  String? _createdAt;
  String? _updatedAt;

  CouponData copyWith({
    int? id,
    String? coupon,
    int? percentage,
    int? maxDiscountAmount,
    String? heading,
    String? description,
    String? createdAt,
    String? updatedAt,
  }) =>
      CouponData(
        id: id ?? _id,
        coupon: coupon ?? _coupon,
        percentage: percentage ?? _percentage,
        maxDiscountAmount: maxDiscountAmount ?? _maxDiscountAmount,
        heading: heading ?? _heading,
        description: description ?? _description,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );
  int? get id => _id;

  String? get coupon => _coupon;

  int? get percentage => _percentage;

  int? get maxDiscountAmount => _maxDiscountAmount;
  String? get heading => _heading;
  String? get description => _description;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['coupon'] = _coupon;
    map['percentage'] = _percentage;
    map['max_discount_amount'] = _maxDiscountAmount;
    map['heading'] = _heading;
    map['description'] = _description;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}
