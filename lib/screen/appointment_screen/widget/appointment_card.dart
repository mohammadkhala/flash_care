import 'dart:ui';

import 'package:doctor_flutter/common/common_fun.dart';
import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/common/image_builder_custom.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/appointment/appointment_request.dart';
import 'package:doctor_flutter/screen/appointment_detail_screen/appointment_detail_screen.dart';
import 'package:doctor_flutter/screen/appointment_screen/appointment_screen_controller.dart';
import 'package:doctor_flutter/screen/appointment_screen/widget/appointment_shimmer.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentScreenController controller;

  const AppointmentCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(
        () => controller.isLoading.value && controller.filterAppointment.isEmpty
            ? const AppointmentShimmer()
            : controller.filterAppointment.isEmpty
                ? CustomUi.noDataImage(message: S.of(context).noAppointments)
                : ListView.builder(
                    itemCount: controller.filterAppointment.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      AppointmentData? appointmentData =
                          controller.filterAppointment[index];
                      return InkWell(
                        onTap: () {
                          CommonFun.doctorBanned(() {
                            Get.to(() => AppointmentDetailScreen(
                                appointmentData: appointmentData));
                          });
                        },
                        child: AspectRatio(
                          aspectRatio: 1 / 0.27,
                          child: Container(
                            padding: const EdgeInsets.only(
                                top: 5, left: 8, right: 8, bottom: 7),
                            margin: const EdgeInsets.symmetric(vertical: 3),
                            decoration: BoxDecoration(
                                color: ColorRes.whiteSmoke,
                                borderRadius: BorderRadius.circular(15)),
                            child: Row(
                              children: [
                                AspectRatio(
                                  aspectRatio: 0.95,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        AspectRatio(
                                          aspectRatio: .95,
                                          child: ImageBuilderCustom(
                                              appointmentData
                                                  .user?.profileImage,
                                              size: 95,
                                              radius: 15,
                                              name: appointmentData
                                                  .user?.fullname),
                                        ),
                                        ClipRect(
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaY: 10, sigmaX: 10),
                                            child: Container(
                                              height: 28,
                                              alignment: Alignment.center,
                                              color: ColorRes.black
                                                  .withValues(alpha: 0.3),
                                              child: Text(
                                                  CommonFun
                                                      .convert24HoursInto12Hours(
                                                          appointmentData.time),
                                                  style: const TextStyle(
                                                      color: ColorRes.white,
                                                      fontFamily:
                                                          FontRes.semiBold,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                  maxLines: 1),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        appointmentData.user?.fullname ??
                                            S.current.unKnown,
                                        style: const TextStyle(
                                            color: ColorRes.charcoalGrey,
                                            fontFamily: FontRes.extraBold,
                                            fontSize: 18,
                                            overflow: TextOverflow.ellipsis),
                                        maxLines: 1,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "${appointmentData.user?.dob == null ? '0' : CommonFun.calculateAge(appointmentData.user?.dob ?? '2001-01-02')} ${S.current.years}: ${appointmentData.user?.gender == 1 ? S.current.male : S.current.feMale}",
                                        style: const TextStyle(
                                            fontFamily: FontRes.medium,
                                            color: ColorRes.battleshipGrey,
                                            fontSize: 14.5,
                                            overflow: TextOverflow.ellipsis),
                                      )
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    String? number = appointmentData
                                        .user?.phoneNumber
                                        ?.split(' ')[0];
                                    if (number == null || number.isEmpty) {
                                      return CustomUi.snackBar(
                                        message:
                                            S.of(context).mobileNumberNotFound,
                                      );
                                    }
                                    CommonFun.doctorBanned(() {
                                      launchUrl(Uri.parse('tel:$number'));
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: ColorRes.greenWhite,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      S.current.callNow,
                                      style: const TextStyle(
                                        color: ColorRes.tuftsBlue,
                                        fontFamily: FontRes.semiBold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
