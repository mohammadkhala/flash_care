import 'package:get/get.dart';
import 'package:patient_flutter/model/home/home.dart';
import 'package:patient_flutter/services/api_service.dart';

class SpecialistsScreenController extends GetxController {
  bool isLoading = false;
  List<Categories> categories = [];

  @override
  void onInit() {
    fetchHomePageDataApiCall();
    super.onInit();
  }

  void fetchHomePageDataApiCall() async {
    isLoading = true;
    ApiService.instance.fetchHomePageData().then((value) {
      categories.addAll(value.categories ?? []);
      isLoading = false;
      update();
    });
  }
}
