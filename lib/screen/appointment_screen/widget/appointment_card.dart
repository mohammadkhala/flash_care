import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/common/image_builder_custom.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/appointment/fetch_appointment.dart';
import 'package:patient_flutter/model/doctor/fetch_doctor.dart';
import 'package:patient_flutter/screen/appointment_detail_screen/appointment_detail_screen.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/extention.dart';
import 'package:patient_flutter/utils/my_text_style.dart';
import 'package:patient_flutter/utils/update_res.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentData? appointmentData;

  const AppointmentCard({super.key, this.appointmentData});

  bool get _isOnline => (appointmentData?.type ?? 1) == 0;

  @override
  Widget build(BuildContext context) {
    final DoctorData? doctor = appointmentData?.doctor;
    final status = appointmentData?.status ?? 0;

    return GestureDetector(
      onTap: () => Get.to(() => const AppointmentDetailScreen(),
          arguments: appointmentData),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00695C).withValues(alpha: .07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Doctor + time row ──────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ImageBuilderCustom(
                    doctor?.image,
                    name: doctor?.name,
                    size: 64,
                    radius: 12,
                  ),
                ),
                const SizedBox(width: 12),
                // Doctor info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        doctor?.name ?? S.current.unKnown,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 15,
                          fontFamily: 'ProductSans-Bold',
                          color: Color(0xFF171D1B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        doctor?.designation ?? doctor?.degrees ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'ProductSans-Regular',
                          color: Color(0xFF6D7A77),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Type badge
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: _TypeBadge(isOnline: _isOnline),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Three dots / status
                _StatusDot(status: status),
              ],
            ),

            const SizedBox(height: 12),

            // ── Date + time row ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F5F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Time
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 15, color: Color(0xFF6D7A77)),
                      const SizedBox(width: 5),
                      Text(
                        CustomUi.convert24HoursInto12Hours(
                            appointmentData?.time),
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'ProductSans-Medium',
                          color: Color(0xFF3D4946),
                        ),
                      ),
                    ],
                  ),
                  // Date
                  Row(
                    children: [
                      Text(
                        (appointmentData?.date ?? createdDate)
                            .dateParse(eeeMmmDdYyyy),
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'ProductSans-Medium',
                          color: Color(0xFF3D4946),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.calendar_today_outlined,
                          size: 15, color: Color(0xFF6D7A77)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Action buttons ─────────────────────────────────────────
            Row(
              children: [
                // Details (always visible)
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.to(() => const AppointmentDetailScreen(),
                        arguments: appointmentData),
                    child: Container(
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF00897B)),
                      ),
                      child: const Text(
                        'تفاصيل الحجز',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'ProductSans-Medium',
                          color: Color(0xFF00897B),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Primary action (join / reschedule)
                Expanded(
                  child: _isOnline && status == 1
                      ? Container(
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00897B), Color(0xFF00695C)],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.videocam_rounded,
                                  size: 16, color: Colors.white),
                              const SizedBox(width: 6),
                              const Text(
                                'دخول الجلسة الآن',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'ProductSans-Medium',
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2F1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'تعديل الموعد',
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'ProductSans-Medium',
                              color: Color(0xFF00695C),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final bool isOnline;
  const _TypeBadge({required this.isOnline});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isOnline
              ? const Color(0xFFE0F2F1)
              : const Color(0xFFF0F5F2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isOnline ? 'جلسة عن بعد' : 'في العيادة',
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'ProductSans-Medium',
                color: isOnline
                    ? const Color(0xFF00695C)
                    : const Color(0xFF3D4946),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isOnline
                  ? Icons.videocam_outlined
                  : Icons.location_on_outlined,
              size: 12,
              color: isOnline
                  ? const Color(0xFF00695C)
                  : const Color(0xFF3D4946),
            ),
          ],
        ),
      );
}

class _StatusDot extends StatelessWidget {
  final int status;
  const _StatusDot({required this.status});

  Color get _color {
    switch (status) {
      case 0:
        return const Color(0xFFF59E2A);
      case 1:
        return const Color(0xFF00897B);
      case 2:
        return const Color(0xFF00695C);
      case 3:
        return const Color(0xFF6D7A77);
      default:
        return const Color(0xFFE05040);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _color,
        ),
      );
}
