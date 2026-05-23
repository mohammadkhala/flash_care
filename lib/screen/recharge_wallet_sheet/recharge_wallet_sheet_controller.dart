import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/global/global_setting.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/screen/confirm_booking_screen/widget/transaction_complete_sheet.dart';
import 'package:patient_flutter/screen/recharge_wallet_sheet/widget/payment_gateway.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/services/session_manager.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/update_res.dart';

class RechargeWalletSheetController extends GetxController {
  List<String> list = [
    '50',
    '100',
    '150',
    '200',
    otherCap,
  ];
  String selectedAmount = '0';
  int? selectedAmountIndex;
  TextEditingController amountController = TextEditingController();
  GlobalSettingData? settings;
  UserData? user;
  Function(int selectedAmount)? onUpdateAmount;

  RechargeWalletSheetController(this.onUpdateAmount);

  @override
  void onInit() {
    prefData();
    selectedAmount = Get.arguments ?? '0';
    amountController.text = Get.arguments ?? '0';
    super.onInit();
  }

  void onCategoryChange(int categoryIndex) {
    selectedAmountIndex = categoryIndex;
    if (list[selectedAmountIndex!] == otherCap) {
    } else {
      selectedAmount = list[selectedAmountIndex!];
      amountController.clear();
    }
    update();
  }

  void onTextChange(String value) {
    selectedAmount =
        amountController.text.isEmpty ? '0' : amountController.text;
    update();
  }

  void onContinueTap(int type) {
    if (settings?.paymentGateway == 1) {
      // Go to And SelectCard-> https://docs.stripe.com/testing

      CustomUi.loader();
      StripePayment().makePayment(
        amount: selectedAmount,
        currency: settings?.stripeCurrencyCode ?? defaultCurrency,
        user: user,
        authKey: settings?.stripeSecret ?? '',
        onError: (error) {
          Get.back();
          CustomUi.infoSnackBar(S.current.paymentFailed);
        },
        onSuccess: (value) {
          Get.back();
          apiCall(type,
              paymentGateway: 1,
              transactionId: value['id'],
              transactionSummary: jsonEncode(value));
        },
      );
    } else if (settings?.paymentGateway == 3) {
      /// card Payment :- 4111 1111 1111 1111
      RazorPayPayment().makePayment(
        amount: selectedAmount,
        authKey: settings?.razorpayKey ?? '',
        currency: settings?.razorpayCurrencyCode ?? defaultCurrency,
        user: user,
        handleExternalWalletSelected: (response) {
          CustomUi.infoSnackBar(response.toString());
        },
        handlePaymentErrorResponse: (response) {
          CustomUi.infoSnackBar(response.message.toString());
        },
        handlePaymentSuccessResponse: (response) {
          Map<String, dynamic> map = {};
          map["razorpay_payment_id"] = response.paymentId;
          map["razorpay_signature"] = response.signature;
          map["razorpay_order_id"] = response.orderId;

          String data = jsonEncode(map);
          apiCall(type,
              paymentGateway: 3,
              transactionSummary: data,
              transactionId: response.paymentId.toString());
        },
      );
    } else if (settings?.paymentGateway == 4) {
      ///Test card:- 4084084084084081
      ///03/24
      ///408

      PaystackPayment().makePayment(
        user: user,
        amount: selectedAmount,
        publicKey: settings?.paystackPublicKey ?? '',
        authKey: settings?.paystackSecretKey ?? '',
        currency: settings?.paystackCurrencyCode ?? defaultCurrency,
        transactionCompleted: (response) {
          print('RESPONSE :: ${response.toJson()}');
          apiCall(type,
              paymentGateway: 4,
              transactionId: response.id.toString(),
              transactionSummary: jsonEncode(response.toJson()));
        },
        transactionNotCompleted: (response) {
          print('CANCEL TRANSACTION :: $response');
        },
      );
    } else if (settings?.paymentGateway == 5) {
      /// Card Type: Visa
      /// Card Number: 4032 0323 7188 0367
      /// Expiration Date: 01/2024
      /// CVV: 571
      PaypalPayment().makePayment(
        amount: selectedAmount,
        currency: settings?.paypalCurrencyCode ?? defaultCurrency,
        authKey: settings?.paypalSecretKey ?? '',
        clientId: settings?.paypalClientId ?? '',
        onSuccess: (param) {
          // Get.back();
          apiCall(type,
              paymentGateway: 5,
              transactionId: param['data']['id'],
              transactionSummary: jsonEncode(param));
        },
        onError: (error) {
          Get.back();
          CustomUi.infoSnackBar(S.current.somethingWentWrong);
        },
        onCancel: (param) {
          Get.back();
          CustomUi.infoSnackBar(S.current.paymentCancelled);
        },
      );
    } else if (settings?.paymentGateway == 6) {
      /// 'Card number' = 5531 8866 5214 2950
      /// 'Expiry' = 09 / 32
      /// 'CVV' = 564
      /// 'OTP' = 12345
      /// 'PIN' = 3310
      //  remove library [analysis issue]

      // FlutterwavePayment().makePayment(
      //   user: user,
      //   amount: selectedAmount,
      //   publishKey: settings?.flutterwavePublicKey ?? '',
      //   currency: settings?.flutterwaveCurrencyCode ?? defaultCurrency,
      //   onError: (error) {
      //     CustomUi.infoSnackBar(error);
      //   },
      //   onSuccess: (param) {
      //     apiCall(
      //       type,
      //       paymentGateway: 6,
      //       transactionId: param.transactionId ?? '',
      //       transactionSummary: jsonEncode(param),
      //     );
      //   },
      // );
    } else if (settings?.paymentGateway == 7) {
      if (settings?.sslcommerzStoreId == null ||
          settings!.sslcommerzStoreId!.isEmpty) {
        return CustomUi.snackBar(message: 'Store id Missing');
      } else if (settings?.sslcommerzStorePasswd == null ||
          settings!.sslcommerzStorePasswd!.isEmpty) {
        return CustomUi.snackBar(message: 'Store Password Missing');
      } else if (settings?.sslcommerzCurrencyCode == null ||
          settings!.sslcommerzCurrencyCode!.isEmpty) {
        return CustomUi.snackBar(
            message: 'This Payment Gateway currency code missing');
      } else if (settings?.sslcommerzCurrencyCode != 'USD' &&
          settings?.sslcommerzCurrencyCode != 'BDT') {
        return CustomUi.snackBar(
            message:
                '${settings?.sslcommerzCurrencyCode} currency not supported');
      }
      SSLCommerze.makePayment(
        storeId: settings?.sslcommerzStoreId ?? '',
        storePassword: settings?.sslcommerzStorePasswd ?? '',
        totalAmount: selectedAmount,
        currency: settings?.sslcommerzCurrencyCode ?? defaultCurrency,
        onCompletion: (response) {
          if (response.status == 'VALID') {
            apiCall(type,
                paymentGateway: 7,
                transactionId: response.tranId ?? '',
                transactionSummary: jsonEncode(response));
          }
        },
      );
    }
  }

