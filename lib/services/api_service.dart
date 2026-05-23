import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:patient_flutter/model/ai_bot/ai_bot.dart';
import 'package:patient_flutter/model/appointment/add_appointment.dart';
import 'package:patient_flutter/model/appointment/appointment_detail.dart';
import 'package:patient_flutter/model/appointment/coupon.dart';
import 'package:patient_flutter/model/appointment/fetch_accept_pending_appointments.dart';
import 'package:patient_flutter/model/appointment/fetch_appointment.dart';
import 'package:patient_flutter/model/appointment/prescription.dart';
import 'package:patient_flutter/model/custom/order_summary.dart';
import 'package:patient_flutter/model/doctor/doctor_review.dart';
import 'package:patient_flutter/model/doctor/fetch_doctor.dart';
import 'package:patient_flutter/model/doctor/search_doctor.dart';
import 'package:patient_flutter/model/global/agora_token.dart';
import 'package:patient_flutter/model/global/fetch_faqs.dart';
import 'package:patient_flutter/model/global/get_path.dart';
import 'package:patient_flutter/model/global/global_setting.dart';
import 'package:patient_flutter/model/home/fav_doctor.dart';
import 'package:patient_flutter/model/home/home.dart';
import 'package:patient_flutter/model/message/message.dart';
import 'package:patient_flutter/model/notification/notification.dart'
    as notification;
import 'package:patient_flutter/model/user/patient.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/model/wallet/wallet_statement.dart';
import 'package:patient_flutter/model/wallet/withdraw_request.dart';
import 'package:patient_flutter/services/session_manager.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/update_res.dart';
import 'package:patient_flutter/utils/urls.dart';

class ApiService {
  static ApiService get instance {
    return ApiService();
  }

  Future<Registration> registration(
      {String? name,
      String? identity,
      String? deviceToken,
      int? deviceType,
      int? loginType,
      int? isLogin}) async {
    Map<String, dynamic> map = {};
    if (name != null) {
      map[pFullName] = name;
    }
    map[pIdentity] = identity;
    map[pDeviceToken] = deviceToken;
    if (loginType != null) {
      map[pLoginType] = loginType.toString();
    }

    if (deviceType != null) {
      map[pDeviceType] = deviceType.toString();
    }
    if (isLogin != null) {
      map[pIsLogin] = isLogin.toString();
    }

    http.Response response = await http.post(
      Uri.parse(Urls.registration),
      headers: {pApikeyName: ConstRes.apiKey},
      body: map,
    );
    return Registration.fromJson(jsonDecode(response.body));
  }

  Future<Registration> updateUserDetails(
      {String? name,
      String? countryCode,
      int? gender,
      File? image,
      String? dob,
      String? favouriteDoctors,
      int? isNotification,
      String? phoneNumber,
      String? savedReels}) async {
    var request = http.MultipartRequest(
      pPost,
      Uri.parse(Urls.updateUserDetails),
    );

    request.headers.addAll({
      pApikeyName: ConstRes.apiKey,
    });
    request.fields[pIdentity] = SessionManager.instance.getIdentity();
    if (name != null) {
      request.fields[pFullName] = name;
    }
    if (countryCode != null) {
      request.fields[pCountryCode] = countryCode;
    }
    if (gender != null) {
      request.fields[pGender] = '$gender';
    }
    if (savedReels != null) {
      request.fields[pSavedReels] = savedReels;
    }
    if (dob != null) {
      request.fields[pDob] = dob;
    }
    if (favouriteDoctors != null) {
      request.fields[pFavouriteDoctors] = favouriteDoctors;
    }
    if (isNotification != null) {
      request.fields[pIsNotification] = isNotification.toString();
    }

    if (phoneNumber != null) {
      request.fields[pPhoneNumber] = phoneNumber.toString();
    }

    if (image != null) {
      request.files.add(http.MultipartFile(
          pProfileImage, image.readAsBytes().asStream(), image.lengthSync(),
          filename: image.path.split("/").last));
    }

    var response = await request.send();
    var respStr = await response.stream.bytesToString();
    final responseJson = jsonDecode(respStr);
    print(responseJson);
    Registration updateProfile = Registration.fromJson(responseJson);
    print(updateProfile.message);
    SessionManager.instance.setUser(updateProfile.data);
    SessionManager.instance.updateFirebaseProfile(updateProfile.data);
    return updateProfile;
  }

