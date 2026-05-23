import 'package:get/get.dart';
import 'package:patient_flutter/model/global/fetch_faqs.dart';
import 'package:patient_flutter/services/api_service.dart';

class HelpAndFaqScreenController extends GetxController {
  int selectedCategory = 0;
  List<FetchFaqsData> faqs = [];
  bool isLoading = false;

  void onCategoryChange(int category) {
    selectedCategory = category;
    update();
  }

  @override
  void onInit() {
    fetchFaqsApiCall();
    super.onInit();
  }

  void fetchFaqsApiCall() {
    isLoading = true;
    ApiService.instance.fetchFaqCats().then((value) {
      faqs = value.data ?? [];
      isLoading = false;
      update();
    });
  }
}
