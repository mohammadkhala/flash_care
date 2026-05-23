import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/common/top_bar_area.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/appointment/fetch_appointment.dart';
import 'package:patient_flutter/screen/manage_patient_screen/manage_patient_screen_controller.dart';
import 'package:patient_flutter/screen/manage_patient_screen/widget/pop_up_menu_custom.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';
import 'package:patient_flutter/utils/update_res.dart';

class ManagePatientScreen extends StatelessWidget {
  const ManagePatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManagePatientScreenController());
    return Scaffold(
      backgroundColor: ColorRes.white,
      body: Column(
        children: [
          TopBarArea(title: S.current.patient),
          const SizedBox(
            height: 2,
          ),
          GetBuilder(
            init: controller,
            builder: (context) {
              return Container(
                width: double.infinity,
                color: ColorRes.whiteSmoke,
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.all(15),
                child: _userCard(controller.userData?.fullname ?? S.current.unKnown, mySelf),
              );
            },
          ),
          GetBuilder(
            id: kManagePatient,
            init: controller,
            builder: (context) {
              return Expanded(
                child: controller.isLoading
                    ? CustomUi.loaderWidget()
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: controller.patients.length,
                        itemBuilder: (context, index) {
                          Patient? patients = controller.patients[index];
                          return Container(
                            color: ColorRes.whiteSmoke,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              children: [
                                _userCard(patients.fullname ?? S.current.unKnown, patients.relation ?? ''),
                                const Spacer(),
                                PopUpMenuCustom(
                                  onSelectedChange: (value) {
                                    controller.onSelectedValue(value, controller, patients);
                                  },
                                )
                              ],
                            ),
                          );
                        },
                      ),
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.addNewPatient(controller),
        backgroundColor: ColorRes.darkSkyBlue,
        child: const Icon(
          Icons.add_rounded,
          color: ColorRes.white,
          size: 30,
        ),
      ),
    );
  }

  Widget _userCard(String? fullName, String? relation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fullName ?? '',
          style: MyTextStyle.montserratSemiBold(size: 14, color: ColorRes.davyGrey),
        ),
        const SizedBox(
          height: 2,
        ),
        Text(
          relation ?? '',
          style: MyTextStyle.montserratRegular(size: 13, color: ColorRes.davyGrey),
        ),
      ],
    );
  }
}