  Future<notification.Notification> fetchNotification({int start = 0}) async {
    http.Response response = await http.post(
      Uri.parse(Urls.fetchNotification),
      headers: {pApikeyName: ConstRes.apiKey},
      body: {
        pStart: start.toString(),
        pCount: '$paginationLimit',
      },
    );
    return notification.Notification.fromJson(jsonDecode(response.body));
  }

  Future<Home> fetchHomePageData({String? date}) async {
    Map<String, dynamic> map = {};
    map[pUserId] = SessionManager.instance.getUserID().toString();
    if (date != null) {
      map[pDate] = date;
    }
    http.Response response = await http.post(Uri.parse(Urls.fetchHomePageData),
        headers: {pApikeyName: ConstRes.apiKey}, body: map);
    return Home.fromJson(
      jsonDecode(response.body),
    );
  }

  Future<SearchDoctor> searchDoctor({
    int? gender,
    String keyword = '',
    int? categoryId,
    int start = 0,
    int? sortType,
    int searchType = 0,
  }) async {
    Map<String, dynamic> map = {};
    map[pStart] = start.toString();
    map[pCount] = '$paginationLimit';
    if (keyword.isNotEmpty) {
      map[pKeyword] = keyword;
    }
    if (gender != null) {
      map[pGender] = gender.toString();
    }
    if (categoryId != null) {
      map[pCategoryId] = categoryId.toString();
    }
    if (sortType != null) {
      map[pSortType] = sortType.toString();
    }
    if (searchType > 0) {
      map['search_type'] = searchType.toString();
    }

    http.Response? response = await http.post(Uri.parse(Urls.searchDoctor),
        headers: {pApikeyName: ConstRes.apiKey}, body: map);
    return SearchDoctor.fromJson(jsonDecode(response.body));
  }

  Future<FetchPatient> fetchPatient() async {
    http.Response response = await http.post(
      Uri.parse(Urls.fetchPatients),
      headers: {pApikeyName: ConstRes.apiKey},
      body: {pUserId: SessionManager.instance.getUserID().toString()},
    );
    FetchPatient data = FetchPatient.fromJson(jsonDecode(response.body));
    SessionManager.instance
        .setString(key: kPatient, value: jsonEncode(data.data));
    return data;
  }

  Future<Message> addPatient({
    String? fullName,
    String? age,
    String? relation,
    int? gender,
    File? image,
  }) async {
    var request = http.MultipartRequest(
      pPost,
      Uri.parse(Urls.addPatient),
    );

    request.headers.addAll({
      pApikeyName: ConstRes.apiKey,
    });
    request.fields[pUserId] = '${SessionManager.instance.getUserID()}';
    if (fullName != null) {
      request.fields[pFullName] = fullName;
    }
    if (age != null) {
      request.fields[pAge] = age.toString();
    }
    if (relation != null) {
      request.fields[pRelation] = relation.toString();
    }
    if (gender != null) {
      request.fields[pGender] = gender.toString();
    }

    if (image != null) {
      request.files.add(http.MultipartFile(
          pImage, image.readAsBytes().asStream(), image.lengthSync(),
          filename: image.path.split("/").last));
    }
    var response = await request.send();
    var respStr = await response.stream.bytesToString();
    return Message.fromJson(jsonDecode(respStr));
  }

