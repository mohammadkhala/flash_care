import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/common/image_builder_custom.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/appointment/fetch_appointment.dart';
import 'package:patient_flutter/screen/appointment_detail_screen/appointment_detail_screen.dart';
import 'package:patient_flutter/screen/home_screen/home_screen.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class TodayAppointment extends StatelessWidget {
  final List<AppointmentData> appointments;
  final VoidCallback? onViewAll;

  const TodayAppointment(
      {super.key, required this.appointments, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: HomeScreenCatHeading(
            title: 'مواعيد اليوم',
            actionLabel: 'عرض الكل',
            onAction: onViewAll,
          ),
        ),
        ListView.builder(
          primary: false,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            return _AppointmentCard(appointment: appointments[index]);
          },
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentData appointment;
  const _AppointmentCard({required this.appointment});

  bool get _isOnline => (appointment.type ?? 1) == 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // ── Doctor row ─────────────────────────────────────────────
          Row(
            children: [
              // Doctor image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ImageBuilderCustom(
                  appointment.doctor?.image,
                  name: appointment.doctor?.name,
                  size: 60,
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
                      appointment.doctor?.name ?? S.current.unKnown,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'ProductSans-Bold',
                        color: Color(0xFF171D1B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.doctor?.designation ?? '',
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
              // Time badge
              Column(
                children: [
                  Text(
                    CustomUi.convert24HoursInto12Hours(appointment.time),
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'ProductSans-Bold',
                      color: Color(0xFF00695C),
                    ),
                  ),
                  Text(
                    'ص',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'ProductSans-Regular',
                      color: Color(0xFF6D7A77),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Action buttons ─────────────────────────────────────────
          Row(
            children: [
              // Details button (outline)
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.to(() => const AppointmentDetailScreen(),
                      arguments: appointment),
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF00897B)),
                    ),
                    child: const Text(
                      'تفاصيل الموعد',
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
              // Join call button (filled) — visible only for online
              if (_isOnline)
                Expanded(
                  child: Container(
                    height: 40,
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
                        const Icon(Icons.video_camera_front_rounded,
                            size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        const Text(
                          'انضم للمكالمة',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'ProductSans-Medium',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final bool isOnline;
  const _TypeBadge({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            isOnline ? 'جلسة أون لاين' : 'في العيادة',
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'ProductSans-Medium',
              color: isOnline ? const Color(0xFF00695C) : const Color(0xFF3D4946),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isOnline ? Icons.videocam_rounded : Icons.location_on_outlined,
            size: 12,
            color: isOnline ? const Color(0xFF00695C) : const Color(0xFF3D4946),
          ),
        ],
      ),
    );
  }
}
