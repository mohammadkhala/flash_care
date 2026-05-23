import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/doctor/fetch_doctor.dart';
import 'package:patient_flutter/model/home/home.dart';
import 'package:patient_flutter/screen/home_screen/home_screen.dart';
import 'package:patient_flutter/screen/home_screen/home_screen_controller.dart';
import 'package:patient_flutter/screen/saved_doctor_screen/widget/doctor_card.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class DoctorCategorySection extends StatelessWidget {
  final HomeScreenController controller;

  const DoctorCategorySection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.doctorCategory.isNotEmpty)
          HomeScreenCatHeading(title: S.of(context).doctors),
        const SizedBox(height: 10),
        if (controller.doctorCategory.isNotEmpty)
          _buildCategoryListView(controller),
        if (controller.doctors.isNotEmpty) _buildDoctorListView(controller),
        const SizedBox(height: 20),
      ],
    );
  }

  // Method to build category list
  Widget _buildCategoryListView(HomeScreenController controller) {
    return SizedBox(
      height: 39,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: controller.doctorCategory.length,
        itemBuilder: (context, index) {
          Categories category = controller.doctorCategory[index];
          return Obx(
            () => InkWell(
              onTap: () => controller.onCategoryTap(category),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 25),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: category == controller.selectedCategoryIndex.value
                      ? ColorRes.havelockBlue
                      : ColorRes.whiteSmoke,
                ),
                child: Text(
                  category.title?.capitalize ?? '',
                  style: MyTextStyle.montserratMedium(
                    size: 16,
                    color: category == controller.selectedCategoryIndex.value
                        ? ColorRes.white
                        : ColorRes.battleshipGrey,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Method to build doctor list
  Widget _buildDoctorListView(HomeScreenController controller) {
    return Obx(
      () => ListView.builder(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.zero,
        primary: false,
        shrinkWrap: true,
        itemCount: controller.doctors.length,
        itemBuilder: (context, index) {
          DoctorData doctor = controller.doctors[index];
          return DoctorCard(
              doctorData: doctor,
              index: index,
              onTap: () => controller.onDoctorCardTap(doctor),
              isBookMarkVisible: false);
        },
      ),
    );
  }
}