  Future<Message> editPatient(
      {String? fullName,
      String? age,
      String? relation,
      int? gender,
      File? image,
      int? patientId}) async {
    var request = http.MultipartRequest(
      pPost,
      Uri.parse(Urls.editPatient),
    );

    request.headers.addAll({
      pApikeyName: ConstRes.apiKey,
    });
    request.fields[pPatientId] = '$patientId';
    if (fullName != null) {
      request.fields[pFullName] = fullName;
    }
    if (age != null) {
      request.fields[pAge] = age.toString();
    }
    if (relation != null) {
      request.fields[pRelation] = relation.toString();
    }
    if (gender != null) {
      request.fields[pGender] = gender.toString();
    }

    if (image != null) {
      request.files.add(http.MultipartFile(
          pImage, image.readAsBytes().asStream(), image.lengthSync(),
          filename: image.path.split("/").last));
    }
    var response = await request.send();
    var respStr = await response.stream.bytesToString();
    return Message.fromJson(jsonDecode(respStr));
  }

  Future<Message> deletePatient({int? patientId}) async {
    http.Response response = await http.post(
      Uri.parse(Urls.deletePatient),
      headers: {pApikeyName: ConstRes.apiKey},
      body: {pPatientId: patientId.toString()},
    );
    return Message.fromJson(jsonDecode(response.body));
  }

  Future<FetchDoctor> fetchDoctorProfile({int? doctorId}) async {
    http.Response response = await http.post(
      Uri.parse(Urls.fetchDoctorProfile),
      headers: {pApikeyName: ConstRes.apiKey},
      body: {pDoctorId: doctorId.toString()},
    );
    return FetchDoctor.fromJson(jsonDecode(response.body));
  }

  Future<DoctorReview> fetchDoctorReviews(
      {int? doctorId, int start = 0}) async {
    http.Response response = await http.post(
      Uri.parse(Urls.fetchDoctorReviews),
      headers: {
        pApikeyName: ConstRes.apiKey,
      },
      body: {
        pDoctorId: doctorId.toString(),
        pStart: start.toString(),
        pCount: '$paginationLimit',
      },
    );
    return DoctorReview.fromJson(jsonDecode(response.body));
  }

  Future<FavDoctor> fetchFavoriteDoctors() async {
    http.Response response = await http.post(
      Uri.parse(Urls.fetchFavoriteDoctors),
      headers: {
        pApikeyName: ConstRes.apiKey,
      },
      body: {
        pUserId: SessionManager.instance.getUserID().toString(),
      },
    );
    return FavDoctor.fromJson(jsonDecode(response.body));
  }

  Future<Coupon> fetchCoupons() async {
    http.Response response = await http.post(
      Uri.parse(Urls.fetchCoupons),
      headers: {
        pApikeyName: ConstRes.apiKey,
      },
      body: {
        pUserId: SessionManager.instance.getUserID().toString(),
      },
    );
    return Coupon.fromJson(jsonDecode(response.body));
  }

  Future<Registration> fetchMyUserDetails() async {
    http.Response response = await http.post(
      Uri.parse(Urls.fetchMyUserDetails),
      headers: {
        pApikeyName: ConstRes.apiKey,
      },
      body: {
        pUserId: SessionManager.instance.getUserID().toString(),
      },
    );
    Registration user = Registration.fromJson(jsonDecode(response.body));
    SessionManager.instance.setUser(user.data);
    return user;
  }

  Future<Message> addMoneyToUserWallet(
      {num? amount,
      required String transactionId,
      required String transactionSummary,
      required int paymentGateway}) async {
    http.Response response = await http.post(
      Uri.parse(Urls.addMoneyToUserWallet),
      headers: {
        pApikeyName: ConstRes.apiKey,
      },
      body: {
        pUserId: SessionManager.instance.getUserID().toString(),
        pAmount: amount.toString(),
        pGateway: paymentGateway.toString(),
        pTransactionId: transactionId,
        pTransactionSummary: transactionSummary,
      },
    );
    await fetchMyUserDetails();
    return Message.fromJson(jsonDecode(response.body));
  }

