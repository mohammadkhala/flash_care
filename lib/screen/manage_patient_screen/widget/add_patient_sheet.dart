import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/close_button_custom.dart';
import 'package:patient_flutter/common/drop_down_menu.dart';
import 'package:patient_flutter/common/patient_text_filed.dart';
import 'package:patient_flutter/common/text_button_custom.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/manage_patient_screen/manage_patient_screen_controller.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class AddPatientSheet extends StatelessWidget {
  final ManagePatientScreenController controller;
  final VoidCallback onContinueTap;
  final int screenType;

  const AddPatientSheet(
      {super.key,
      required this.controller,
      required this.onContinueTap,
      required this.screenType});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: ColorRes.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      padding: const EdgeInsets.only(left: 15, right: 15, top: 25, bottom: 10),
      margin: EdgeInsets.only(top: AppBar().preferredSize.height * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  screenType == 0
                      ? S.current.addPatient
                      : S.current.editPatient,
                  style: MyTextStyle.montserratExtraBold(
                      size: 20, color: ColorRes.charcoalGrey),
                ),
              ),
              const CloseButtonCustom(),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: controller.pickImage,
                    child: SizedBox(
                      height: 120,
                      width: 120,
                      child: DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          radius: const Radius.circular(30),
                          strokeWidth: 2,
                          dashPattern: const [5, 3],
                          color: ColorRes.nobel,
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(30),
                          ),
                          child: Stack(
                            children: [
                              GetBuilder(
                                init: controller,
                                builder: (context) {
                                  return controller.imageFile != null
                                      ? Image.file(
                                          controller.imageFile!,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : controller.networkImage != null
                                          ? CachedNetworkImage(
                                              imageUrl:
                                                  '${ConstRes.itemBaseURL}${controller.networkImage}',
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                              errorWidget:
                                                  (context, url, error) {
                                                return Container();
                                              },
                                            )
                                          : Container(
                                              width: 140,
                                              height: 140,
                                              color: ColorRes.softPeach,
                                            );
                                },
                              ),
                              const Center(
                                child: Icon(
                                  Icons.add_circle,
                                  color: ColorRes.nobel,
                                  size: 35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GetBuilder(
                      init: controller,
                      builder: (context) {
                        return PatientTextField(
                            title: S.current.fullName,
                            exampleTitle: "",
                            hintTitle: "",
                            isValid: controller.isFullName,
                            controller: controller.fullNameController,
                            titleTextStyle: MyTextStyle.montserratRegular(
                                size: 15, color: ColorRes.darkJungleGreen));
                      }),
                  GetBuilder(
                      init: controller,
                      builder: (context) {
                        return PatientTextField(
                            title: S.current.age,
                            exampleTitle: "",
                            hintTitle: "",
                            isValid: controller.isAge,
                            textInputType: TextInputType.number,
                            controller: controller.ageController,
                            titleTextStyle: MyTextStyle.montserratRegular(
                                size: 15, color: ColorRes.darkJungleGreen));
                      }),
                  GetBuilder(
                      init: controller,
                      builder: (context) {
                        return _genderTab();
                      }),
                  GetBuilder(
                      init: controller,
                      builder: (context) {
                        return PatientTextField(
                          title: S.current.relation,
                          exampleTitle: "",
                          hintTitle: "",
                          controller: controller.relationController,
                          isValid: controller.isRelation,
                          titleTextStyle: MyTextStyle.montserratRegular(
                            size: 15,
                            color: ColorRes.darkJungleGreen,
                          ),
                        );
                      }),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: TextButtonCustom(
              onPressed: onContinueTap,
              title: screenType == 0 ? S.current.continueText : S.current.edit,
              titleColor: ColorRes.white,
              backgroundColor: ColorRes.darkSkyBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderTab() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.current.gender,
            style: MyTextStyle.montserratRegular(
                size: 15, color: ColorRes.darkJungleGreen),
          ),
          const SizedBox(
            height: 10,
          ),
          GetBuilder(
            init: controller,
            builder: (controller) => DropDownMenu(
                items: controller.genders,
                initialValue: controller.selectGender,
                onChange: controller.onGenderChange),
          ),
        ],
      ),
    );
  }
}
