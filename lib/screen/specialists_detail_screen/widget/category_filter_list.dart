import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/close_button_custom.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/search_screen/widget/filter_sheet.dart';
import 'package:patient_flutter/screen/specialists_detail_screen/specialists_detail_screen_controller.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class CategoryFilterList extends StatelessWidget {
  final SpecialistsDetailScreenController controller;

  const CategoryFilterList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          decoration: const BoxDecoration(
            color: ColorRes.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        S.current.applySearchFilters,
                        style: MyTextStyle.montserratExtraBold(size: 20, color: ColorRes.charcoalGrey),
                      ),
                    ),
                    const CloseButtonCustom()
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.current.gender,
                      style: MyTextStyle.montserratRegular(size: 15, color: ColorRes.battleshipGrey),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GetBuilder(
                      init: controller,
                      builder: (controller) {
                        return Wrap(
                          children: List.generate(
                            controller.genderList.length,
                            (index) {
                              return InkWell(
                                onTap: () {
                                  controller.onGenderTap(index);
                                },
                                child: Card(
                                  elevation: controller.selectedGender == index ? 2 : 0,
                                  color:
                                      controller.selectedGender == index ? ColorRes.havelockBlue : ColorRes.softPeach,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      controller.genderList[index].toUpperCase(),
                                      style: MyTextStyle.montserratSemiBold(
                                              size: 12,
                                              color: controller.selectedGender == index
                                                  ? ColorRes.white
                                                  : ColorRes.charcoalGrey)
                                          .copyWith(letterSpacing: 0.5),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  S.current.sortBy,
                  style: MyTextStyle.montserratRegular(size: 15, color: ColorRes.battleshipGrey),
                ),
              ),
              ListView.builder(
                itemCount: 3,
                primary: false,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    margin: const EdgeInsets.symmetric(vertical: 1),
                    color: ColorRes.whiteSmoke,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            controller.sortByList[index],
                            style: MyTextStyle.montserratSemiBold(
                              size: 14,
                              color: ColorRes.charcoalGrey,
                            ),
                          ),
                        ),
                        GetBuilder(
                          init: controller,
                          builder: (controller) {
                            return UnicornOutlineButton(
                              strokeWidth: 2.5,
                              radius: 30,
                              gradient: MyTextStyle.linearTopGradient,
                              child: Visibility(
                                visible: controller.selectedSortBy == index ? true : false,
                                child: Container(
                                  height: 18,
                                  width: 18,
                                  decoration: const BoxDecoration(
                                    gradient: MyTextStyle.linearTopGradient,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                controller.onSortByTap(index);
                              },
                            );
                          },
                        )
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}