  Future<AddAppointment> addAppointment({
    required int? doctorId,
    int? patientId,
    required String problem,
    required String date,
    required String time,
    required OrderSummary orderSummary,
    required num payableAmount,
    required int? type,
    required int isCouponApplied,
    required num discountAmount,
    required num serviceAmount,
    required num subTotal,
    required num totalTaxAmount,
    List<File>? documents,
  }) async {
    var request = http.MultipartRequest(
      pPost,
      Uri.parse(Urls.addAppointment),
    );
    request.headers.addAll({
      pApikeyName: ConstRes.apiKey,
    });
    request.fields[pUserId] = SessionManager.instance.getUserID().toString();
    request.fields[pDoctorId] = '$doctorId';
    if (patientId != null) {
      request.fields[pPatientId] = '$patientId';
    }
    request.fields[pProblem] = problem;
    request.fields[pDate] = date;
    request.fields[pTime] = time;
    request.fields[pOrderSummary] = jsonEncode(orderSummary);
    request.fields[pPayableAmount] = '$payableAmount';
    request.fields[pType] = '$type';
    request.fields[pIsCouponApplied] = '$isCouponApplied';
    request.fields[pDiscountAmount] = '$discountAmount';
    request.fields[pServiceAmount] = '$serviceAmount';
    request.fields[pSubtotal] = '$subTotal';
    request.fields[pTotalTaxAmount] = '$totalTaxAmount';

    List<http.MultipartFile> newList = <http.MultipartFile>[];
    if (documents != null) {
      for (int i = 0; i < documents.length; i++) {
        File imageFile = documents[i];
        var multipartFile = http.MultipartFile(pDocuments,
            imageFile.readAsBytes().asStream(), imageFile.lengthSync(),
            filename: imageFile.path.split('/').last);
        newList.add(multipartFile);
      }
    }
    request.files.addAll(newList);
    var response = await request.send();
    var respStr = await response.stream.bytesToString();
    return AddAppointment.fromJson(jsonDecode(respStr));
  }

  Future<WalletStatement> fetchWalletStatement({int? start}) async {
    http.Response response =
        await http.post(Uri.parse(Urls.fetchWalletStatement), headers: {
      pApikeyName: ConstRes.apiKey
    }, body: {
      pUserId: SessionManager.instance.getUserID().toString(),
      pStart: start.toString(),
      pCount: '$paginationLimit',
    });
    return WalletStatement.fromJson(jsonDecode(response.body));
  }

  Future<WalletStatement> submitUserWithdrawRequest(
      {String? bankName,
      String? accountNumber,
      String? holderName,
      String? swiftCode}) async {
    http.Response response =
        await http.post(Uri.parse(Urls.submitUserWithdrawRequest), headers: {
      pApikeyName: ConstRes.apiKey
    }, body: {
      pUserId: SessionManager.instance.getUserID().toString(),
      pBankTitle: bankName,
      pAccountNumber: accountNumber,
      pHolder: holderName,
      pSwiftCode: swiftCode,
    });
    fetchMyUserDetails();
    return WalletStatement.fromJson(jsonDecode(response.body));
  }

  Future<Appointment> fetchAppointmentDetails({int? appointmentId}) async {
    http.Response response =
        await http.post(Uri.parse(Urls.fetchAppointmentDetails), headers: {
      pApikeyName: ConstRes.apiKey
    }, body: {
      pAppointmentId: appointmentId.toString(),
    });
    return Appointment.fromJson(
      jsonDecode(response.body),
    );
  }

  Future<FetchPrescription> fetchMyPrescriptions() async {
    http.Response response =
        await http.post(Uri.parse(Urls.fetchMyPrescriptions), headers: {
      pApikeyName: ConstRes.apiKey
    }, body: {
      pUserId: SessionManager.instance.getUserID().toString(),
    });
    return FetchPrescription.fromJson(jsonDecode(response.body));
  }

  Future<FetchAppointment> fetchMyAppointments() async {
    http.Response response = await http.post(
        Uri.parse(Urls.fetchMyAppointments),
        headers: {pApikeyName: ConstRes.apiKey},
        body: {pUserId: SessionManager.instance.getUserID().toString()});
    return FetchAppointment.fromJson(jsonDecode(response.body));
  }

