import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/common/text_button_custom.dart';
import 'package:patient_flutter/common/top_bar_area.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/appointment_chat_screen/appointment_chat_screen.dart';
import 'package:patient_flutter/screen/appointment_detail_screen/appointment_detail_screen_controller.dart';
import 'package:patient_flutter/screen/appointment_detail_screen/widget/appointment_bill_card.dart';
import 'package:patient_flutter/screen/appointment_detail_screen/widget/attachment_card.dart';
import 'package:patient_flutter/screen/appointment_detail_screen/widget/medical_prescription_card.dart';
import 'package:patient_flutter/screen/appointment_detail_screen/widget/problem_card.dart';
import 'package:patient_flutter/screen/appointment_screen/widget/qr_code_screen.dart';
import 'package:patient_flutter/screen/select_date_time_screen/widget/doctor_profile_card.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class AppointmentDetailScreen extends StatelessWidget {
  const AppointmentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppointmentDetailScreenController());

    return Scaffold(
      backgroundColor: ColorRes.white,
      body: Column(
        children: [
          GetBuilder(
            init: controller,
            builder: (context) {
              return TopBarArea(
                title: controller.appointmentData?.appointmentNumber ?? '',
                isQrCodeVisible: (controller.appointmentData?.status == 0 ||
                        controller.appointmentData?.status == 1)
                    ? true
                    : false,
                onQrCodeTap: () {
                  Get.bottomSheet(
                    QrCodeSheet(appointmentId: controller.appointmentData?.id),
                    isScrollControlled: true,
                  );
                },
              );
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: SafeArea(
                top: false,
                child: GetBuilder(
                  init: controller,
                  builder: (context) {
                    if (controller.isLoading) {
                      return CustomUi.loaderWidget();
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DoctorProfileCard(
                            isDividerVisible: false,
                            doctor: controller.appointmentData?.doctor,
                          ),
                          AppointmentBillCard(
                            appointmentData: controller.appointmentData,
                            isExpand: controller.isExpanded,
                            onExpandTap: controller.onExpandTap,
                          ),
                          ProblemCard(
                              title: S.current.yourProblem,
                              description: controller.appointmentData?.problem ?? ''),
                          if (controller.appointmentData?.documents == null ||
                              controller.appointmentData!.documents!.isEmpty)
                            const SizedBox()
                          else
                            AttachmentCard(doc: controller.appointmentData?.documents),
                          Visibility(
                            visible: controller.appointmentData?.status == 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ProblemCard(
                                    title: S.current.diagnosedWith,
                                    description: controller.appointmentData?.diagnosedWith ?? ''),
                                if (controller.appointmentData?.prescription == null)
                                  const SizedBox()
                                else
                                  MedicalPrescriptionCard(
                                      appointmentData: controller.appointmentData),
                                Visibility(
                                  visible: controller.appointmentData?.isRated == 1,
                                  child: Container(
                                    width: double.infinity,
                                    color: ColorRes.snowDrift,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(15),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(S.current.yourReview,
                                            style: MyTextStyle.montserratBold(
                                                color: ColorRes.charcoalGrey)),
                                        const SizedBox(height: 5),
                                        CustomUi.ratingIndicator(
                                            rating: controller.appointmentData?.rating?.rating
                                                    ?.toDouble() ??
                                                0,
                                            ratingSize: 21),
                                        const SizedBox(height: 10),
                                        Text(controller.appointmentData?.rating?.comment ?? '',
                                            style: MyTextStyle.montserratMedium(
                                                size: 15, color: ColorRes.battleshipGrey))
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          GetBuilder(
                              init: controller,
                              builder: (context) {
                                return Visibility(
                                  visible: controller.appointmentData?.status == 0,
                                  child: Container(
                                    margin: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextButtonCustom(
                                              onPressed: () => controller
                                                  .onRescheduleTap(controller.appointmentData),
                                              title: S.current.reschedule,
                                              titleColor: ColorRes.irishGreen,
                                              backgroundColor:
                                                  ColorRes.irishGreen.withValues(alpha: 0.2)),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: TextButtonCustom(
                                              onPressed: () => controller
                                                  .onCancelBtnClick(controller.appointmentData),
                                              title: S.current.cancel,
                                              titleColor: ColorRes.bittersweet,
                                              backgroundColor:
                                                  ColorRes.bittersweet.withValues(alpha: 0.2)),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                          Visibility(
                            visible: controller.appointmentData?.status == 1,
                            child: SafeArea(
                              top: false,
                              child: TextButtonCustom(
                                  onPressed: () {
                                    Get.to(() => const AppointmentChatScreen(),
                                        arguments: controller.appointmentData);
                                  },
                                  title: S.current.messages,
                                  titleColor: ColorRes.white,
                                  backgroundColor: ColorRes.darkSkyBlue),
                            ),
                          ),
                          Visibility(
                            visible: controller.appointmentData?.status == 1,
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(vertical: 15),
                              color: ColorRes.whiteSmoke,
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      text: '${S.current.completionOTP} : ',
                                      style: MyTextStyle.montserratMedium(
                                          color: ColorRes.battleshipGrey, size: 15),
                                      children: [
                                        TextSpan(
                                          text:
                                              '${controller.appointmentData?.completionOtp ?? ''}',
                                          style: MyTextStyle.montserratSemiBold(
                                            size: 16,
                                            color: ColorRes.charcoalGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    S.current.pleaseProvideThisOTPEtc,
                                    style: MyTextStyle.montserratRegular(
                                        color: ColorRes.battleshipGrey, size: 15),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          GetBuilder(
            init: controller,
            builder: (context) {
              return Visibility(
                visible: controller.appointmentData?.status == 2 &&
                    controller.appointmentData?.isRated == 0,
                child: InkWell(
                  onTap: () => controller.onRatingTap(controller),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    color: ColorRes.mangoOrange,
                    alignment: Alignment.center,
                    child: SafeArea(
                      top: false,
                      child: Text(
                        S.current.rateYourExperience,
                        style: MyTextStyle.montserratSemiBold(size: 17, color: ColorRes.white),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
