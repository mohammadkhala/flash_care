import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:pay_with_paystack/model/payment_data.dart';
import 'package:pay_with_paystack/pay_with_paystack.dart';
import 'package:paypal_payment/paypal_payment.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

String email = 'test@gmail.com';
String address = 'Test Location';
String pinCode = '395005';
String city = 'TESTING';
String countryCode = 'IN';
String state = 'Gujarat';

_calculateAmount(String amount) {
  final calculateAmount = (int.parse(amount)) * 100;
  return calculateAmount.toString();
}

class StripePayment {
  Future<void> makePayment(
      {required String amount,
      required String authKey,
      UserData? user,
      required String currency,
      required Function(String error) onError,
      required Function(Map value) onSuccess}) async {
    Map<String, dynamic> paymentIntent;
    try {
      paymentIntent = await ApiService.instance.createPaymentIntent(
          amount: amount, currency: currency, authKey: authKey);

      // STEP 2: Initialize Payment Sheet
      try {
        await Stripe.instance
            .initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            customFlow: false,
            merchantDisplayName: user?.fullname ?? S.current.unKnown,
            paymentIntentClientSecret: paymentIntent['client_secret'],
            setupIntentClientSecret: paymentIntent['client_secret'],
            customerId: paymentIntent['customer'],
            customerEphemeralKeySecret: paymentIntent['ephemeralKey'],
            style: ThemeMode.dark,
          ),
        )
            .then((value) async {
          //STEP 3: Display Payment sheet
          await Stripe.instance.presentPaymentSheet().then((value) {
            onSuccess(paymentIntent);
          }).onError((error, stackTrace) {
            onError('Payment Failed');
          }).catchError((e) {
            onError('Payment Failed');
          });
        }).onError((error, stackTrace) {});
      } catch (e) {
        log(e.toString());
      }
    } catch (err) {
      throw Exception(err);
    }
  }
}

class RazorPayPayment {
  void makePayment({
    required String amount,
    required String authKey,
    required String currency,
    UserData? user,
    required Function(PaymentFailureResponse response)
        handlePaymentErrorResponse,
    required Function(PaymentSuccessResponse response)
        handlePaymentSuccessResponse,
    required Function(ExternalWalletResponse response)
        handleExternalWalletSelected,
  }) {
    Razorpay razorpay = Razorpay();
    var options = {
      'key': authKey,
      'amount': _calculateAmount(amount),
      'currency': currency,
      'name': S.current.doctorIo,
      'description': 'Add Coin to wallet',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': user?.identity ?? '', 'email': email},
      'external': {
        'wallets': [
          'paytm',
        ]
      }
    };

    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
    razorpay.open(options);
  }
}

class PaystackPayment {
  // var plugin = PaystackPlugin();

  void makePayment({
    required String amount,
    UserData? user,
    required String publicKey,
    required String currency,
    required String authKey,
    required Function(PaymentData) transactionCompleted,
    required Function(String response) transactionNotCompleted,
  }) async {
    // await plugin.initialize(publicKey: publicKey);
    var ref = DateTime.now().microsecondsSinceEpoch.toString();
    PayWithPayStack().now(
      context: Get.context!,
      secretKey: authKey,
      customerEmail: email,
      reference: ref,
      callbackUrl: "https://retrytech.com/",
      currency: currency,
      paymentChannel: ["mobile_money", "card"],
      amount: double.parse(_calculateAmount(amount)),
      transactionCompleted: transactionCompleted,
      transactionNotCompleted: transactionNotCompleted,
    );
  }
}