  Future<Appointment> addRating(
      {int? appointmentId, int? userId, String? comment, int? rating}) async {
    http.Response response =
        await http.post(Uri.parse(Urls.addRating), headers: {
      pApikeyName: ConstRes.apiKey
    }, body: {
      pAppointmentId: appointmentId.toString(),
      pUserId: userId.toString(),
      pComment: comment.toString(),
      pRating: rating.toString(),
    });
    return Appointment.fromJson(jsonDecode(response.body));
  }

  Future<Appointment> rescheduleAppointment(
      {int? appointmentId, int? userId, String? date, String? time}) async {
    http.Response response =
        await http.post(Uri.parse(Urls.rescheduleAppointment), headers: {
      pApikeyName: ConstRes.apiKey
    }, body: {
      pAppointmentId: appointmentId.toString(),
      pUserId: userId.toString(),
      pDate: date,
      pTime: time,
    });
    return Appointment.fromJson(jsonDecode(response.body));
  }

  Future<Appointment> cancelAppointment({
    int? appointmentId,
    int? userId,
  }) async {
    http.Response response =
        await http.post(Uri.parse(Urls.cancelAppointment), headers: {
      pApikeyName: ConstRes.apiKey
    }, body: {
      pAppointmentId: appointmentId.toString(),
      pUserId: userId.toString(),
    });
    return Appointment.fromJson(jsonDecode(response.body));
  }

  Future<WithdrawRequest> fetchUserWithdrawRequests({
    int? start,
  }) async {
    http.Response response =
        await http.post(Uri.parse(Urls.fetchUserWithdrawRequests), headers: {
      pApikeyName: ConstRes.apiKey
    }, body: {
      pUserId: SessionManager.instance.getUserID().toString(),
      pStart: start.toString(),
      pCount: '$paginationLimit'
    });
    return WithdrawRequest.fromJson(jsonDecode(response.body));
  }

  Future<Message> logOut() async {
    http.Response response = await http.post(Uri.parse(Urls.logOut), headers: {
      pApikeyName: ConstRes.apiKey
    }, body: {
      pUserId: SessionManager.instance.getUserID().toString(),
    });
    return Message.fromJson(jsonDecode(response.body));
  }

  Future<Message> deleteUserAccount() async {
    http.Response response =
        await http.post(Uri.parse(Urls.deleteUserAccount), headers: {
      pApikeyName: ConstRes.apiKey
    }, body: {
      pUserId: SessionManager.instance.getUserID().toString(),
    });
    return Message.fromJson(jsonDecode(response.body));
  }

  Future<GlobalSetting> fetchGlobalSettings() async {
    http.Response response = await http.post(
        Uri.parse(Urls.fetchGlobalSettings),
        headers: {pApikeyName: ConstRes.apiKey});
    GlobalSetting setting = GlobalSetting.fromJson(jsonDecode(response.body));
    SessionManager.instance.setSettings(setting.data);
    return setting;
  }

  Future<FetchFaqs> fetchFaqCats() async {
    http.Response response = await http.post(Uri.parse(Urls.fetchFaqCats),
        headers: {pApikeyName: ConstRes.apiKey});
    FetchFaqs faqs = FetchFaqs.fromJson(jsonDecode(response.body));
    return faqs;
  }

