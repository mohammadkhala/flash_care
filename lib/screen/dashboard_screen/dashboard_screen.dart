import 'package:doctor_flutter/screen/appointment_screen/appointment_screen.dart';
import 'package:doctor_flutter/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:doctor_flutter/screen/home_reel_screen/home_reel_screen.dart';
import 'package:doctor_flutter/screen/home_screen/home_screen.dart';
import 'package:doctor_flutter/screen/message_screen/message_screen.dart';
import 'package:doctor_flutter/screen/profile_screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _primary = Color(0xFF00685d);
  static const _bg = Color(0xFFF6FAF8);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardScreenController());

    return GetBuilder(
      init: controller,
      builder: (_) => Scaffold(
        backgroundColor: _bg,
        bottomNavigationBar: Obx(
          () => _BottomNav(
            selectedIndex: controller.currentIndex.value,
            unreadCount: controller.unReadMessages.length,
            onTap: controller.onItemSelected,
          ),
        ),
        body: Obx(
          () => IndexedStack(
            index: controller.currentIndex.value,
            children: [
              const HomeScreen(),
              const AppointmentScreen(),
              HomeReelScreen(),
              const MessageScreen(),
              const ProfileScreen(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final int unreadCount;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.selectedIndex,
    required this.unreadCount,
    required this.onTap,
  });

  static const _primary = Color(0xFF00685d);
  static const _inactive = Color(0xFF6D7A77);

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
    _NavItem(icon: Icons.calendar_month_rounded, label: 'المواعيد'),
    _NavItem(icon: Icons.play_circle_outline_rounded, label: 'ريلز'),
    _NavItem(icon: Icons.chat_bubble_outline_rounded, label: 'الرسائل'),
    _NavItem(icon: Icons.person_outline_rounded, label: 'حسابي'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: .08),
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
            final selected = i == selectedIndex;
            final isMessage = i == 3;
            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 64,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: selected
                                ? _primary.withValues(alpha: .12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _items[i].icon,
                            size: 22,
                            color: selected ? _primary : _inactive,
                          ),
                        ),
                        if (isMessage && unreadCount > 0)
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
                                '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontFamily: 'ProductSans-Bold',
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _items[i].label,
                      style: TextStyle(
                        fontFamily: selected
                            ? 'ProductSans-Bold'
                            : 'ProductSans-Regular',
                        fontSize: 10,
                        color: selected ? _primary : _inactive,
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
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