class PaypalPayment {
  void makePayment({
    UserData? user,
    required String clientId,
    required String authKey,
    required String amount,
    required String currency,
    required Function(Map param) onSuccess,
    required Function(dynamic error) onError,
    required Function(dynamic param) onCancel,
  }) {
    Get.to(() => PaypalOrderPayment(
        sandboxMode: true,
        clientId:
            'AWAx9jlPcgEW307XY4IhBhiDD-cHLioraxAYKsmWVizHt__vd3YuV4p31CK8jm8JswOQVbYgsl9zFOHq',
        secretKey:
            'EL7zh5my5hXGBsu0_cAV0kBl3XnR_MeJ4yHzcrN_S8EMk8jtM0cMzw-eYOUXHC7QPP4b_5Y1Hwt2BeVb',
        currencyCode: currency,
        amount: amount,
        onSuccess: onSuccess,
        returnURL: "https://retrytech.com/",
        cancelURL: "https://retrytech.com/",
        onError: onError,
        onCancel: onCancel));

    // Get.to(
    //   () => PaypalCheckoutView(
    //     sandboxMode: true,
    //     clientId: clientId,
    //     secretKey: authKey,
    //     transactions: [
    //       {
    //         "amount": {
    //           "total": amount,
    //           "currency": currency,
    //           "details": {"subtotal": amount, "shipping": '0', "shipping_discount": 0}
    //         },
    //         "description": "The payment transaction description.",
    //         "item_list": {
    //           "items": [
    //             {"name": "Coin Wallet", "quantity": 1, "price": amount, "currency": currency}
    //           ],
    //           // shipping address is not required though
    //           // "shipping_address": {
    //           //   "recipient_name": user?.fullname ??
    //           //       AppLocalizations.of(Get.context!)!.unknown,
    //           //   "line1": address,
    //           //   "line2": "",
    //           //   "city": city,
    //           //   "country_code": countryCode,
    //           //   "postal_code": pinCode,
    //           //   "phone": '+91 12345 67890',
    //           //   "state": state
    //           // },
    //         }
    //       }
    //     ],
    //     note: "Contact us for any questions on your order.",
    //     onSuccess: onSuccess,
    //     onError: onError,
    //     onCancel: onCancel,
    //   ),
    // );
  }
}

Future<String?> getPayPalAccessToken() async {
  final clientId = "YOUR_CLIENT_ID";
  final secret = "YOUR_SECRET_KEY";
  final auth = base64Encode(utf8.encode("$clientId:$secret"));

  final response = await http.post(
    Uri.parse("https://api-m.sandbox.paypal.com/v1/oauth2/token"),
    headers: {
      "Authorization": "Basic $auth",
      "Content-Type": "application/x-www-form-urlencoded"
    },
    body: "grant_type=client_credentials",
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['access_token'];
  } else {
    print("Error: ${response.body}");
    return null;
  }
}

Future<String?> createPayPalOrder(String accessToken) async {
  final response = await http.post(
    Uri.parse("https://api-m.sandbox.paypal.com/v2/checkout/orders"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken"
    },
    body: jsonEncode({
      "intent": "CAPTURE",
      "purchase_units": [
        {
          "amount": {"currency_code": "USD", "value": "10.00"}
        }
      ],
      "application_context": {
        "return_url": "https://yourapp.com/success",
        "cancel_url": "https://yourapp.com/cancel"
      }
    }),
  );

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    return data['id']; // PayPal Order ID
  } else {
    print("Error: ${response.body}");
    return null;
  }
}

Future<void> launchPayPalPayment(String orderId) async {
  final url = "https://www.sandbox.paypal.com/checkoutnow?token=$orderId";
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    print("Could not launch PayPal URL");
  }
}

Future<bool> capturePayPalPayment(String accessToken, String orderId) async {
  final response = await http.post(
    Uri.parse(
        "https://api-m.sandbox.paypal.com/v2/checkout/orders/$orderId/capture"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken"
    },
  );

  if (response.statusCode == 201) {
    print("Payment Captured: ${response.body}");
    return true;
  } else {
    print("Error capturing payment: ${response.body}");
    return false;
  }
}

// class PaypalPayment {
//   void makePayment({
//     UserData? user,
//     required String clientId,
//     required String authKey,
//     required String amount,
//     required String currency,
//     required Function(Map param) onSuccess,
//     required Function(dynamic error) onError,
//     required Function(dynamic param) onCancel,
//   }) {
//     Get.to(() => UsePaypal(
//           sandboxMode: true,
//           clientId: clientId,
//           secretKey: authKey,
//           onSuccess: onSuccess,
//           onError: onError,
//           onCancel: onCancel,
//           transactions: [
//             {
//               "amount": {
//                 "total": amount,
//                 "currency": currency,
//                 "details": {"subtotal": '10.12', "shipping": '0', "shipping_discount": 0}
//               },
//             }
//           ],
//           returnURL: "https://samplesite.com/return",
//           cancelURL: "https://samplesite.com/cancel",
//         ));
//
//     // Get.to(
//     //   () => PaypalCheckoutView(
//     //     sandboxMode: true,
//     //     clientId: clientId,
//     //     secretKey: authKey,
//     //     transactions: [
//     //       {
//     //         "amount": {
//     //           "total": amount,
//     //           "currency": currency,
//     //           "details": {"subtotal": amount, "shipping": '0', "shipping_discount": 0}
//     //         },
//     //         "description": "The payment transaction description.",
//     //         "item_list": {
//     //           "items": [
//     //             {"name": "Coin Wallet", "quantity": 1, "price": amount, "currency": currency}
//     //           ],
//     //           // shipping address is not required though
//     //           // "shipping_address": {
//     //           //   "recipient_name": user?.fullname ??
//     //           //       AppLocalizations.of(Get.context!)!.unknown,
//     //           //   "line1": address,
//     //           //   "line2": "",
//     //           //   "city": city,
//     //           //   "country_code": countryCode,
//     //           //   "postal_code": pinCode,
//     //           //   "phone": '+91 12345 67890',
//     //           //   "state": state
//     //           // },
//     //         }
//     //       }
//     //     ],
//     //     note: "Contact us for any questions on your order.",
//     //     onSuccess: onSuccess,
//     //     onError: onError,
//     //     onCancel: onCancel,
//     //   ),
//     // );
//   }
// }

