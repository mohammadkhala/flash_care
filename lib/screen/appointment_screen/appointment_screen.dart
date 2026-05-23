import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/appointment_screen/appointment_screen_controller.dart';
import 'package:patient_flutter/screen/appointment_screen/widget/appointments.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class AppointmentScreen extends StatelessWidget {
  final int screenType;

  const AppointmentScreen({super.key, required this.screenType});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppointmentScreenController());
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'مواعيدي',
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'ProductSans-Bold',
                      color: Color(0xFF171D1B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'تتبع مواعيدك الطبية وجلسات التأهيل القادمة.',
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'ProductSans-Regular',
                      color: Color(0xFF6D7A77),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Tab row ──────────────────────────────────────────────────
            SizedBox(
              height: 44,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.appointmentFilters.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Obx(
                    () {
                      final isSelected =
                          controller.selectedIndex.value == index;
                      return GestureDetector(
                        onTap: () => controller.onTabChanged(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 44,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(left: 8),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 22),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF00897B),
                                      Color(0xFF00695C)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isSelected ? null : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF00897B)
                                          .withValues(alpha: .3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : [
                                    BoxShadow(
                                      color: const Color(0xFF00695C)
                                          .withValues(alpha: .06),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                          ),
                          child: Text(
                            controller.appointmentFilters[index],
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'ProductSans-Medium',
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF6D7A77),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ── Appointments list ─────────────────────────────────────────
            Appointments(controller: controller),
          ],
        ),
      ),
      // ── FAB ────────────────────────────────────────────────────────────
      floatingActionButton: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00897B), Color(0xFF00695C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00897B).withValues(alpha: .35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
