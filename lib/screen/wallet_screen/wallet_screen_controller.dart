import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/model/wallet/wallet_statement.dart';
import 'package:patient_flutter/screen/recharge_wallet_sheet/recharge_wallet_sheet.dart';
import 'package:patient_flutter/screen/withdraw_request_screen/withdraw_request_screen.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/utils/const_res.dart';

class WalletScreenController extends GetxController {
  UserData? userData;
  List<WalletStatementData> walletData = [];
  bool isLoading = false;
  ScrollController statementController = ScrollController();

  @override
  void onInit() {
    fetchPatientData();
    fetchWalletStatementDataApiCall();
    fetchScrollData();
    super.onInit();
  }

  void onAddBtnClick() {
    Get.bottomSheet(
        RechargeWalletSheet(
            screenType: 1,
            onUpdateAmount: (amount) {
              userData?.updateWallet(amount);
              update();
              fetchWalletStatementDataApiCall(reset: true);
            }),
        isScrollControlled: true);
  }

  void fetchPatientData() {
    ApiService.instance.fetchMyUserDetails().then((value) {
      userData = value.data;
      update();
    });
  }

  void fetchWalletStatementDataApiCall({bool reset = true}) {
    isLoading = true;
    ApiService.instance.fetchWalletStatement(start: reset ? 0 : walletData.length).then((value) {
      if (reset) {
        walletData.clear();
      }
      walletData.addAll(value.data ?? []);
      isLoading = false;
      update();
    });
  }

  void onWithdrawTap(UserData? data) {
    ((data?.wallet ?? 0) >= minimumAmountWithdraw)
        ? Get.to(() => const WithdrawRequestScreen(), arguments: data?.wallet ?? 0)?.then((value) {
            fetchPatientData();
            fetchWalletStatementDataApiCall(reset: true);
          })
        : CustomUi.snackBar(message: S.current.notEnoughBalanceToWithdraw);
  }

  void fetchScrollData() {
    statementController.addListener(
      () {
        if (statementController.offset == statementController.position.maxScrollExtent) {
          if (!isLoading) {
            fetchWalletStatementDataApiCall();
          }
        }
      },
    );
  }
}