  void apiCall(int type,
      {required int paymentGateway,
      required String transactionId,
      required String transactionSummary}) {
    if (type == 1) {
      //wallet screen
      addMoneyApiCall(
          paymentGateway: paymentGateway,
          transactionSummary: transactionSummary,
          transactionId: transactionId);
    } else {
      // appointment booking screen
      addMoneyApiCall(
              paymentGateway: paymentGateway,
              transactionSummary: transactionSummary,
              transactionId: transactionId)
          .then((value) {
        Get.bottomSheet(const TransactionCompleteSheet(),
            isScrollControlled: true);
      });
    }
  }

  Future<void> addMoneyApiCall(
      {required int paymentGateway,
      required String transactionId,
      required String transactionSummary}) async {
    Get.back();
    CustomUi.loader();
    await ApiService.instance
        .addMoneyToUserWallet(
            amount: num.parse(selectedAmount),
            paymentGateway: paymentGateway,
            transactionId: transactionId,
            transactionSummary: transactionSummary)
        .then((value) {
      Get.back();
      if (value.status == true) {
        onUpdateAmount?.call(int.parse(selectedAmount));
        CustomUi.snackBar(message: value.message);
      } else {
        CustomUi.snackBar(message: value.message);
      }
    });
  }

  void prefData() async {
    settings = SessionManager.instance.getSettings();
    user = SessionManager.instance.getUser();
    Stripe.publishableKey = settings?.stripePublishableKey ?? '';
    update();
  }
}
