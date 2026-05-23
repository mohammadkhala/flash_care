import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/common/image_builder_custom.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/doctor/fetch_doctor.dart';
import 'package:patient_flutter/screen/saved_doctor_screen/widget/doctor_card.dart';
import 'package:patient_flutter/screen/search_screen/search_screen_controller.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/extention.dart';
import 'package:patient_flutter/utils/my_text_style.dart';
import 'package:patient_flutter/utils/update_res.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchScreenController());
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────────────
            _SearchHeader(controller: controller),

            // ── Filter chips ─────────────────────────────────────────────
            GetBuilder(
              id: 'searchType',
              init: controller,
              builder: (c) => _FilterChips(controller: c),
            ),

            // ── Results list ─────────────────────────────────────────────
            Expanded(
              child: GetBuilder(
                init: controller,
                builder: (c) {
                  if (c.isLoading) return CustomUi.loaderWidget();
                  if (c.doctors.isEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد نتائج',
                        style: MyTextStyle.montserratMedium(
                            size: 15, color: const Color(0xFF6D7A77)),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: c.scrollController,
                    padding: const EdgeInsets.only(top: 8, bottom: 20),
                    itemCount: c.doctors.length,
                    itemBuilder: (context, index) {
                      // First result as featured card
                      if (index == 0 && c.doctors.length > 1) {
                        return _FeaturedDoctorCard(
                          doctorData: c.doctors[0],
                          onTap: () => c.onDoctorCardTap(c.doctors[0]),
                        );
                      }
                      final doctorIndex = c.doctors.length > 1 ? index : index;
                      return DoctorCard(
                        doctorData: c.doctors[index],
                        index: index,
                        isBookMarkVisible: false,
                        onTap: () => c.onDoctorCardTap(c.doctors[index]),
                        onBookMarkTap: (_) {},
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search header (search bar + back button) ──────────────────────────────────

class _SearchHeader extends StatelessWidget {
  final SearchScreenController controller;
  const _SearchHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          // Back
          GestureDetector(
            onTap: Get.back,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00695C).withValues(alpha: .08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 18, color: Color(0xFF3D4946)),
            ),
          ),
          const SizedBox(width: 12),
          // Search field
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00695C).withValues(alpha: .06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search_rounded,
                      size: 20, color: Color(0xFF6D7A77)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller.keywordController,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'ابحث عن طبيب أو تخصص',
                        hintStyle: TextStyle(
                          color: Color(0xFFBCC9C5),
                          fontSize: 14,
                          fontFamily: 'ProductSans-Regular',
                        ),
                      ),
                      style: const TextStyle(
                        color: Color(0xFF171D1B),
                        fontSize: 14,
                        fontFamily: 'ProductSans-Regular',
                      ),
                      cursorColor: const Color(0xFF00897B),
                      onChanged: controller.onKeyWordChange,
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter chips row ──────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  final SearchScreenController controller;
  const _FilterChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    final filters = [
      _FilterItem(
          label: 'التخصص', icon: Icons.tune_rounded, type: 0),
      _FilterItem(
          label: 'السعر', icon: Icons.keyboard_arrow_down_rounded, type: 1),
      _FilterItem(
          label: 'التقييم', icon: Icons.star_border_rounded, type: 2),
      _FilterItem(label: 'القرب', icon: null, type: 3),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: filters.map((f) {
          final selected = controller.searchType == f.type;
          return GestureDetector(
            onTap: () => controller.onSearchTypeTap(f.type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(left: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF00897B)
                    : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF00897B)
                      : const Color(0xFFBCC9C5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (f.icon != null) ...[
                    Icon(f.icon,
                        size: 14,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF3D4946)),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    f.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'ProductSans-Medium',
                      color: selected
                          ? Colors.white
                          : const Color(0xFF3D4946),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FilterItem {
  final String label;
  final IconData? icon;
  final int type;
  _FilterItem({required this.label, this.icon, required this.type});
}

// ── Featured doctor card (first result) ──────────────────────────────────────

class _FeaturedDoctorCard extends StatelessWidget {
  final DoctorData doctorData;
  final VoidCallback onTap;
  const _FeaturedDoctorCard(
      {required this.doctorData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rating = doctorData.rating;
    final hasRating = rating != null && rating.toInt() != 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00695C).withValues(alpha: .09),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image area
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  ImageBuilderCustom(
                    doctorData.image,
                    name: doctorData.name,
                    size: 200,
                    radius: 0,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  // "فاخرة طبياً" badge
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00897B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'فاخرة طبياً',
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'ProductSans-Bold',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Rating badge
                  if (hasRating)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 14, color: Color(0xFFF59E2A)),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'ProductSans-Bold',
                                color: Color(0xFF171D1B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content area
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          doctorData.name ?? S.current.unKnown,
                          style: const TextStyle(
                            fontSize: 17,
                            fontFamily: 'ProductSans-Bold',
                            color: Color(0xFF171D1B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctorData.designation ?? doctorData.degrees ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'ProductSans-Regular',
                            color: Color(0xFF6D7A77),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$dollar${(doctorData.consultationFee ?? 0).numFormat} / جلسة',
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: 'ProductSans-Bold',
                            color: Color(0xFF171D1B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Book button
                  GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00897B), Color(0xFF00695C)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'حجز موعد',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'ProductSans-Bold',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
