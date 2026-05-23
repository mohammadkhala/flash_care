import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/appointment_screen/appointment_screen.dart';
import 'package:patient_flutter/screen/home_screen/home_screen_controller.dart';
import 'package:patient_flutter/screen/home_screen/widget/doctor_category_section.dart';
import 'package:patient_flutter/screen/home_screen/widget/home_top_area.dart';
import 'package:patient_flutter/screen/home_screen/widget/specialist_categories_grid.dart';
import 'package:patient_flutter/screen/home_screen/widget/today_appointment.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeScreenController());
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF8),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => HomeTopArea(userData: controller.userData.value)),
          Expanded(
            child: Obx(
              () => controller.isLoading.value &&
                      controller.appointments.isEmpty &&
                      controller.specialistCategories.isEmpty
                  ? CustomUi.loaderWidget()
                  : RefreshIndicator(
                      color: const Color(0xFF00897B),
                      onRefresh: () async =>
                          controller.fetchHomePageDataApiCall(resetData: true),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),

                            // ── Today's appointments ──────────────────
                            Obx(() => TodayAppointment(
                                appointments: controller.appointments,
                                onViewAll: () {
                                  // navigate to appointments tab
                                })),

                            // ── Specialties ───────────────────────────
                            Obx(() => SpecialistCategoriesGrid(
                                  specialistCategories:
                                      controller.specialistCategories,
                                  onCategoryTap: (category) {
                                    controller
                                        .onSpecialistsDetailScreenNavigate(
                                            category);
                                  },
                                )),

                            // ── Doctors by category ───────────────────
                            DoctorCategorySection(controller: controller),

                            // ── Daily health tip ──────────────────────
                            const _DailyTipCard(),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Daily health tip card ─────────────────────────────────────────────────────

class _DailyTipCard extends StatelessWidget {
  const _DailyTipCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF91462C),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF91462C).withValues(alpha: .2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'نصيحة اليوم',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'ProductSans-Bold',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'شرب 8 أكواب من الماء يومياً يساعد في تحسين الدورة الدموية وسرعة التعافي.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .9),
                      fontSize: 12,
                      fontFamily: 'ProductSans-Regular',
                      height: 1.6,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.water_drop_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared section heading ────────────────────────────────────────────────────

class HomeScreenCatHeading extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const HomeScreenCatHeading({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'ProductSans-Regular',
                  color: Color(0xFF00897B),
                ),
              ),
            ),
          const Spacer(),
          Text(
            title,
            style: MyTextStyle.montserratSemiBold(
                size: 16, color: const Color(0xFF171D1B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
