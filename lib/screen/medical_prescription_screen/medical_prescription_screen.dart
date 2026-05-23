import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctor_flutter/common/common_fun.dart';
import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/common/doctor_reg_button.dart';
import 'package:doctor_flutter/common/top_bar_area.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/appointment/appointment_request.dart';
import 'package:doctor_flutter/model/medical_prescription.dart';
import 'package:doctor_flutter/screen/medical_prescription_screen/medical_prescription_screen_controller.dart';
import 'package:doctor_flutter/screen/medical_prescription_screen/widget/add_home_exercise_sheet.dart';
import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MedicalPrescriptionScreen extends StatelessWidget {
  final AppointmentData? appointmentData;

  const MedicalPrescriptionScreen({super.key, this.appointmentData});

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.put(MedicalPrescriptionScreenController(appointmentData));
    return Scaffold(
      backgroundColor: ColorRes.white,
      body: Column(
        children: [
          TopBarArea(title: S.current.medicalPrescription),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _simpleText(
                      title: S.current.createPrescriptionFor,
                      fontFamily: FontRes.regular),
                  Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                        color: ColorRes.whiteSmoke,
                        borderRadius: BorderRadius.circular(15)),
                    child: GetBuilder(
                        init: controller,
                        builder: (context) {
                          return Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      '${ConstRes.itemBaseURL}${controller.appointmentData?.patientId == null ? controller.appointmentData?.user?.profileImage : controller.appointmentData?.patient?.image}',
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, error, stackTrace) {
                                    return CustomUi.userPlaceHolder(
                                        male: controller.appointmentData?.user
                                                ?.gender ??
                                            0,
                                        height: 70);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (controller.appointmentData?.patientId ==
                                                  null
                                              ? controller.appointmentData?.user
                                                  ?.fullname
                                              : controller.appointmentData
                                                  ?.patient?.fullname) ??
                                          S.current.unKnown,
                                      style: const TextStyle(
                                        color: ColorRes.charcoalGrey,
                                        fontFamily: FontRes.extraBold,
                                        fontSize: 18,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      ageAndGenderFormat(
                                          controller.appointmentData),
                                      style: const TextStyle(
                                        color: ColorRes.battleshipGrey,
                                        fontFamily: FontRes.medium,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // ── الأدوية ───────────────────────────────────────────
                  GetBuilder(
                    init: controller,
                    builder: (context) {
                      return controller.medicines.isEmpty
                          ? const SizedBox()
                          : ListView.builder(
                              itemCount: controller.medicines.length,
                              primary: false,
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                AddMedicine addMedicine =
                                    controller.medicines[index];
                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  color: index % 2 == 0
                                      ? ColorRes.whiteSmoke
                                      : ColorRes.snowDrift,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              addMedicine.title ?? '',
                                              style: const TextStyle(
                                                  fontFamily: FontRes.semiBold,
                                                  color: ColorRes.charcoalGrey,
                                                  fontSize: 15),
                                            ),
                                            const SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              addMedicine.mealTime == 0
                                                  ? S.current.afterMeal
                                                  : S.current.beforeMeal,
                                              style: const TextStyle(
                                                  fontFamily: FontRes.semiBold,
                                                  color:
                                                      ColorRes.battleshipGrey,
                                                  fontSize: 13),
                                            ),
                                            const SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              addMedicine.dosage ?? '',
                                              style: const TextStyle(
                                                  color:
                                                      ColorRes.battleshipGrey,
                                                  fontSize: 13),
                                            ),
                                            const SizedBox(
                                              height: 7,
                                            ),
                                            Visibility(
                                              visible:
                                                  addMedicine.notes!.isEmpty
                                                      ? false
                                                      : true,
                                              child: Text(
                                                '${S.current.notes} :- ${addMedicine.notes ?? ''}',
                                                style: const TextStyle(
                                                    color: ColorRes.tuftsBlue,
                                                    fontSize: 13),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '${addMedicine.quantity ?? ''}',
                                            style: const TextStyle(
                                                fontFamily: FontRes.bold,
                                                color: ColorRes.charcoalGrey,
                                                fontSize: 24),
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          PopupMenuButton(
                                            initialValue:
                                                controller.initialValue,
                                            padding: const EdgeInsets.all(0),
                                            icon: Image.asset(
                                              AssetRes.icMore,
                                              width: 20,
                                              color: ColorRes.tuftsBlue,
                                            ),
                                            onSelected: (value) {
                                              if (value == 0) {
                                                controller.onMedicineEdit(
                                                    addMedicine, controller);
                                              } else {
                                                controller
                                                    .onDeleteTap(addMedicine);
                                              }
                                            },
                                            itemBuilder:
                                                (BuildContext context) =>
                                                    <PopupMenuEntry>[
                                              PopupMenuItem(
                                                value: 0,
                                                child: Text(
                                                  S.current.edit,
                                                  style: const TextStyle(
                                                      fontFamily:
                                                          FontRes.medium,
                                                      color: ColorRes
                                                          .battleshipGrey),
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 1,
                                                child: Text(
                                                  S.current.delete,
                                                  style: const TextStyle(
                                                      fontFamily:
                                                          FontRes.medium,
                                                      color: ColorRes
                                                          .battleshipGrey),
                                                ),
                                              ),
                                            ],
                                            color: ColorRes.whiteSmoke,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  bottomLeft:
                                                      Radius.circular(15),
                                                  bottomRight:
                                                      Radius.circular(15)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                    },
                  ),
                  InkWell(
                    onTap: () => controller.addMedicineTap(controller),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.all(15),
                      color: ColorRes.whiteSmoke,
                      alignment: Alignment.center,
                      child: Text(
                        S.current.addMedicine,
                        style: const TextStyle(
                            color: ColorRes.tuftsBlue,
                            fontSize: 14,
                            fontFamily: FontRes.semiBold),
                      ),
                    ),
                  ),

                  // ── البرنامج المنزلي ──────────────────────────────────
                  _simpleText(
                      title: 'البرنامج المنزلي',
                      fontFamily: FontRes.semiBold,
                      color: ColorRes.charcoalGrey),
                  GetBuilder(
                    init: controller,
                    builder: (c) {
                      return Column(
                        children: [
                          if (c.homeProgram.isNotEmpty)
                            ListView.builder(
                              itemCount: c.homeProgram.length,
                              primary: false,
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemBuilder: (ctx, i) {
                                final ex = c.homeProgram[i];
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  color: i % 2 == 0
                                      ? ColorRes.whiteSmoke
                                      : ColorRes.snowDrift,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(ex.title ?? '',
                                                style: const TextStyle(
                                                    fontFamily: FontRes.semiBold,
                                                    color: ColorRes.charcoalGrey,
                                                    fontSize: 15)),
                                            if ((ex.reps ?? '').isNotEmpty)
                                              Text('التكرارات: ${ex.reps}',
                                                  style: const TextStyle(
                                                      color: ColorRes
                                                          .battleshipGrey,
                                                      fontSize: 12)),
                                            if ((ex.sets ?? '').isNotEmpty)
                                              Text('المجموعات: ${ex.sets}',
                                                  style: const TextStyle(
                                                      color: ColorRes
                                                          .battleshipGrey,
                                                      fontSize: 12)),
                                            if ((ex.duration ?? '').isNotEmpty)
                                              Text('المدة: ${ex.duration}',
                                                  style: const TextStyle(
                                                      color: ColorRes
                                                          .battleshipGrey,
                                                      fontSize: 12)),
                                            if ((ex.notes ?? '').isNotEmpty)
                                              Text(ex.notes ?? '',
                                                  style: const TextStyle(
                                                      color: ColorRes.tuftsBlue,
                                                      fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: ColorRes.bittersweet,
                                            size: 20),
                                        onPressed: () =>
                                            c.onDeleteHomeExercise(ex),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          InkWell(
                            onTap: () => Get.bottomSheet(
                              AddHomeExerciseSheet(controller: controller),
                              isScrollControlled: true,
                            ),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(15),
                              color: ColorRes.whiteSmoke,
                              alignment: Alignment.center,
                              child: const Text('+ إضافة تمرين',
                                  style: TextStyle(
                                      color: ColorRes.tuftsBlue,
                                      fontSize: 14,
                                      fontFamily: FontRes.semiBold)),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // ── المرفقات ──────────────────────────────────────────
                  _simpleText(
                      title: 'المرفقات (صور وملفات)',
                      fontFamily: FontRes.semiBold,
                      color: ColorRes.charcoalGrey),
                  GetBuilder(
                    init: controller,
                    builder: (c) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Images grid
                          if (c.imageUrls.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: c.imageUrls.map((url) {
                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              '${ConstRes.itemBaseURL}$url',
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) =>
                                              Container(
                                            width: 90,
                                            height: 90,
                                            color: ColorRes.whiteSmoke,
                                            child: const Icon(
                                                Icons.broken_image_outlined,
                                                color: ColorRes.silver),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 2,
                                        right: 2,
                                        child: GestureDetector(
                                          onTap: () => c.onDeleteImage(url),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                                color: ColorRes.bittersweet,
                                                shape: BoxShape.circle),
                                            padding: const EdgeInsets.all(3),
                                            child: const Icon(Icons.close,
                                                size: 12,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          // Files list
                          if (c.attachmentUrls.isNotEmpty)
                            ...c.attachmentUrls.map((url) => ListTile(
                                  dense: true,
                                  leading: const Icon(
                                      Icons.attach_file_rounded,
                                      color: ColorRes.havelockBlue),
                                  title: Text(url.split('/').last,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: ColorRes.davyGrey,
                                          fontFamily: FontRes.medium)),
                                  trailing: IconButton(
                                    icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: ColorRes.bittersweet,
                                        size: 18),
                                    onPressed: () =>
                                        c.onDeleteAttachment(url),
                                  ),
                                )),
                          // Upload buttons
                          if (c.isUploadingFile)
                            const Padding(
                              padding: EdgeInsets.all(10),
                              child: Center(
                                  child: CircularProgressIndicator(
                                      color: ColorRes.havelockBlue)),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: c.onPickImage,
                                      icon: const Icon(
                                          Icons.photo_library_outlined,
                                          size: 18,
                                          color: ColorRes.havelockBlue),
                                      label: const Text('صور',
                                          style: TextStyle(
                                              color: ColorRes.havelockBlue,
                                              fontSize: 13)),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: ColorRes.havelockBlue),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: c.onPickAttachment,
                                      icon: const Icon(
                                          Icons.attach_file_rounded,
                                          size: 18,
                                          color: ColorRes.havelockBlue),
                                      label: const Text('ملفات',
                                          style: TextStyle(
                                              color: ColorRes.havelockBlue,
                                              fontSize: 13)),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: ColorRes.havelockBlue),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 4),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // ── ملاحظات ───────────────────────────────────────────
                  _simpleText(
                      title: S.current.notes,
                      fontFamily: FontRes.semiBold,
                      color: ColorRes.charcoalGrey),
                  const SizedBox(height: 8),
                  Container(
                    height: 120,
                    color: ColorRes.whiteSmoke,
                    child: TextField(
                        controller: controller.extraNoteController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.all(10),
                          border: InputBorder.none,
                          hintText: S.current.writeHere,
                          hintStyle: const TextStyle(
                            fontFamily: FontRes.medium,
                            fontSize: 15,
                            color: ColorRes.nobel,
                          ),
                        ),
                        style: const TextStyle(
                            fontSize: 15,
                            color: ColorRes.davyGrey,
                            fontFamily: FontRes.medium),
                        expands: true,
                        minLines: null,
                        maxLines: null),
                  ),
                  const SizedBox(height: 10)
                ],
              ),
            ),
          ),
          DoctorRegButton(
              onTap: () => controller.onContinueTap(
                  controller.appointmentData?.prescription == null ? 0 : 1),
              title: S.current.submit)
        ],
      ),
    );
  }

  String ageAndGenderFormat(AppointmentData? data) {
    if (data?.patient == null) {
      return "${data?.user?.dob == null ? '0' : CommonFun.calculateAge(data?.user?.dob)} ${S.current.years} : ${data?.user?.gender == 1 ? S.current.male : S.current.feMale}";
    } else {
      return "${data?.patient?.age ?? '0'} ${S.current.years} : ${data?.patient?.gender == 1 ? S.current.male : S.current.feMale}";
    }
  }

  Widget _simpleText(
      {required String title,
      required String fontFamily,
      Color color = ColorRes.battleshipGrey}) {
    return Container(
      padding: EdgeInsets.only(
        top: 10,
        left: Directionality.of(Get.context!) == TextDirection.rtl ? 0 : 15,
        bottom: 5,
        right: Directionality.of(Get.context!) == TextDirection.rtl ? 15 : 0,
      ),
      child: Text(
        title,
        style: TextStyle(fontSize: 15, color: color, fontFamily: fontFamily),
      ),
    );
  }
}
