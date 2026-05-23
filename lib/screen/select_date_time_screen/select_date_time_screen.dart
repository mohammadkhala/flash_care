import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/common/top_bar_area.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/appointment/fetch_appointment.dart';
import 'package:patient_flutter/model/doctor/fetch_doctor.dart';
import 'package:patient_flutter/screen/select_date_time_screen/select_date_time_screen_controller.dart';
import 'package:patient_flutter/screen/select_date_time_screen/widget/doctor_profile_card.dart';
import 'package:patient_flutter/screen/select_date_time_screen/widget/select_month_dialog.dart';
import 'package:patient_flutter/services/session_manager.dart';
import 'package:patient_flutter/utils/asset_res.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/extention.dart';
import 'package:patient_flutter/utils/font_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';
import 'package:patient_flutter/utils/update_res.dart';

class SelectDateTimeScreen extends StatelessWidget {
  final int addAppointment;

  const SelectDateTimeScreen({super.key, required this.addAppointment});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SelectDateTimeScreenController());
    return Scaffold(
      backgroundColor: ColorRes.white,
      body: Column(
        children: [
          TopBarArea(title: S.current.selectDateAndTime),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DoctorProfileCard(
                  doctor: controller.doctorData,
                ),
                _topBarTitle(
                    title: S.current.selectDate,
                    isDateVisible: true,
                    topPadding: 0,
                    controller: controller),
                DateSelector(controller: controller),
                _topBarTitle(
                  controller: controller,
                  title: S.current.selectTime,
                ),
                GetBuilder(
                  init: controller,
                  id: kSelectTime,
                  builder: (controller) {
                    if (controller.isLoadAppointment) {
                      return CustomUi.loaderWidget();
                    } else if (controller.slotTime.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: Text(
                            S.current.noSlotAvailable,
                            style: MyTextStyle.montserratBold(
                                color: ColorRes.grey, size: 12),
                          ),
                        ),
                      );
                    } else if (controller.slotTime.first.id == 0) {
                      return Center(
                        child: Text(
                          controller.slotTime.first.time ?? '',
                          style: MyTextStyle.montserratBold(
                              color: ColorRes.grey, size: 12),
                        ),
                      );
                    } else {
                      return SizedBox(
                        height: 60,
                        child: ListView.builder(
                          itemCount: controller.slotTime.length,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemBuilder: (context, index) {
                            controller.slotTime
                                .sort((a, b) => a.time!.compareTo(b.time!));
                            Slots? slot = controller.slotTime[index];

                            var bookedSlots = controller.acceptPendingData
                                .where((element) => element.time == slot.time)
                                .toList();

                            return InkWell(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                if (bookedSlots.indexWhere((element) =>
                                        element.userId ==
                                        SessionManager.instance.getUserID()) ==
                                    -1) {
                                  if ((slot.remainSlot ?? 0) <= 0) {
                                    CustomUi.snackBar(
                                      message: S.of(context).slotNotAvailable,
                                    );
                                  } else {
                                    controller.onTimeTap(slot);
                                  }
                                } else {
                                  if ((slot.remainSlot ?? 0) > 0) {
                                    CustomUi.snackBar(
                                      message: S
                                          .of(context)
                                          .youHaveAlreadyBookedThisSlot,
                                    );
                                  }
                                }
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: controller.selectedSlot == slot
                                            ? ColorRes.havelockBlue
                                            : ColorRes.softPeach,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        CustomUi.convert24HoursInto12Hours(
                                            slot.time),
                                        style: MyTextStyle.montserratSemiBold(
                                          color: (slot.remainSlot ?? 0) <= 0
                                              ? ColorRes.nobel
                                              : (controller.selectedSlot == slot
                                                  ? ColorRes.white
                                                  : ColorRes.charcoalGrey),
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      (slot.remainSlot ?? 0) <= 0
                                          ? S.of(context).notAvailable
                                          : '${slot.remainSlot ?? 0} ${S.of(context).slotsAvailable}',
                                      style: TextStyle(
                                        color: (slot.remainSlot ?? 0) <= 0
                                            ? ColorRes.nobel
                                            : ColorRes.mediumGreen,
                                        fontFamily: FontRes.medium,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
                _topBarTitle(
                  controller: controller,
                  title: S.current.appointmentType,
                ),
                GetBuilder(
                  init: controller,
                  id: kAppointmentType,
                  builder: (controller) {
                    return Row(
                      children: [
                        _appointmentTypeCard(
                            controller: controller,
                            index: 0,
                            title: S.current.online,
                            isVisible:
                                controller.doctorData?.onlineConsultation == 1
                                    ? true
                                    : false),
                        _appointmentTypeCard(
                            controller: controller,
                            index: 1,
                            title: S.current.clinic,
                            isVisible:
                                controller.doctorData?.clinicConsultation == 1
                                    ? true
                                    : false)
                      ],
                    );
                  },
                ),
                // ── Patient section ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.people_alt_outlined,
                          size: 18, color: Color(0xFF00897B)),
                      const SizedBox(width: 6),
                      Text(S.current.patient,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF1A2B3C))),
                    ],
                  ),
                ),
                GetBuilder(
                  init: controller,
                  builder: (controller) {
                    final selected = controller.selectedPatient ??
                        controller.patientList.first;
                    final isMyself = selected?.id == null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: addAppointment == 0
                            ? () => controller.showPatientSheet(context)
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white,
                            border: Border.all(
                                color: const Color(0xFF00897B)
                                    .withValues(alpha: .3)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor:
                                    const Color(0xFF00897B).withValues(alpha: .15),
                                child: Text(
                                  (selected?.fullname ?? '؟')
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                      color: Color(0xFF00897B),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selected?.fullname ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: Color(0xFF1A2B3C)),
                                    ),
                                    Text(
                                      isMyself
                                          ? 'أنت'
                                          : (selected?.relation ?? ''),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              ),
                              if (addAppointment == 0) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00897B)
                                        .withValues(alpha: .1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('تغيير',
                                          style: TextStyle(
                                              color: Color(0xFF00897B),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600)),
                                      SizedBox(width: 4),
                                      Icon(Icons.keyboard_arrow_down_rounded,
                                          color: Color(0xFF00897B), size: 18),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _topBarTitle(
                    title: S.current.explainYourProblemBriefly,
                    controller: controller),
                GetBuilder(
                  init: controller,
                  builder: (context) {
                    return Container(
                      height: 150,
                      width: double.infinity,
                      color: ColorRes.whiteSmoke,
                      child: addAppointment == 1
                          ? Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                controller.problemController.text,
                                style: MyTextStyle.montserratMedium(
                                  size: 15,
                                  color: ColorRes.battleshipGrey,
                                ),
                              ),
                            )
                          : TextField(
                              controller: controller.problemController,
                              expands: true,
                              minLines: null,
                              maxLines: null,
                              onTapOutside: (event) =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(15),
                                hintText: S.current.enterHere,
                                hintStyle: MyTextStyle.montserratMedium(
                                  size: 15,
                                  color: ColorRes.grey.withValues(alpha: 0.7),
                                ),
                              ),
                              cursorColor: ColorRes.battleshipGrey,
                              cursorHeight: 15,
                              style: MyTextStyle.montserratMedium(
                                size: 15,
                                color: ColorRes.battleshipGrey,
                              ),
                            ),
                    );
                  },
                ),
                Visibility(
                  visible: addAppointment == 1 &&
                      controller.appointmentData?.documents?.length.toInt() !=
                          0,
                  child: _topBarTitle(
                      title: S.current.attachPhoto, controller: controller),
                ),
                SizedBox(
                  height: 120,
                  child: Row(
                    children: [
                      Visibility(
                        visible: addAppointment == 0,
                        child: InkWell(
                          onTap: controller.onAttachDocument,
                          child: Container(
                            height: 100,
                            width: 100,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: ColorRes.whiteSmoke,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              AssetRes.messageAddBox,
                              color: ColorRes.darkJungleGreen,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 100,
                          child: GetBuilder(
                            id: kAttachDocument,
                            init: controller,
                            builder: (context) {
                              return addAppointment == 1
                                  ? ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: controller.appointmentData
                                              ?.documents?.length ??
                                          0,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 2),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  '${ConstRes.itemBaseURL}${controller.appointmentData?.documents?[index].image}',
                                              fit: BoxFit.cover,
                                              width: 100,
                                              height: 100,
                                              errorWidget:
                                                  (context, url, error) {
                                                return Container();
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : controller.imageFileList.isEmpty
                                      ? const SizedBox()
                                      : ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              controller.imageFileList.length,
                                          itemBuilder: (context, index) {
                                            return InkWell(
                                              onTap: () => controller
                                                  .onImageDelete(controller
                                                      .imageFileList[index]),
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 2),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: Image.file(
                                                        controller
                                                                .imageFileList[
                                                            index],
                                                        fit: BoxFit.cover,
                                                        width: 100,
                                                        height: 100,
                                                      ),
                                                    ),
                                                  ),
                                                  const Icon(
                                                    Icons.delete_rounded,
                                                    color: ColorRes.whiteSmoke,
                                                  )
                                                ],
                                              ),
                                            );
                                          },
                                        );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          )),
          InkWell(
            onTap: addAppointment == 1
                ? controller.onRescheduleTap
                : controller.onMakePaymentClick,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: const BoxDecoration(
                gradient: MyTextStyle.linearTopGradient,
              ),
              alignment: Alignment.center,
              child: SafeArea(
                top: false,
                child: Text(
                  addAppointment == 0
                      ? S.current.makePayment
                      : S.current.reschedule,
                  style: MyTextStyle.montserratSemiBold(
                      size: 17, color: ColorRes.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _topBarTitle(
      {required String title,
      bool isDateVisible = false,
      double topPadding = 10,
      double bottomPadding = 10,
      required SelectDateTimeScreenController controller}) {
    return Container(
      padding: EdgeInsets.only(
          left: 15, right: 15, top: topPadding, bottom: bottomPadding),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: MyTextStyle.montserratRegular(
                size: 15,
                color: ColorRes.battleshipGrey,
              ),
            ),
          ),
          Visibility(
            visible: isDateVisible,
            child: GetBuilder(
              id: kSelectDate,
              init: controller,
              builder: (controller) {
                return InkWell(
                  onTap: () {
                    Get.dialog(
                      SelectMonthDialog(
                          onDoneClick: controller.onDoneClick,
                          month: controller.month,
                          year: controller.year),
                    );
                  },
                  child: Text(
                    '${DateFormat(mmmm).format(DateTime(controller.year, controller.month))} ${controller.year}',
                    style: MyTextStyle.montserratSemiBold(
                      size: 15,
                      color: ColorRes.charcoalGrey,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _appointmentTypeCard(
      {required SelectDateTimeScreenController controller,
      required int index,
      required String title,
      required bool isVisible}) {
    return Visibility(
      visible: isVisible,
      child: InkWell(
        onTap: () {
          addAppointment == 0 ? controller.onAppointmentTypeTap(index) : () {};
        },
        child: Card(
          elevation: controller.selectedAppointmentType == index ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: controller.selectedAppointmentType == index
                  ? ColorRes.havelockBlue
                  : ColorRes.softPeach,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              title,
              style: MyTextStyle.montserratSemiBold(
                  color: controller.selectedAppointmentType == index
                      ? ColorRes.white
                      : ColorRes.charcoalGrey,
                  size: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class DateSelector extends StatelessWidget {
  final SelectDateTimeScreenController controller;

  const DateSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        height: 63,
        child: ListView.builder(
          controller: controller.dateController,
          itemCount: controller.days.length,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          itemBuilder: (context, index) {
            final dateKey = GlobalKey();
            DateTime time = controller.days[index];
            return Obx(
              () {
                return DateView(
                    key: dateKey,
                    onTap: () {
                      controller.onSelectedDateClick(time, index);
                    },
                    isSelected: controller.selectedDay.value
                        .isSameDate(controller.days[index]),
                    time: time);
              },
            );
          },
        ),
      ),
    );
  }
}

class DateView extends StatelessWidget {
  final VoidCallback onTap;
  final bool isSelected;
  final DateTime time;

  const DateView(
      {super.key,
      required this.onTap,
      required this.isSelected,
      required this.time});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 63,
        width: 63,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: ShapeDecoration(
            shape: SmoothRectangleBorder(
                borderRadius:
                    SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1)),
            shadows: !isSelected
                ? null
                : [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: .15),
                        blurRadius: 5.0)
                  ],
            color: isSelected ? ColorRes.havelockBlue : ColorRes.softPeach),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat.E().format(time).toUpperCase(),
              style: TextStyle(
                  color: isSelected ? ColorRes.white : ColorRes.charcoalGrey,
                  fontSize: 12,
                  fontFamily: FontRes.medium),
            ),
            const SizedBox(height: 1),
            Text(
              time.day.toString(),
              style: TextStyle(
                color: isSelected ? ColorRes.white : ColorRes.charcoalGrey,
                fontSize: 24,
                fontFamily: FontRes.semiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
