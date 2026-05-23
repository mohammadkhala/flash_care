import 'package:flutter/material.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/specialists_detail_screen/specialists_detail_screen_controller.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class SpecialistsFilterList extends StatelessWidget {
  final SpecialistsDetailScreenController controller;

  const SpecialistsFilterList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible:
          (controller.selectedGender == null && controller.selectedSortBy == null) ? false : true,
      child: Container(
        height: 37,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Visibility(
                      visible: controller.selectedGender != null,
                      child: filterTab(
                        title: controller.selectedGender == 0
                            ? S.current.female
                            : controller.selectedGender == 1
                                ? S.current.male
                                : S.current.both,
                        onTap: controller.onGenderRemove,
                      ),
                    ),
                    Visibility(
                      visible: controller.selectedSortBy != null,
                      child: filterTab(
                        title: controller.selectedSortBy == 0
                            ? S.current.feesLow
                            : controller.selectedSortBy == 1
                                ? S.current.feesHigh
                                : S.current.rating,
                        onTap: controller.onTypeRemove,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: controller.onClearAllTap,
              child: Text(
                S.current.clearAll,
                style: MyTextStyle.montserratSemiBold(size: 15, color: ColorRes.tuftsBlue),
              ),
            )
          ],
        ),
      ),
    );
  }

  Container filterTab({required String title, required VoidCallback onTap}) {
    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      decoration: BoxDecoration(
          color: ColorRes.havelockBlue.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(30)),
      padding: const EdgeInsets.only(left: 10, right: 5),
      child: Row(
        children: [
          Text(
            title,
            style: MyTextStyle.montserratSemiBold(color: ColorRes.havelockBlue, size: 11),
          ),
          const SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: onTap,
            child: Container(
              height: 25,
              width: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorRes.crystalBlue.withValues(alpha: 0.20),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: ColorRes.havelockBlue,
                size: 15,
              ),
            ),
          )
        ],
      ),
    );
  }
}
