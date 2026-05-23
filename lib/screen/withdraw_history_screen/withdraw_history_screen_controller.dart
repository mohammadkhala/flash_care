import 'package:get/get.dart';
import 'package:patient_flutter/model/wallet/withdraw_request.dart';
import 'package:patient_flutter/services/api_service.dart';

class WithdrawHistoryScreenController extends GetxController {
  List<WithdrawRequestData>? withdrawData;

  bool isLoading = false;

  @override
  void onInit() {
    fetchUserWithdrawRequestsApiCall();
    super.onInit();
  }

  void fetchUserWithdrawRequestsApiCall() {
    isLoading = true;
    ApiService.instance.fetchUserWithdrawRequests().then((value) {
      withdrawData = value.data;
      isLoading = false;
      update();
    });
  }
}
