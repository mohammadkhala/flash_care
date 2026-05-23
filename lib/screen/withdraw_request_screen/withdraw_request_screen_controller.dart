import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/utils/update_res.dart';

class WithdrawRequestScreenController extends GetxController {
  int wallet = 0;
  TextEditingController bankNameController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController reAccountNumberController = TextEditingController();
  TextEditingController holderNameController = TextEditingController();
  TextEditingController swiftCodeController = TextEditingController();

  /// Regex to check valid IFSC (Indian Financial System) Code.
  RegExp regExp = RegExp(ifscCode);

  bool isBankName = false;
  bool isAccountNumber = false;
  bool isReAccountNumber = false;
  bool isHolderName = false;
  bool isSwiftCode = false;

  @override
  void onInit() {
    wallet = Get.arguments;
    super.onInit();
  }

  void onSubmitTap() {
    if (isValid()) {
      CustomUi.loader();
      ApiService.instance
          .submitUserWithdrawRequest(
              bankName: bankNameController.text,
              accountNumber: reAccountNumberController.text,
              holderName: holderNameController.text,
              swiftCode: swiftCodeController.text)
          .then((value) {
        Get.back();
        if (value.status == true) {
          Get.back();
          CustomUi.snackBar(message: value.message ?? '');
        } else {
          CustomUi.snackBar(message: value.message ?? '');
        }
      });
    }
  }

  bool isValid() {
    int i = 0;
    isBankName = false;
    isAccountNumber = false;
    isReAccountNumber = false;
    isHolderName = false;
    isSwiftCode = false;
    update();
    if (bankNameController.text.isEmpty) {
      isBankName = true;
      i++;
      return false;
    }
    if (accountNumberController.text.isEmpty) {
      isAccountNumber = true;
      i++;
      return false;
    }
    if (reAccountNumberController.text.isEmpty) {
      isReAccountNumber = true;
      i++;
      return false;
    } else if (accountNumberController.text != reAccountNumberController.text) {
      i++;
      CustomUi.infoSnackBar(
        S.current.pleaseAccountNumberSame,
      );
      return false;
    }
    if (holderNameController.text.isEmpty) {
      isHolderName = true;
      i++;
      return false;
    }
    if (swiftCodeController.text.isEmpty) {
      isSwiftCode = true;
      i++;
      return false;
    }

    return i == 0 ? true : false;
  }

  @override
  void onClose() {
    bankNameController.dispose();
    accountNumberController.dispose();
    reAccountNumberController.dispose();
    holderNameController.dispose();
    swiftCodeController.dispose();
    super.onClose();
  }
}
