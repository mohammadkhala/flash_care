import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/screen/appointment_screen/appointment_screen.dart';
import 'package:patient_flutter/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:patient_flutter/screen/home_screen/home_screen.dart';
import 'package:patient_flutter/screen/message_screen/message_screen.dart';
import 'package:patient_flutter/screen/profile_screen/profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _kPrimary = Color(0xFF00685d);
  static const _kBg = Color(0xFFF6FAF8);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardScreenController());
    return Scaffold(
      backgroundColor: _kBg,
      bottomNavigationBar: _BottomNav(controller: controller),
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: [
              const HomeScreen(),
              const AppointmentScreen(screenType: 0),
              MessageScreen(),
              const ProfileScreen(),
            ],
          )),
    );
  }
}

// ── Bottom Navigation Bar ─────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final DashboardScreenController controller;
  const _BottomNav({required this.controller});

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
    _NavItem(icon: Icons.calendar_month_rounded, label: 'المواعيد'),
    _NavItem(icon: Icons.chat_bubble_outline_rounded, label: 'الرسائل'),
    _NavItem(icon: Icons.person_outline_rounded, label: 'حسابي'),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final idx = controller.currentIndex.value;
      return Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00685d).withValues(alpha: .08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final selected = idx == i;
              return GestureDetector(
                onTap: () => controller.onItemSelected(i),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 72,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF00685d).withValues(alpha: .1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          _items[i].icon,
                          size: 24,
                          color: selected
                              ? const Color(0xFF00685d)
                              : const Color(0xFF6D7A77),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _items[i].label,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'ProductSans-Medium',
                          color: selected
                              ? const Color(0xFF00685d)
                              : const Color(0xFF6D7A77),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      );
    });
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
