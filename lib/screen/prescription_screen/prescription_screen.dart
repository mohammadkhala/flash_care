import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/top_bar_area.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/appointment/fetch_appointment.dart';
import 'package:patient_flutter/model/appointment/prescription.dart';
import 'package:patient_flutter/screen/medical_prescription_screen/medical_prescription_screen.dart';
import 'package:patient_flutter/screen/prescription_screen/prescription_screen_controller.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/extention.dart';
import 'package:patient_flutter/utils/my_text_style.dart';
import 'package:patient_flutter/utils/update_res.dart';

class PrescriptionScreen extends StatelessWidget {
  const PrescriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrescriptionScreenController());
    return Scaffold(
      backgroundColor: ColorRes.white,
      body: Column(
        children: [
          TopBarArea(title: S.current.prescriptions),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GetBuilder(
                    init: controller,
                    builder: (controller) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(color: ColorRes.whiteSmoke, borderRadius: BorderRadius.circular(0)),
                        child: DropdownButton<Patient?>(
                          value: controller.selectedPrescription,
                          isExpanded: true,
                          alignment: Alignment.center,
                          onChanged: controller.onPatientChange,
                          iconEnabledColor: ColorRes.charcoalGrey,
                          iconSize: 30,
                          items: controller.list
                              .map<DropdownMenuItem<Patient?>>((Patient? value) => DropdownMenuItem<Patient>(
                                    value: value,
                                    child: Text(
                                      value?.fullname ?? '',
                                      style: MyTextStyle.montserratBold(size: 15, color: ColorRes.charcoalGrey),
                                    ),
                                  ))
                              .toList(),
                          underline: const SizedBox(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GetBuilder(
                    init: controller,
                    builder: (context) {
                      return ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        padding: EdgeInsets.zero,
                        itemCount: controller.prescriptionData?.length ?? 0,
                        itemBuilder: (context, index) {
                          PrescriptionData? data = controller.prescriptionData?[index];
                          return InkWell(
                            onTap: () {
                              Get.to(() => const MedicalPrescriptionScreen(), arguments: [
                                data?.medicine,
                                data?.appointment,
                                data?.user,
                              ]);
                            },
                            child: Container(
                              color: ColorRes.snowDrift,
                              padding: const EdgeInsets.all(15),
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data?.user?.fullname ?? S.current.unKnown,
                                          style: MyTextStyle.montserratSemiBold(color: ColorRes.charcoalGrey, size: 15),
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        Text(
                                          data?.appointment?.doctor?.name ?? '${S.current.dr} ${S.current.unKnown}',
                                          style: MyTextStyle.montserratRegular(size: 13, color: ColorRes.tuftsBlue),
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        Text(
                                          (data?.createdAt ?? createdDate).dateParse(ddMmmYyyyEeeHhMmA),
                                          style: MyTextStyle.montserratMedium(size: 13, color: ColorRes.battleshipGrey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: ColorRes.tuftsBlue,
                                    size: 20,
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
