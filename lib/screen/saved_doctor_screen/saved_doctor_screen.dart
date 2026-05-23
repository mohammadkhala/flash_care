import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/common/top_bar_area.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/doctor/fetch_doctor.dart';
import 'package:patient_flutter/screen/saved_doctor_screen/saved_doctor_screen_controller.dart';
import 'package:patient_flutter/screen/saved_doctor_screen/widget/appointment_shimmer.dart';
import 'package:patient_flutter/screen/saved_doctor_screen/widget/doctor_card.dart';

class SavedDoctorScreen extends StatelessWidget {
  const SavedDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SavedDoctorScreenController());

    return Scaffold(
      body: Column(
        children: [
          TopBarArea(title: S.current.savedDoctors),
          Expanded(
            child: GetBuilder(
              init: controller,
              builder: (context) {
                return controller.isLoading
                    ? const AppointmentShimmer()
                    : controller.favDoctor == null ||
                            controller.favDoctor!.isEmpty
                        ? CustomUi.noDataImage(
                            message: S.current.noSavedDoctors)
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: controller.favDoctor?.length ?? 0,
                            itemBuilder: (context, index) {
                              DoctorData? doc = controller.favDoctor?[index];
                              return DoctorCard(
                                index: index,
                                onTap: () => controller.onNavigateDoctor(doc),
                                doctorData: doc,
                                isBookMarkVisible: true,
                                isBookMark: controller.isSaved,
                                onBookMarkTap: (doctorId) {
                                  controller.onBookMarkTap(doctorId);
                                },
                              );
                            },
                          );
              },
            ),
          )
        ],
      ),
    );
  }
}
