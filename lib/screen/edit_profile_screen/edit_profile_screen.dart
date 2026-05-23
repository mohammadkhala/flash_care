import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/chat_widget/text_field_custom.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/common/drop_down_menu.dart';
import 'package:patient_flutter/common/mobile_number_box.dart';
import 'package:patient_flutter/common/text_button_custom.dart';
import 'package:patient_flutter/common/top_bar_area.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/edit_profile_screen/edit_profile_screen_controller.dart';
import 'package:patient_flutter/utils/asset_res.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditProfileScreenController());
    return Scaffold(
      backgroundColor: ColorRes.white,
      body: GetBuilder(
        init: controller,
        builder: (_) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopBarArea(title: S.current.editProfile),
              Expanded(
                  child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileView(controller: controller),
                      EditProfileHeadingWidget(heading: S.current.yourFullname),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                            color: ColorRes.silverChalice.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: controller.fullNameController,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 15),
                            border: InputBorder.none,
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          style: MyTextStyle.montserratBold(size: 17, color: ColorRes.charcoalGrey),
                          cursorColor: ColorRes.charcoalGrey,
                          cursorHeight: 17,
                          onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                        ),
                      ),
                      EditProfileHeadingWidget(heading: S.current.mobileNumber),
                      if (controller.selectCountry != null)
                        TextFieldCustom(
                          controller: controller.phoneNumberController,
                          prefixIcon: MobileNumberBox(
                            onSelectedCountry: controller.onSelectedCountry,
                            selectedCountry: controller.phoneCountry,
                          ),
                        ),
                      EditProfileHeadingWidget(heading: S.current.selectCountry),
                      InkWell(
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
                      ),
                      EditProfileHeadingWidget(heading: S.current.gender),
                      DropDownMenu(
                          items: controller.genders,
                          initialValue: controller.selectGender,
                          onChange: controller.onGenderChange),
                      EditProfileHeadingWidget(heading: S.current.dateOfBirth),
                      InkWell(
                        onTap: () => controller.selectDate(context),
                        child: Container(
                          height: 47,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              color: ColorRes.whiteSmoke, borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  controller.dateController.text,
                                  style: MyTextStyle.montserratBold(
                                      size: 17, color: ColorRes.charcoalGrey),
                                ),
                              ),
                              Image.asset(
                                AssetRes.calender,
                                width: 20,
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              )),
              SafeArea(
                top: false,
                child: TextButtonCustom(
                    onPressed: controller.onContinueTap,
                    title: S.current.continueText,
                    titleColor: ColorRes.white,
                    backgroundColor: ColorRes.darkSkyBlue,
                    bottomMargin: 10),
              )
            ],
          );
        },
      ),
    );
  }
}

class ProfileView extends StatelessWidget {
  final EditProfileScreenController controller;

  const ProfileView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
      child: InkWell(
        onTap: controller.onImageTap,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: controller.imageFile != null
                  ? Image.file(
                      controller.imageFile!,
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    )
                  : controller.userData?.profileImage != null
                      ? CachedNetworkImage(
                          imageUrl: '${ConstRes.itemBaseURL}${controller.userData?.profileImage}',
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) {
                            return CustomUi.doctorPlaceHolder(gender: controller.userData?.gender);
                          },
                        )
                      : CustomUi.userPlaceHolder(
                          height: 120,
                          gender: controller.userData?.gender ?? 0,
                        ),
            ),
            Container(
              height: 28,
              width: 28,
              margin: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: ColorRes.charcoalGrey,
                shape: BoxShape.circle,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    child: Image.asset(
                      AssetRes.messageEditBox,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class EditProfileHeadingWidget extends StatelessWidget {
  final String heading;

  const EditProfileHeadingWidget({super.key, required this.heading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text(heading,
          style: MyTextStyle.montserratRegular(size: 15, color: ColorRes.battleshipGrey)),
    );
  }
}
