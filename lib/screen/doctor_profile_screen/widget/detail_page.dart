import 'package:flutter/material.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/doctor/fetch_doctor.dart';
import 'package:patient_flutter/screen/doctor_profile_screen/doctor_profile_screen_controller.dart';
import 'package:patient_flutter/screen/doctor_profile_screen/widget/languages.dart';
import 'package:patient_flutter/screen/doctor_profile_screen/widget/service_location.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/font_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class DetailPage extends StatelessWidget {
  final DoctorProfileScreenController controller;

  const DetailPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (controller.doctorData?.aboutYouself != null &&
            controller.doctorData!.aboutYouself!.isNotEmpty)
          AboutDr(doctorData: controller.doctorData),
        if (controller.doctorData?.languagesSpoken != null &&
            controller.doctorData!.languagesSpoken!.isNotEmpty)
          Languages(doctorData: controller.doctorData),
        Expertise(
          title: S.current.services,
          showMore: controller.isServiceShowMore,
          onTap: controller.onServicesShowMoreTap,
          services: controller.doctorData?.services,
          noData: S.current.noServiceAvailable,
        ),
        const SizedBox(height: 10),
        Expertise(
          title: S.current.expertise,
          showMore: controller.isExpertiseShowMore,
          onTap: controller.onExpertiseShowMoreTap,
          services: controller.doctorData?.expertise,
          noData: S.current.noExpertiseAvailable,
        ),
        const SizedBox(height: 10),
        ServiceLocation(controller: controller),
        const SizedBox(height: 10),
      ],
    );
  }
}

class AboutDr extends StatelessWidget {
  final DoctorData? doctorData;

  const AboutDr({super.key, this.doctorData});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorRes.snowDrift,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          Text(
            S.current.aboutDr,
            style: MyTextStyle.montserratSemiBold(
                    size: 13, color: ColorRes.charcoalGrey)
                .copyWith(letterSpacing: 0.5),
          ),
          const SizedBox(height: 10),
          Text(
            doctorData?.aboutYouself ?? '',
            style: MyTextStyle.montserratRegular(
                color: ColorRes.battleshipGrey, size: 15),
          ),
        ],
      ),
    );
  }
}

class Expertise extends StatelessWidget {
  final String title;
  final bool showMore;
  final VoidCallback onTap;
  final List<Services>? services;
  final String noData;

  const Expertise({
    super.key,
    required this.title,
    required this.showMore,
    required this.onTap,
    this.services,
    required this.noData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorRes.snowDrift,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 5,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text(
              title,
              style: MyTextStyle.montserratSemiBold(
                      size: 14, color: ColorRes.charcoalGrey)
                  .copyWith(letterSpacing: 1),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          _textCard(noData),
          const SizedBox(
            height: 10,
          ),
          Visibility(
            visible: (services?.length ?? 0) > 4 ? true : false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: InkWell(
                onTap: onTap,
                child: Text(
                  !showMore
                      ? S.current.less
                      : "+${(services?.length ?? 0) - 4} ${S.current.more}",
                  style: const TextStyle(
                      fontFamily: FontRes.semiBold,
                      fontSize: 15,
                      color: ColorRes.havelockBlue),
                ),
              ),
            ),
          ),
          Visibility(
            visible: (services?.length ?? 0) > 4 ? true : false,
            child: const SizedBox(
              height: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _textCard(String noData) {
    return services == null || services!.isEmpty
        ? CustomUi.noData(title: noData)
        : ListView.builder(
            primary: false,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount:
                showMore && (services?.length ?? 0) > 4 ? 4 : services?.length,
            itemBuilder: (context, index) {
              Services? service = services?[index];
              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                  color:
                      index % 2 == 0 ? ColorRes.whiteSmoke : ColorRes.snowDrift,
                ),
                child: Text(
                  service?.title ?? '',
                ),
              );
            },
          );
  }
}
