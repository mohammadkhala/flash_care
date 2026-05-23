import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/saved_doctor_screen/widget/doctor_card.dart';
import 'package:patient_flutter/screen/specialists_detail_screen/specialists_detail_screen_controller.dart';
import 'package:patient_flutter/screen/specialists_detail_screen/widget/specialists_filter_list.dart';
import 'package:patient_flutter/screen/specialists_detail_screen/widget/specialists_top_bar.dart';
import 'package:patient_flutter/utils/color_res.dart';

class SpecialistsDetailScreen extends StatelessWidget {
  const SpecialistsDetailScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SpecialistsDetailScreenController());
    return Scaffold(
      backgroundColor: ColorRes.white,
      body: GetBuilder(
        init: controller,
        builder: (context) {
          return Column(
            children: [
              SpecialistsTopBar(
                title: controller.categories?.title ?? '',
                onTap: () => controller.onFilterTap(controller: controller),
                onCloseBtnTap: controller.onCloseTap,
              ),
              GetBuilder(
                init: controller,
                builder: (context) {
                  return SpecialistsFilterList(
                    controller: controller,
                  );
                },
              ),
              Expanded(
                child: controller.isLoading
                    ? CustomUi.loaderWidget()
                    : controller.doctorData.isEmpty
                        ? CustomUi.noDataImage(message: S.current.noDoctors)
                        : ListView.builder(
                            controller: controller.scrollController,
                            itemCount: controller.doctorData.length,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              return DoctorCard(
                                index: index,
                                isBookMarkVisible: false,
                                color: ColorRes.snowDrift,
                                onTap: () => controller.onDoctorCardTap(
                                    controller.doctorData[index]),
                                doctorData: controller.doctorData[index],
                                onBookMarkTap: (doctorId) {},
                              );
                            },
                          ),
              )
            ],
          );
        },
      ),
    );
  }
}
