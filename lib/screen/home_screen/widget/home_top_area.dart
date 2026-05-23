import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:patient_flutter/screen/message_screen/message_screen.dart';
import 'package:patient_flutter/screen/notification_screen/notification_screen.dart';
import 'package:patient_flutter/screen/prescription_screen/prescription_screen.dart';
import 'package:patient_flutter/screen/search_screen/search_screen.dart';
import 'package:patient_flutter/utils/const_res.dart';

class HomeTopArea extends StatelessWidget {
  final UserData? userData;
  const HomeTopArea({super.key, this.userData});

  static const _primary = Color(0xFF00685d);
  static const _bg = Color(0xFFF6FAF8);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── App bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  // User avatar
                  _Avatar(name: userData?.fullname ?? ''),
                  const Spacer(),
                  // App name center
                  const Text(
                    appName,
                    style: TextStyle(
                      fontFamily: 'ProductSans-Bold',
                      fontSize: 20,
                      color: Color(0xFF171D1B),
                    ),
                  ),
                  const Spacer(),
                  // Bell
                  _IconBtn(
                    icon: Icons.notifications_outlined,
                    onTap: () => Get.to(() => const NotificationScreen()),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Greeting ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'أهلاً، ${userData?.fullname?.split(' ').first ?? ''}',
                    style: const TextStyle(
                      fontFamily: 'ProductSans-Bold',
                      fontSize: 22,
                      color: Color(0xFF171D1B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'نتمنى لك يوماً صحياً مليئاً بالنشاط.',
                    style: TextStyle(
                      fontFamily: 'ProductSans-Regular',
                      fontSize: 13,
                      color: Color(0xFF6D7A77),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Book appointment banner ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => Get.to(() => const SearchScreen()),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF008376), Color(0xFF00685d)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _primary.withValues(alpha: .2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
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
                              'حجز موعد جديد',
                              style: TextStyle(
                                fontFamily: 'ProductSans-Bold',
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'اختر طبيبك المفضل الآن',
                              style: TextStyle(
                                fontFamily: 'ProductSans-Regular',
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: .85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Quick actions ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.search_rounded,
                      label: 'البحث عن طبيب',
                      onTap: () => Get.to(() => const SearchScreen()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.receipt_long_outlined,
                      label: 'الوصفات الطبية',
                      onTap: () => Get.to(() => const PrescriptionScreen()),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});
  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF008376), Color(0xFF00685d)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'ProductSans-Bold',
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00685d).withValues(alpha: .08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 22, color: const Color(0xFF3D4946)),
        ),
      );
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00685d).withValues(alpha: .06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: const Color(0xFF00685d)),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'ProductSans-Medium',
                  color: Color(0xFF3D4946),
                ),
              ),
            ],
          ),
        ),
      );
}

// kept for backward compat
class MessageIcon extends StatelessWidget {
  const MessageIcon({super.key});
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DashboardScreenController>();
    return GestureDetector(
      onTap: () => Get.to(() => MessageScreen()),
      child: Obx(() => Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00685d).withValues(alpha: .08),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.chat_bubble_outline_rounded,
                    size: 20, color: Color(0xFF3D4946)),
              ),
              if (ctrl.unReadMessages.isNotEmpty)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE05040),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${ctrl.unReadMessages.length}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontFamily: 'ProductSans-Bold'),
                    ),
                  ),
                ),
            ],
          )),
    );
  }
}
