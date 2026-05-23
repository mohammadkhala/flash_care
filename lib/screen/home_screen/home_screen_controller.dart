import 'dart:convert';

import 'package:get/get.dart';
import 'package:patient_flutter/model/appointment/fetch_appointment.dart';
import 'package:patient_flutter/model/doctor/fetch_doctor.dart';
import 'package:patient_flutter/model/home/home.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/screen/doctor_profile_screen/doctor_profile_screen.dart';
import 'package:patient_flutter/screen/specialists_detail_screen/specialists_detail_screen.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/services/session_manager.dart';
import 'package:patient_flutter/utils/extention.dart';
import 'package:patient_flutter/utils/update_res.dart';

class HomeScreenController extends GetxController {
  RxBool isLoading = false.obs;

  RxList<AppointmentData> appointments = <AppointmentData>[].obs;
  Rx<UserData?> userData = Rx(null);
  RxList<Categories> doctorCategory = [Categories(id: 0, title: 'All')].obs;
  RxList<Categories> specialistCategories = <Categories>[].obs;
  RxList<DoctorData> doctors = RxList([]);
  RxList<DoctorData> tampDoctors = RxList([]);

  Rx<Categories> selectedCategoryIndex = Categories(id: 0, title: 'All').obs;

  @override
  void onInit() {
    selectedCategoryIndex.value = doctorCategory.first;
    prefData();
    fetchHomePageDataApiCall();
    super.onInit();
  }

  void prefData() async {
    userData.value = SessionManager.instance.getUser();
  }

  void fetchHomePageDataApiCall({bool resetData = false}) async {
    isLoading.value = true;
    ApiService.instance
        .fetchHomePageData(date: DateTime.now().formatDateTime(yyyyMMDd))
        .then((value) {
      if (resetData) {
        appointments.clear();
        doctorCategory.clear();
        specialistCategories.clear();
        doctors.clear();
        tampDoctors.clear();

        // add "All" again to doctorCategory
        doctorCategory.add(Categories(id: 0, title: 'All'));
      }
      if (value.status == true) {
        appointments.addAll(value.appointments ?? []);
        doctorCategory.addAll(value.categories ?? []);
        specialistCategories.addAll(value.categories ?? []);

        value.categories?.forEach((element) {
          final elementDoctors = element.doctors ?? [];
          if (elementDoctors.isNotEmpty) {
            doctors.addAll(elementDoctors);
            tampDoctors.addAll(elementDoctors);
          }
        });

        saveCategories();
        selectedCategoryIndex.value = doctorCategory.first;
      }
      isLoading.value = false;
    });
  }

  void saveCategories() {
    List<Categories> category = [];
    for (var element in doctorCategory) {
      if (element.id != 0) {
        category.add(Categories(
            id: element.id,
            title: element.title,
            image: element.image,
            isDeleted: element.isDeleted,
            createdAt: element.createdAt,
            updatedAt: element.updatedAt));
      }
    }
    String jsonString = jsonEncode(category.map((e) => e.toJson()).toList());

    SessionManager.instance.setString(key: kDoctorCategory, value: jsonString);
  }

  onSpecialistsDetailScreenNavigate(Categories? categories) {
    Get.to(() => const SpecialistsDetailScreen(), arguments: categories);
  }

  onDoctorCardTap(DoctorData? doctor) {
    Get.to(() => DoctorProfileScreen(doctorData: doctor));
  }

  void onCategoryTap(Categories index) {
    selectedCategoryIndex.value = index;
    doctors.value = [];
    for (var element in tampDoctors) {
      if (index.id == 0) {
        doctors.add(element);
      } else if (element.categoryId == index.id) {
        doctors.add(element);
      }
    }
  }
}
