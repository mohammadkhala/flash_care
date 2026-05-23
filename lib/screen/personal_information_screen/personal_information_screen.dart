import 'dart:typed_data';
import 'dart:ui';

import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/common/doctor_profile_text_filed.dart';
import 'package:doctor_flutter/common/doctor_reg_button.dart';
import 'package:doctor_flutter/common/image_builder_custom.dart';
import 'package:doctor_flutter/common/mobile_number_box.dart';
import 'package:doctor_flutter/common/top_bar_area.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/screen/personal_information_screen/personal_information_screen_controller.dart';
import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PersonalInformationScreenController());
    return Scaffold(
      backgroundColor: ColorRes.white,
      body: Column(
        children: [
          TopBarArea(title: S.current.personalInformation),
          const SizedBox(height: 5),
          Expanded(
            child: GetBuilder(
              init: controller,
              builder: (controller) {
                if (controller.isLoading) {
                  return CustomUi.loaderWidget();
                }
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      _buildProfileSection(controller),
                      _buildTextWithPadding(S.current.phoneNumber),
                      _buildPhoneNumberField(controller),
                      ..._buildDoctorProfileFields(controller),
                    ],
                  ),
                );
              },
            ),
          ),
          DoctorRegButton(
            onTap: controller.updateDoctor,
            title: S.current.continueText,
          ),
        ],
      ),
    );
  }

  // Helper Widgets and Functions
  Widget _buildProfileSection(PersonalInformationScreenController controller) {
    return Container(
      color: ColorRes.whiteSmoke,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          InkWell(
            onTap: controller.onImagePick,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: GetBuilder(
                    init: controller,
                    builder: (context) {
                      if (controller.profileImage != null) {
                        return FutureBuilder<Uint8List>(
                          future: controller.profileImage!.readAsBytes(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Image.memory(snapshot.data!,
                                  width: 100, height: 100, fit: BoxFit.cover);
                            }
                            return const CircularProgressIndicator();
                          },
                        );
                      }
                      if (controller.netWorkProfileImage != null) {
                        return ImageBuilderCustom(
                          controller.netWorkProfileImage,
                          size: 100,
                          name: controller.doctorData?.name,
                          radius: 20,
                        );
                      }
                      return CustomUi.userPlaceHolder(
                        male: controller.doctorData?.gender ?? 0,
                        height: 100,
                      );
                    },
                  ),
                ),
                _buildEditOverlay(),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.nameController.text,
                  style: const TextStyle(
                    fontFamily: FontRes.extraBold,
                    fontSize: 19,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Image.asset(AssetRes.stethoscope, width: 18, height: 18),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        controller.designationController.text,
                        style: const TextStyle(
                          color: ColorRes.havelockBlue,
                          fontSize: 15,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  controller.degreeController.text,
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: ColorRes.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditOverlay() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
        child: Container(
          height: 40,
          width: 40,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ColorRes.charcoalGrey.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: Image.asset(AssetRes.messageEditBox),
        ),
      ),
    );
  }

  Widget _buildTextWithPadding(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: FontRes.semiBold,
          color: ColorRes.charcoalGrey,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField(
      PersonalInformationScreenController controller) {
    return GetBuilder(
      init: controller,
      builder: (context) {
        return Container(
          height: 48,
          decoration: const BoxDecoration(color: ColorRes.aquaHaze),
          child: TextField(
            controller: controller.phoneNumberEditController,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              prefixIcon: MobileNumberBox(
                onSelectedCountry: controller.onSelectedCountry,
                isRadius: false,
                selectedCountry: controller.selectCountry,
              ),
            ),
            textAlignVertical: TextAlignVertical.center,
            cursorColor: ColorRes.darkJungleGreen,
            keyboardType: TextInputType.number,
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            style: const TextStyle(
              fontFamily: FontRes.bold,
              fontSize: 15,
              color: ColorRes.charcoalGrey,
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildDoctorProfileFields(
      PersonalInformationScreenController controller) {
    return [
      DoctorProfileTextField(
        isExample: false,
        title: S.current.yourName,
        exampleTitle: "",
        onChange: controller.onNameChange,
        textFieldColor: ColorRes.mediumGrey,
        textFieldFontFamily: FontRes.medium,
        hintTitle: S.current.enterYourName,
        controller: controller.nameController,
        focusNode: controller.nameFocusNode,
      ),
      DoctorProfileTextField(
        isExample: false,
        title: S.current.designationEtc,
        exampleTitle: "",
        onChange: controller.onDesignationChange,
        textFieldColor: ColorRes.mediumGrey,
        textFieldFontFamily: FontRes.medium,
        hintTitle: S.current.enterDesignation,
        controller: controller.designationController,
        focusNode: controller.designationFocusNode,
      ),
      DoctorProfileTextField(
          title: S.current.enterYourDegreesEtc,
          exampleTitle: S.current.exampleMsEtc,
          onChange: controller.onDegreeChange,
          hintTitle: S.current.enterDesignation,
          textFieldColor: ColorRes.mediumGrey,
          textFieldFontFamily: FontRes.medium,
          controller: controller.degreeController,
          focusNode: controller.degreeFocusNode,
          textFieldHeight: 100,
          isExpand: true,
          textInputType: TextInputType.multiline),
      DoctorProfileTextField(
        title: S.current.languagesYouSpeakEtc,
        exampleTitle: S.current.exampleLanguage,
        hintTitle: S.current.enterLanguages,
        textFieldColor: ColorRes.mediumGrey,
        textFieldFontFamily: FontRes.medium,
        controller: controller.languageController,
        focusNode: controller.languageFocusNode,
      ),
      DoctorProfileTextField(
        title: S.current.yearsOfExperience,
        isExample: false,
        exampleTitle: "",
        textFieldColor: ColorRes.mediumGrey,
        textFieldFontFamily: FontRes.medium,
        hintTitle: S.current.numberOfYears,
        controller: controller.yearController,
        textInputType: TextInputType.number,
        focusNode: controller.yearFocusNode,
      ),
      DoctorProfileTextField(
        title: S.current.consultationFee,
        exampleTitle: S.current.youCanChangeThisEtc,
        hintTitle: '00',
        textFieldColor: ColorRes.mediumGrey,
        textFieldFontFamily: FontRes.medium,
        controller: controller.feesController,
        textInputType: TextInputType.number,
        focusNode: controller.feesFocusNode,
        isDollar: true,
      ),
    ];
  }
}