class FlutterwavePayment {
  // void makePayment({
  //   RegistrationData? user,
  //   required String amount,
  //   required String publishKey,
  //   required String currency,
  //   required Function(ChargeResponse param) onSuccess,
  //   required Function(dynamic error) onError,
  // }) async {
  //   final Customer customer =
  //       Customer(email: email, name: user?.fullname ?? S.current.unKnown, phoneNumber: user?.identity ?? '');
  //
  //   final Flutterwave flutterwave = Flutterwave(
  //     context: Get.context!,
  //     publicKey: publishKey,
  //     currency: currency,
  //     redirectUrl: 'https://facebook.com',
  //     txRef: const Uuid().v1(),
  //     amount: amount,
  //     customer: customer,
  //     paymentOptions: "card, payattitude, barter, bank transfer, ussd",
  //     customization: Customization(title: "Wallet Payment"),
  //     isTestMode: true,
  //     // style: FlutterwaveStyle(
  //     //   buttonColor: ColorRes.tuftsBlue,
  //     //   buttonTextStyle: MyTextStyle.montserratMedium(color: ColorRes.white, size: 15),
  //     //   appBarColor: ColorRes.whiteSmoke,
  //     //   appBarTitleTextStyle: MyTextStyle.montserratBold(
  //     //     size: 17,
  //     //     color: ColorRes.charcoalGrey
  //     //   ),
  //     // ),
  //   );
  //   flutterwave.charge().then((value) {
  //     if (value.success == true) {
  //       onSuccess(value);
  //     } else {
  //       onError(S.current.paymentFailed);
  //     }
  //   }).onError((error, stackTrace) {
  //     onError(S.current.paymentFailed);
  //   });
  // }
}

class PaystackResponse {
  PaystackResponse({
    bool? status,
    String? message,
    Data? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  PaystackResponse.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  bool? _status;
  String? _message;
  Data? _data;

  PaystackResponse copyWith({
    bool? status,
    String? message,
    Data? data,
  }) =>
      PaystackResponse(
        status: status ?? _status,
        message: message ?? _message,
        data: data ?? _data,
      );

  bool? get status => _status;

  String? get message => _message;

  Data? get data => _data;

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

class Data {
  Data({
    String? authorizationUrl,
    String? accessCode,
    String? reference,
  }) {
    _authorizationUrl = authorizationUrl;
    _accessCode = accessCode;
    _reference = reference;
  }

  Data.fromJson(dynamic json) {
    _authorizationUrl = json['authorization_url'];
    _accessCode = json['access_code'];
    _reference = json['reference'];
  }

  String? _authorizationUrl;
  String? _accessCode;
  String? _reference;

  Data copyWith({
    String? authorizationUrl,
    String? accessCode,
    String? reference,
  }) =>
      Data(
        authorizationUrl: authorizationUrl ?? _authorizationUrl,
        accessCode: accessCode ?? _accessCode,
        reference: reference ?? _reference,
      );

  String? get authorizationUrl => _authorizationUrl;

  String? get accessCode => _accessCode;

  String? get reference => _reference;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['authorization_url'] = _authorizationUrl;
    map['access_code'] = _accessCode;
    map['reference'] = _reference;
    return map;
  }
}

class SSLCommerze {
  static void makePayment(
      {required String storeId,
      required String storePassword,
      required String totalAmount,
      required String currency,
      required Function(SSLCTransactionInfoModel response) onCompletion}) {
    Sslcommerz sslcommerz = Sslcommerz(
        initializer: SSLCommerzInitialization(
            currency: currency.toUpperCase(),
            product_category: sslProductCategory,
            sdkType: sslSdkType,
            store_id: storeId,
            store_passwd: storePassword,
            total_amount: double.parse(totalAmount),
            tran_id: const Uuid().v1()));
    sslcommerz.payNow().then(
      (value) {
        onCompletion.call(value);
        print('🛑 ${value.toJson()}');
      },
    );
  }
}
