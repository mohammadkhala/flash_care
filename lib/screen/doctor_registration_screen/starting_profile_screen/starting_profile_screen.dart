import 'package:doctor_flutter/common/doctor_reg_button.dart';
import 'package:doctor_flutter/common/top_bar_area.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/starting_profile_screen/starting_profile_screen_controller.dart';
import 'package:doctor_flutter/screen/doctor_registration_screen/starting_profile_screen/widget/drop_down_menu.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:doctor_flutter/utils/update_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:intl_phone_number_input_v2/intl_phone_number_input.dart';

class StartingProfileScreen extends StatelessWidget {
  final DoctorData? doctorData;

  const StartingProfileScreen({super.key, required this.doctorData});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StartingProfileScreenController(doctorData));
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TopBarArea(title: S.current.doctorRegistration),
          GetBuilder(
              init: controller,
              builder: (_) {
                return _yourName(controller);
              }),
          DoctorRegButton(onTap: controller.updateDoctor, title: S.current.continueText),
        ],
      ),
    );
  }

  Widget _yourName(StartingProfileScreenController controller) {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                S.current.selectCountry,
                style: const TextStyle(
                  fontFamily: FontRes.regular,
                  fontSize: 15,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () => controller.countryBottomSheet(controller),
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
                        style: const TextStyle(fontFamily: FontRes.bold, fontSize: 15, color: ColorRes.charcoalGrey),
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
              const SizedBox(
                height: 25,
              ),
              Text(
                S.current.selectGender,
                style: const TextStyle(
                  fontFamily: FontRes.regular,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GetBuilder<StartingProfileScreenController>(
                id: kSelectGender,
                init: controller,
                builder: (controller) => DropDownMenu(
                    items: controller.genders,
                    initialValue: controller.selectGender,
                    onChange: controller.onGenderChange),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
