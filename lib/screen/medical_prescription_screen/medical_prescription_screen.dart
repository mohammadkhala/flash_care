import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/top_bar_area.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/custom/categories.dart';
import 'package:patient_flutter/screen/medical_prescription_screen/medical_prescription_screen_controller.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';
import 'package:url_launcher/url_launcher.dart';

class MedicalPrescriptionScreen extends StatelessWidget {
  const MedicalPrescriptionScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MedicalPrescriptionScreenController());
    return Scaffold(
      backgroundColor: ColorRes.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TopBarArea(title: S.current.medicalPrescription),
          const SizedBox(
            height: 8,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── الأدوية ───────────────────────────────────────────
                  ListView.builder(
                    itemCount:
                        controller.medicalPrescription?.addMedicine?.length ??
                            0,
                    primary: false,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      AddMedicine? data = controller
                          .medicalPrescription?.addMedicine?[index];
                      return Container(
                        color: index % 2 != 0
                            ? ColorRes.snowDrift
                            : ColorRes.whiteSmoke,
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data?.title ?? '',
                                        style: MyTextStyle.montserratSemiBold(
                                            size: 15,
                                            color: ColorRes.charcoalGrey),
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        data?.mealTime == 0
                                            ? S.current.afterMeal
                                            : S.current.beforeMeal,
                                        style: MyTextStyle.montserratSemiBold(
                                            size: 13,
                                            color: ColorRes.battleshipGrey),
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        data?.dosage ?? '',
                                        style: MyTextStyle.montserratRegular(
                                            size: 13,
                                            color: ColorRes.battleshipGrey),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${data?.quantity ?? 0}',
                                      style: MyTextStyle.montserratBold(
                                          size: 24,
                                          color: ColorRes.charcoalGrey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Visibility(
                              visible: (data?.notes == null ||
                                      data!.notes!.isEmpty)
                                  ? false
                                  : true,
                              child: Container(
                                margin: const EdgeInsets.only(top: 8),
                                child: Text(
                                  data?.notes == null
                                      ? ''
                                      : '${S.current.notes} :- ${data?.notes}',
                                  style: MyTextStyle.montserratRegular(
                                      size: 13, color: ColorRes.tuftsBlue),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),

                  // ── البرنامج المنزلي ──────────────────────────────────
                  _buildHomeProgramSection(controller),

                  // ── المرفقات ──────────────────────────────────────────
                  _buildAttachmentsSection(controller),

                  // ── ملاحظات ───────────────────────────────────────────
                  Visibility(
                    visible: (controller.medicalPrescription?.notes == null ||
                            controller.medicalPrescription!.notes!.isEmpty)
                        ? false
                        : true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            S.current.notes,
                            style: MyTextStyle.montserratSemiBold(
                                size: 15, color: ColorRes.charcoalGrey),
                          ),
                        ),
                        Container(
                          color: ColorRes.snowDrift,
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            controller.medicalPrescription?.notes ?? '',
                            style: MyTextStyle.montserratMedium(
                              color: ColorRes.nobel,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          GetBuilder(
              init: controller,
              builder: (context) {
                return InkWell(
                  onTap: controller.createPdf,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
                    decoration: const BoxDecoration(
                        gradient: MyTextStyle.linearTopGradient),
                    alignment: Alignment.center,
                    child: SafeArea(
                      top: false,
                      child: Text(
                        S.current.downloadPrescription,
                        style: MyTextStyle.montserratSemiBold(
                            size: 17, color: ColorRes.white),
                      ),
                    ),
                  ),
                );
              })
        ],
      ),
    );
  }

  Widget _buildHomeProgramSection(
      MedicalPrescriptionScreenController controller) {
    final exercises =
        controller.medicalPrescription?.homeProgram ?? [];
    if (exercises.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          child: Text(
            'البرنامج المنزلي',
            style: MyTextStyle.montserratSemiBold(
                size: 15, color: ColorRes.charcoalGrey),
          ),
        ),
        ListView.builder(
          itemCount: exercises.length,
          primary: false,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemBuilder: (ctx, i) {
            final ex = exercises[i];
            return Container(
              color: i % 2 != 0 ? ColorRes.snowDrift : ColorRes.whiteSmoke,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ex.title ?? '',
                    style: MyTextStyle.montserratSemiBold(
                        size: 14, color: ColorRes.charcoalGrey),
                  ),
                  if ((ex.reps ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        'التكرارات: ${ex.reps}',
                        style: MyTextStyle.montserratRegular(
                            size: 12, color: ColorRes.battleshipGrey),
                      ),
                    ),
                  if ((ex.sets ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        'المجموعات: ${ex.sets}',
                        style: MyTextStyle.montserratRegular(
                            size: 12, color: ColorRes.battleshipGrey),
                      ),
                    ),
                  if ((ex.duration ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        'المدة: ${ex.duration}',
                        style: MyTextStyle.montserratRegular(
                            size: 12, color: ColorRes.battleshipGrey),
                      ),
                    ),
                  if ((ex.notes ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        ex.notes ?? '',
                        style: MyTextStyle.montserratRegular(
                            size: 12, color: ColorRes.tuftsBlue),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection(
      MedicalPrescriptionScreenController controller) {
    final images = controller.medicalPrescription?.images ?? [];
    final attachments = controller.medicalPrescription?.attachments ?? [];
    if (images.isEmpty && attachments.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          child: Text(
            'المرفقات',
            style: MyTextStyle.montserratSemiBold(
                size: 15, color: ColorRes.charcoalGrey),
          ),
        ),
        // Images horizontal scroll
        if (images.isNotEmpty)
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: images.length,
              itemBuilder: (ctx, i) {
                final url = images[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: '${ConstRes.itemBaseURL}$url',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 100,
                        height: 100,
                        color: ColorRes.whiteSmoke,
                        child: const Icon(Icons.broken_image_outlined,
                            color: ColorRes.silver),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        if (images.isNotEmpty) const SizedBox(height: 6),
        // Files list
        ...attachments.map((url) {
          final fileName = url.split('/').last;
          final fullUrl = '${ConstRes.itemBaseURL}$url';
          return ListTile(
            dense: true,
            leading: const Icon(Icons.attach_file_rounded,
                color: ColorRes.havelockBlue),
            title: Text(
              fileName,
              style: MyTextStyle.montserratMedium(
                  size: 13, color: ColorRes.davyGrey),
            ),
            trailing:
                const Icon(Icons.open_in_new, size: 18, color: ColorRes.havelockBlue),
            onTap: () async {
              final uri = Uri.parse(fullUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          );
        }),
        const SizedBox(height: 6),
      ],
    );
  }
}