  createPaymentIntent(
      {required String amount,
      required String currency,
      required String authKey}) async {
    try {
      //Request body
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
      };

      //Make post request to Stripe
      http.Response response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $authKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return jsonDecode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  calculateAmount(String amount) {
    final calculateAmount = (int.parse(amount)) * 100;
    return calculateAmount.toString();
  }

  Future<GetPath> uploadFileGivePath(File? image) async {
    var request = http.MultipartRequest(
      pPost,
      Uri.parse(Urls.uploadFileGivePath),
    );
    request.headers.addAll({
      pApikeyName: ConstRes.apiKey,
    });
    if (image != null) {
      request.files.add(
        http.MultipartFile(
            pFile, image.readAsBytes().asStream(), image.lengthSync(),
            filename: image.path.split("/").last),
      );
    }
    var response = await request.send();
    var respStr = await response.stream.bytesToString();
    final responseJson = jsonDecode(respStr);
    return GetPath.fromJson(responseJson);
  }

  Future<AgoraToken> getAgoraToken({required String channelName}) async {
    http.Response response = await http.post(Uri.parse(Urls.generateAgoraToken),
        headers: {pApikeyName: ConstRes.apiKey},
        body: {pChannelName: channelName});
    return AgoraToken.fromJson(jsonDecode(response.body));
  }

  Future pushNotification(
      {String? token,
      num? deviceType,
      required Map<String, dynamic> data}) async {
    bool isIOS = deviceType == 2;

    Map<String, dynamic> messageData = {
      "apns": {
        "payload": {
          "aps": {"sound": "default"}
        }
      },
      "data": data
    };

    if (isIOS) {
      messageData["notification"] = {
        "body": data['body'],
        "title": data['title']
      };
    }

    messageData["token"] = token;
    Map<String, dynamic> inputData = {"message": messageData};
    await http
        .post(Uri.parse(Urls.pushNotificationToSingleUser),
            headers: {
              pApikeyName: ConstRes.apiKey,
              // 'content-type': 'application/json'
            },
            body: json.encode(inputData))
        .then((value) {
      debugPrint('Notification : ${value.body}');
    });
  }

  Future<FetchAcceptPendingAppointments>
      fetchAcceptedPendingAppointmentsOfDoctorByDate(
          {required int doctorId, required String date}) async {
    http.Response response = await http.post(
        Uri.parse(Urls.fetchAcceptedPendingAppointmentsOfDoctorByDate),
        headers: {pApikeyName: ConstRes.apiKey},
        body: {pDoctorId: doctorId.toString(), pDate: date});
    return FetchAcceptPendingAppointments.fromJson(jsonDecode(response.body));
  }

  void call(
      {required String url,
      Map<String, dynamic>? param,
      required Function(Object response) completion,
      Map<String, String>? header}) async {
    Map<String, String> params = {};
    param?.forEach((key, value) {
      params[key] = "$value";
    });

    debugPrint('👉 URL $url');
    // debugPrint('👉 Parameters $param');
    try {
      await http
          .post(Uri.parse(url),
              headers: header ?? {pApikeyName: ConstRes.apiKey}, body: params)
          .then((value) {
        // debugPrint('👉 Response ${value.body}');
        debugPrint('👉 Status Code ${value.statusCode}');
        var response = jsonDecode(value.body);
        completion(response);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void chatCompletion(
      {required Function(Object response) completion,
      required String model,
      required List<AiBot> content,
      required String token}) async {
    Map<String, dynamic> param = {
      "model": model,
      "messages": content,
      "temperature": 0.7
    };
    debugPrint("❗️{PARAMETER}:  $param");
    debugPrint("❗️{Token}:  $token");

    await http
        .post(Uri.parse(Urls.myHealthBotUrl),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json'
            },
            body: jsonEncode(param))
        .then((value) {
      // debugPrint( '👉 Response', value.body);
      debugPrint(
        '👉 Status Code ${value.statusCode}',
      );
      var response = jsonDecode(value.body);
      completion(response);
    });
  }

  Future<Message> scheduleAppointmentReminders(
      {required int appointmentID, required List<String> scheduledAt}) async {
    debugPrint('message Calling');

    Map<String, String> map = {};
    for (int i = 0; i < scheduledAt.length; i++) {
      map["$pScheduledAt[$i]"] = scheduledAt[i];
    }
    map[pUserId] = SessionManager.instance.getUserID().toString();
    map[pAppointmentId] = '$appointmentID';

    http.Response response = await http.post(
        Uri.parse(Urls.scheduleAppointmentReminders),
        headers: {pApikeyName: ConstRes.apiKey},
        body: map);
    return Message.fromJson(jsonDecode(response.body));
  }
}
