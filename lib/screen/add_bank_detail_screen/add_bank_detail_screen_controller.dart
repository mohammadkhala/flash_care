import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:doctor_flutter/service/session_manager.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddBankDetailScreenController extends GetxController {
  TextEditingController bankNameController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController reAccountNumberController = TextEditingController();
  TextEditingController holderNameController = TextEditingController();
  TextEditingController swiftCodeController = TextEditingController();
  XFile? chequePhoto;
  String? networkChequeImage;
  BankAccount? userData;
  bool isBankName = false;
  bool isAccountNumber = false;
  bool isReAccountNumber = false;
  bool isHolderName = false;
  bool isSwiftCode = false;

  @override
  void onInit() {
    prefData();
    super.onInit();
  }

  void manageDrBankAccountApiCall() {
    bool isValidate = isValidation();
    if (isValidate) {
      ApiService.instance
          .manageDrBankAccount(
        accountNumber: accountNumberController.text,
        bankName: bankNameController.text,
        holderName: holderNameController.text,
        swiftCode: swiftCodeController.text,
        chequePhoto: chequePhoto,
      )
          .then((value) {
        if (value.data?.bankAccount != null) {
          userData = value.data?.bankAccount;
          CustomUi.snackBar(
            message: value.message,
          );
        } else {
          CustomUi.snackBar(
            message: value.message,
          );
        }
        update();
      });
    }
  }

  bool isValidation() {
    isBankName = false;
    isAccountNumber = false;
    isReAccountNumber = false;
    isHolderName = false;
    isSwiftCode = false;
    int i = 0;
    if (bankNameController.text.isEmpty) {
      i++;
      isBankName = true;
    } else if (accountNumberController.text.isEmpty) {
      i++;
      isAccountNumber = true;
    } else if (reAccountNumberController.text.isEmpty) {
      i++;
      isReAccountNumber = true;
    } else if (holderNameController.text.isEmpty) {
      i++;
      isHolderName = true;
    } else if (swiftCodeController.text.isEmpty) {
      i++;
      isSwiftCode = true;
    } else if (chequePhoto == null && networkChequeImage == null) {
      CustomUi.snackBar(
        message: S.current.pleaseAddCancelChequePhoto,
      );
      i++;
    } else if (accountNumberController.text != reAccountNumberController.text) {
      isReAccountNumber = true;
      CustomUi.snackBar(
        message: S.current.yourAccountNumberNotSame,
      );
      i++;
    }
    update();
    return i == 0 ? true : false;
  }

  void prefData() async {
    userData = SessionManager.instance.getDoctor()?.bankAccount;
    bankNameController = TextEditingController(text: userData?.bankName ?? '');
    accountNumberController = TextEditingController(text: userData?.accountNumber ?? '');
    reAccountNumberController = TextEditingController(text: userData?.accountNumber ?? '');
    holderNameController = TextEditingController(text: userData?.holder ?? '');
    swiftCodeController = TextEditingController(text: userData?.swiftCode ?? '');
    if (userData?.chequePhoto != null) {
      networkChequeImage = userData?.chequePhoto;
    }
    update();
  }

  void onChequePhotoTap() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: imageQuality, maxHeight: maxHeight, maxWidth: maxWidth);
    if (image != null) {
      chequePhoto = image;
    }
    update();
  }
}
