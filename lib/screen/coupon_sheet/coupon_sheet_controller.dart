import 'package:get/get.dart';
import 'package:patient_flutter/model/appointment/coupon.dart';
import 'package:patient_flutter/services/api_service.dart';

class CouponSheetController extends GetxController {
  List<CouponData>? coupons;
  bool isLoading = false;

  @override
  void onInit() {
    fetchCouponApiCall();
    super.onInit();
  }

  void fetchCouponApiCall() {
    isLoading = true;
    ApiService.instance.fetchCoupons().then((value) {
      coupons = value.data;
      isLoading = false;
      update();
    });
  }
}
