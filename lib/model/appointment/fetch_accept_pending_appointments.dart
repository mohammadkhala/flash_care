class FetchAcceptPendingAppointments {
  FetchAcceptPendingAppointments({
    bool? status,
    String? message,
    List<FetchAcceptPendingAppointmentData>? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  FetchAcceptPendingAppointments.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(FetchAcceptPendingAppointmentData.fromJson(v));
      });
    }
  }

  bool? _status;
  String? _message;
  List<FetchAcceptPendingAppointmentData>? _data;

  bool? get status => _status;

  String? get message => _message;

  List<FetchAcceptPendingAppointmentData>? get data => _data;

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

class FetchAcceptPendingAppointmentData {
  FetchAcceptPendingAppointmentData({
    int? id,
    String? appointmentNumber,
    int? status,
    int? doctorId,
    int? userId,
    int? patientId,
    String? problem,
    String? diagnosedWith,
    String? document,
    String? date,
    String? time,
    int? type,
    String? orderSummary,
    int? isCouponApplied,
    String? couponTitle,
    int? completionOtp,
    int? serviceAmount,
    int? discountAmount,
    int? subtotal,
    num? totalTaxAmount,
    int? payableAmount,
    int? isRated,
    String? createdAt,
    String? updatedAt,
    User? user,
  }) {
    _id = id;
    _appointmentNumber = appointmentNumber;
    _status = status;
    _doctorId = doctorId;
    _userId = userId;
    _patientId = patientId;
    _problem = problem;
    _diagnosedWith = diagnosedWith;
    _document = document;
    _date = date;
    _time = time;
    _type = type;
    _orderSummary = orderSummary;
    _isCouponApplied = isCouponApplied;
    _couponTitle = couponTitle;
    _completionOtp = completionOtp;
    _serviceAmount = serviceAmount;
    _discountAmount = discountAmount;
    _subtotal = subtotal;
    _totalTaxAmount = totalTaxAmount;
    _payableAmount = payableAmount;
    _isRated = isRated;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _user = user;
  }

