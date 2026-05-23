import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/chat_widget/text_field_custom.dart';
import 'package:patient_flutter/common/drop_down_menu.dart';
import 'package:patient_flutter/common/mobile_number_box.dart';
import 'package:patient_flutter/common/text_button_custom.dart';
import 'package:patient_flutter/common/top_bar_area.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/complete_registration_screen/complete_registration_screen_controller.dart';
import 'package:patient_flutter/utils/asset_res.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';
import 'package:patient_flutter/utils/update_res.dart';

class CompleteRegistrationScreen extends StatelessWidget {
  final int screenType;

  const CompleteRegistrationScreen({super.key, required this.screenType});

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.put(CompleteRegistrationScreenController(screenType));
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TopBarArea(title: S.current.completeRegistration),
          CenterArea(controller: controller),
          SafeArea(
            top: false,
            child: TextButtonCustom(
                onPressed: controller.onSubmitBtnClick,
                title: S.current.submit,
                titleColor: ColorRes.white,
                backgroundColor: ColorRes.darkSkyBlue),
          ),
          SizedBox(height: AppBar().preferredSize.height)
        ],
      ),
    );
  }
}

class CenterArea extends StatelessWidget {
  final CompleteRegistrationScreenController controller;

  const CenterArea({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Text(
                S.of(context).mobileNumber,
                style: MyTextStyle.montserratRegular(
                    size: 15, color: ColorRes.battleshipGrey),
              ),
              const SizedBox(height: 10),
              TextFieldCustom(
                controller: controller.phoneController,
                prefixIcon: MobileNumberBox(
                  onSelectedCountry: controller.onPhoneCountrySelected,
                  selectedCountry: controller.phoneCountry,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Text(
                S.current.selectCountry,
                style: MyTextStyle.montserratRegular(
                    size: 15, color: ColorRes.battleshipGrey),
              ),
              const SizedBox(height: 10),
              GetBuilder(
                init: controller,
                builder: (_) {
                  return InkWell(
                    onTap: controller.countryBottomSheet,
                    child: Container(
                      height: 45,
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: ColorRes.whiteSmoke,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text(
                            controller.selectCountry?.countryName ?? '',
                            style: MyTextStyle.montserratBold(
                                size: 15, color: ColorRes.charcoalGrey),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: ColorRes.charcoalGrey,
                            size: 30,
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 25),
              Text(
                S.current.selectGender,
                style: MyTextStyle.montserratRegular(
                    size: 15, color: ColorRes.battleshipGrey),
              ),
              const SizedBox(height: 10),
              GetBuilder(
                init: controller,
                builder: (controller) => DropDownMenu(
                    items: controller.genders,
                    initialValue: controller.selectGender,
                    onChange: controller.onGenderChange),
              ),
              const SizedBox(height: 25),
              Text(
                S.current.dateOfBirth,
                style: MyTextStyle.montserratRegular(
                    size: 15, color: ColorRes.battleshipGrey),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => controller.selectDate(Get.context!),
                child: Container(
                  height: 47,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      color: ColorRes.whiteSmoke,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      GetBuilder(
                          id: kChangeDate,
                          init: controller,
                          builder: (context) {
                            return Expanded(
                              child: Text(
                                controller.dateController.text,
                                style: MyTextStyle.montserratBold(
                                    size: 17, color: ColorRes.charcoalGrey),
                              ),
                            );
                          }),
                      Image.asset(
                        AssetRes.calender,
                        width: 20,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
