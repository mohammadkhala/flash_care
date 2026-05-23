import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/home/home.dart';
import 'package:patient_flutter/screen/home_screen/home_screen.dart';
import 'package:patient_flutter/screen/specialists_screen/specialists_screen.dart';
import 'package:patient_flutter/utils/asset_res.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class SpecialistCategoriesGrid extends StatelessWidget {
  final List<Categories> specialistCategories;
  final Function(Categories category) onCategoryTap;
  final int maxVisibleItems;

  const SpecialistCategoriesGrid({
    super.key,
    required this.specialistCategories,
    required this.onCategoryTap,
    this.maxVisibleItems = 6,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = specialistCategories.length > maxVisibleItems
        ? maxVisibleItems
        : specialistCategories.length;

    return specialistCategories.isEmpty
        ? const SizedBox()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              HomeScreenCatHeading(title: S.current.findBySpecialities),
              GridView.builder(
                itemCount: itemCount,
                shrinkWrap: true,
                primary: false,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisExtent: 100,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  // Handle the last "more" item
                  if (index == maxVisibleItems - 1 &&
                      specialistCategories.length > maxVisibleItems) {
                    return GestureDetector(
                      onTap: () {
                        Get.to(() => SpecialistsScreen(screenType: 1));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorRes.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .07),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00897B), Color(0xFF00695C)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Image.asset(
                                AssetRes.icMoreRound,
                                width: 24,
                                height: 24,
                                color: ColorRes.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              S.of(context).moreHere,
                              style: MyTextStyle.montserratMedium(
                                  size: 12, color: const Color(0xFF00695C)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Regular category card
                  final category = specialistCategories[index];
                  return GestureDetector(
                    onTap: () => onCategoryTap(category),
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorRes.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .07),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF26A69A), Color(0xFF00695C)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: CachedNetworkImage(
                              imageUrl:
                                  '${ConstRes.itemBaseURL}${category.image ?? ' '}',
                              color: ColorRes.white,
                              errorWidget: (context, url, error) {
                                return const Icon(
                                  Icons.medical_services_rounded,
                                  color: ColorRes.white,
                                  size: 22,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              (category.title ?? S.current.unKnown).capitalize ?? '',
                              style: MyTextStyle.montserratMedium(
                                  size: 11, color: ColorRes.charcoalGrey),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
  }
}