  FetchAcceptPendingAppointmentData.fromJson(dynamic json) {
    _id = json['id'];
    _appointmentNumber = json['appointment_number'];
    _status = json['status'];
    _doctorId = json['doctor_id'];
    _userId = json['user_id'];
    _patientId = json['patient_id'];
    _problem = json['problem'];
    _diagnosedWith = json['diagnosed_with'];
    _document = json['document'];
    _date = json['date'];
    _time = json['time'];
    _type = json['type'];
    _orderSummary = json['order_summary'];
    _isCouponApplied = json['is_coupon_applied'];
    _couponTitle = json['coupon_title'];
    _completionOtp = json['completion_otp'];
    _serviceAmount = json['service_amount'];
    _discountAmount = json['discount_amount'];
    _subtotal = json['subtotal'];
    _totalTaxAmount = json['total_tax_amount'];
    _payableAmount = json['payable_amount'];
    _isRated = json['is_rated'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  int? _id;
  String? _appointmentNumber;
  int? _status;
  int? _doctorId;
  int? _userId;
  int? _patientId;
  String? _problem;
  String? _diagnosedWith;
  String? _document;
  String? _date;
  String? _time;
  int? _type;
  String? _orderSummary;
  int? _isCouponApplied;
  String? _couponTitle;
  int? _completionOtp;
  int? _serviceAmount;
  int? _discountAmount;
  int? _subtotal;
  num? _totalTaxAmount;
  num? _payableAmount;
  int? _isRated;
  String? _createdAt;
  String? _updatedAt;
  User? _user;

  int? get id => _id;

  String? get appointmentNumber => _appointmentNumber;

  int? get status => _status;

  int? get doctorId => _doctorId;

  int? get userId => _userId;

  int? get patientId => _patientId;

  String? get problem => _problem;

  String? get diagnosedWith => _diagnosedWith;

  String? get document => _document;

  String? get date => _date;

  String? get time => _time;

  int? get type => _type;

  String? get orderSummary => _orderSummary;

  int? get isCouponApplied => _isCouponApplied;

  String? get couponTitle => _couponTitle;

  int? get completionOtp => _completionOtp;

  int? get serviceAmount => _serviceAmount;

  int? get discountAmount => _discountAmount;

  int? get subtotal => _subtotal;

  num? get totalTaxAmount => _totalTaxAmount;

  num? get payableAmount => _payableAmount;

  int? get isRated => _isRated;

  String? get createdAt => _createdAt;

  String? get updatedAt => _updatedAt;

  User? get user => _user;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['appointment_number'] = _appointmentNumber;
    map['status'] = _status;
    map['doctor_id'] = _doctorId;
    map['user_id'] = _userId;
    map['patient_id'] = _patientId;
    map['problem'] = _problem;
    map['diagnosed_with'] = _diagnosedWith;
    map['document'] = _document;
    map['date'] = _date;
    map['time'] = _time;
    map['type'] = _type;
    map['order_summary'] = _orderSummary;
    map['is_coupon_applied'] = _isCouponApplied;
    map['coupon_title'] = _couponTitle;
    map['completion_otp'] = _completionOtp;
    map['service_amount'] = _serviceAmount;
    map['discount_amount'] = _discountAmount;
    map['subtotal'] = _subtotal;
    map['total_tax_amount'] = _totalTaxAmount;
    map['payable_amount'] = _payableAmount;
    map['is_rated'] = _isRated;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    return map;
  }
}

class User {
  User({
    int? id,
    int? isBlock,
    String? identity,
    String? countryCode,
    String? dob,
    int? gender,
    String? fullname,
    String? email,
    String? phoneNumber,
    String? profileImage,
    int? isNotification,
    int? deviceType,
    String? deviceToken,
    int? loginType,
    int? wallet,
    String? favouriteDoctors,
    String? couponsUsed,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _isBlock = isBlock;
    _identity = identity;
    _countryCode = countryCode;
    _dob = dob;
    _gender = gender;
    _fullname = fullname;
    _email = email;
    _phoneNumber = phoneNumber;
    _profileImage = profileImage;
    _isNotification = isNotification;
    _deviceType = deviceType;
    _deviceToken = deviceToken;
    _loginType = loginType;
    _wallet = wallet;
    _favouriteDoctors = favouriteDoctors;
    _couponsUsed = couponsUsed;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  User.fromJson(dynamic json) {
    _id = json['id'];
    _isBlock = json['is_block'];
    _identity = json['identity'];
    _countryCode = json['country_code'];
    _dob = json['dob'];
    _gender = json['gender'];
    _fullname = json['fullname'];
    _email = json['email'];
    _phoneNumber = json['phone_number'];
    _profileImage = json['profile_image'];
    _isNotification = json['is_notification'];
    _deviceType = json['device_type'];
    _deviceToken = json['device_token'];
    _loginType = json['login_type'];
    _wallet = json['wallet'];
    _favouriteDoctors = json['favourite_doctors'];
    _couponsUsed = json['coupons_used'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }

  int? _id;
  int? _isBlock;
  String? _identity;
  String? _countryCode;
  String? _dob;
  int? _gender;
  String? _fullname;
  String? _email;
  String? _phoneNumber;
  String? _profileImage;
  int? _isNotification;
  int? _deviceType;
  String? _deviceToken;
  int? _loginType;
  num? _wallet;
  String? _favouriteDoctors;
  String? _couponsUsed;
  String? _createdAt;
  String? _updatedAt;

  int? get id => _id;

  int? get isBlock => _isBlock;

  String? get identity => _identity;

  String? get countryCode => _countryCode;

  String? get dob => _dob;

  int? get gender => _gender;

  String? get fullname => _fullname;

  String? get email => _email;

  String? get phoneNumber => _phoneNumber;

  String? get profileImage => _profileImage;

  int? get isNotification => _isNotification;

  int? get deviceType => _deviceType;

  String? get deviceToken => _deviceToken;

  int? get loginType => _loginType;

  num? get wallet => _wallet;

  String? get favouriteDoctors => _favouriteDoctors;

  String? get couponsUsed => _couponsUsed;

  String? get createdAt => _createdAt;

  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['is_block'] = _isBlock;
    map['identity'] = _identity;
    map['country_code'] = _countryCode;
    map['dob'] = _dob;
    map['gender'] = _gender;
    map['fullname'] = _fullname;
    map['email'] = _email;
    map['phone_number'] = _phoneNumber;
    map['profile_image'] = _profileImage;
    map['is_notification'] = _isNotification;
    map['device_type'] = _deviceType;
    map['device_token'] = _deviceToken;
    map['login_type'] = _loginType;
    map['wallet'] = _wallet;
    map['favourite_doctors'] = _favouriteDoctors;
    map['coupons_used'] = _couponsUsed;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}
