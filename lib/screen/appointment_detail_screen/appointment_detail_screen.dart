import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/common/text_button_custom.dart';
import 'package:doctor_flutter/common/top_bar_area.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/appointment/appointment_request.dart';
import 'package:doctor_flutter/screen/appointment_detail_screen/appointment_detail_screen_controller.dart';
import 'package:doctor_flutter/screen/appointment_detail_screen/widget/appointment_detail_card.dart';
import 'package:doctor_flutter/screen/appointment_detail_screen/widget/attachment_card.dart';
import 'package:doctor_flutter/screen/appointment_detail_screen/widget/previous_appointment.dart';
import 'package:doctor_flutter/screen/appointment_detail_screen/widget/problem_card.dart';
import 'package:doctor_flutter/screen/request_screen/widget/request_card.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Function(AppointmentStatus status, AppointmentData? data)? onUpdate;
  final AppointmentData? appointmentData;

  const AppointmentDetailScreen(
      {super.key, this.onUpdate, this.appointmentData});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
        AppointmentDetailScreenController(onUpdate, appointmentData),
        tag: "${appointmentData?.id}");
    return Scaffold(
      backgroundColor: ColorRes.white,
      body: Obx(() {
        AppointmentData? data = controller.appointmentData.value;
        return SafeArea(
          top: false,
          child: Column(
            children: [
              TopBarArea(title: data?.appointmentNumber ?? ''),
              Expanded(
                child: controller.appointmentData.value == null
                    ? CustomUi.noData()
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UserCard(appointmentData: data, onViewTap: () {}),
                            Obx(
                              () => AppointmentDetailCard(
                                data: data,
                                isExpand: controller.isExpanded.value,
                                onExpandTap: controller.onExpandTap,
                              ),
                            ),
                            PreviousAppointment(
                                onTap: controller.onPreviousAppointmentTap,
                                title: S.current.previousAppointments,
                                description: S.current.clickToSeePreviousEtc,
                                isDescription: true),
                            ProblemCard(
                                title: S.current.problem,
                                description: data?.problem ?? ''),
                            AttachmentCard(doc: data?.documents),
                            _acceptRejectButton(controller),
                            _bottomButton(controller),
                            Visibility(
                              visible: data?.status == 2,
                              child: ProblemCard(
                                  title: S.current.diagnosedWith,
                                  description: data?.diagnosedWith ?? ''),
                            ),
                            Visibility(
                              visible: data?.status == 2,
                              child: PreviousAppointment(
                                onTap: controller.onMedicalPrescriptionTap,
                                title: S.current.medicalPrescription,
                                description: '',
                              ),
                            ),
                            const SizedBox(height: 15),
                            _ratingBarWidget(controller)
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _acceptRejectButton(AppointmentDetailScreenController controller) {
    return Obx(() {
      AppointmentData? data = controller.appointmentData.value;
      return Visibility(
        visible: data?.status == 0,
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: TextButtonCustom(
                        onPressed: () {
                          controller.onDeclineBtnTap(data);
                        },
                        title: S.current.decline,
                        titleColor: ColorRes.lightRed,
                        backgroundColor: ColorRes.pinkLace),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextButtonCustom(
                      onPressed: () => controller.onAcceptBtnTap(data),
                      title: S.current.accept,
                      titleColor: ColorRes.irishGreen,
                      backgroundColor:
                          ColorRes.irishGreen.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _bottomButton(AppointmentDetailScreenController controller) {
    return Obx(() {
      AppointmentData? data = controller.appointmentData.value;
      return Visibility(
        visible: data?.status == 1,
        child: Column(
          children: [
            const SizedBox(height: 10),
            TextButtonCustom(
                onPressed: controller.onMessageBtnTap,
                title: S.current.messages,
                titleColor: ColorRes.white,
                backgroundColor: ColorRes.havelockBlue),
            const SizedBox(height: 10),
            TextButtonCustom(
                onPressed: controller.onMedicalPrescriptionTap,
                title: S.current.medicalPrescription,
                titleColor: ColorRes.tuftsBlue,
                backgroundColor: ColorRes.whiteSmoke),
            const SizedBox(height: 10),
            TextButtonCustom(
              onPressed: () => controller.onMarkCompleteTap(controller),
              title: S.current.markCompleted,
              titleColor: ColorRes.irishGreen,
              backgroundColor: ColorRes.irishGreen.withValues(alpha: 0.12),
            ),
          ],
        ),
      );
    });
  }

  Widget _ratingBarWidget(AppointmentDetailScreenController controller) {
    return Obx(() {
      AppointmentData? data = controller.appointmentData.value;
      return Visibility(
        visible: data?.isRated == 1,
        child: Container(
          width: double.infinity,
          color: ColorRes.snowDrift,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data?.user?.fullname ?? S.current.unKnown,
                style: const TextStyle(
                    color: ColorRes.charcoalGrey,
                    fontSize: 16,
                    fontFamily: FontRes.bold),
              ),
              const SizedBox(height: 5),
              RatingBarIndicator(
                itemCount: 5,
                itemSize: 21,
                rating: data?.rating?.rating?.toDouble() ?? 0,
                itemBuilder: (context, index) {
                  return const Icon(
                    Icons.star_rate_rounded,
                    color: ColorRes.mangoOrange,
                    size: 21,
                  );
                },
              ),
              const SizedBox(height: 10),
              Text(
                data?.rating?.comment ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  color: ColorRes.battleshipGrey,
                  fontFamily: FontRes.medium,
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
