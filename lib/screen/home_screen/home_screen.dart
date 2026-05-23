import 'package:doctor_flutter/common/image_builder_custom.dart';
import 'package:doctor_flutter/model/appointment/appointment_request.dart';
import 'package:doctor_flutter/screen/appointment_detail_screen/appointment_detail_screen.dart';
import 'package:doctor_flutter/screen/appointment_screen/appointment_screen.dart';
import 'package:doctor_flutter/screen/home_screen/home_screen_controller.dart';
import 'package:doctor_flutter/screen/notification_screen/notification_screen.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _primary = Color(0xFF00685d);
  static const _primaryContainer = Color(0xFF008376);
  static const _bg = Color(0xFFF6FAF8);
  static const _surface = Color(0xFFEAEFEC);
  static const _onSurface = Color(0xFF171D1B);
  static const _outline = Color(0xFF6D7A77);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(HomeScreenController());
    return GetBuilder<HomeScreenController>(
      init: c,
      builder: (ctrl) => Scaffold(
        backgroundColor: _bg,
        body: RefreshIndicator(
          color: _primary,
          onRefresh: () async => ctrl.fetchTodayAppointments(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(ctrl)),
              SliverToBoxAdapter(child: _buildStatsRow(ctrl)),
              SliverToBoxAdapter(child: _buildEarningsCard()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Get.to(() => const AppointmentScreen()),
                        child: const Text(
                          'عرض الكل',
                          style: TextStyle(
                            fontFamily: 'ProductSans-Medium',
                            fontSize: 13,
                            color: _primary,
                          ),
                        ),
                      ),
                      const Text(
                        'مواعيد اليوم',
                        style: TextStyle(
                          fontFamily: 'ProductSans-Bold',
                          fontSize: 17,
                          color: _onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Obx(() {
                if (ctrl.isLoading.value) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                          child: CircularProgressIndicator(color: _primary)),
                    ),
                  );
                }
                if (ctrl.todayAppointments.isEmpty) {
                  return const SliverToBoxAdapter(child: _EmptyState());
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) =>
                        _AppointmentCard(appointment: ctrl.todayAppointments[i]),
                    childCount: ctrl.todayAppointments.length,
                  ),
                );
              }),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(HomeScreenController ctrl) {
    final name = ctrl.doctorData?.name ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'D';
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'صباح الخير'
        : hour < 17
            ? 'مساء الخير'
            : 'مساء النور';

    return Container(
      color: _bg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              // Bell
              GestureDetector(
                onTap: () => Get.to(() => const NotificationScreen()),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _primary.withValues(alpha: .08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      size: 22, color: Color(0xFF3D4946)),
                ),
              ),
              const Spacer(),
              // Greeting + name
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$greeting، دكتور',
                    style: const TextStyle(
                      fontFamily: 'ProductSans-Regular',
                      fontSize: 13,
                      color: _outline,
                    ),
                  ),
                  Text(
                    name.isNotEmpty ? name : 'الطبيب',
                    style: const TextStyle(
                      fontFamily: 'ProductSans-Bold',
                      fontSize: 17,
                      color: _onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [_primaryContainer, _primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: ctrl.doctorData?.image != null
                    ? ClipOval(
                        child: ImageBuilderCustom(
                          ctrl.doctorData!.image,
                          size: 44,
                          radius: 22,
                        ),
                      )
                    : Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'ProductSans-Bold',
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(HomeScreenController ctrl) {
    return Obx(() {
      final count = ctrl.todayAppointments.length;
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'مواعيد اليوم',
                value: count.toString().padLeft(2, '0'),
                icon: Icons.calendar_month_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF008376), Color(0xFF00685d)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'طلبات جديدة',
                value: '00',
                icon: Icons.inbox_rounded,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3D4946).withValues(alpha: .9),
                    const Color(0xFF171D1B),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEarningsCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF008376), Color(0xFF00685d)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _primary.withValues(alpha: .25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left: icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            // Right: text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'إجمالي الأرباح',
                    style: TextStyle(
                      fontFamily: 'ProductSans-Regular',
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: .85),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '٤,٢٥٠ ر.س',
                    style: TextStyle(
                      fontFamily: 'ProductSans-Bold',
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.trending_up_rounded,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '+١٢٪ من الأسبوع الماضي',
                        style: TextStyle(
                          fontFamily: 'ProductSans-Regular',
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: .85),
                        ),
                      ),
                    ],
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Gradient gradient;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.gradient});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'ProductSans-Bold',
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'ProductSans-Regular',
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: .85),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.event_available_rounded,
                size: 56, color: Color(0xFFBCC9C5)),
            SizedBox(height: 12),
            Text(
              'لا توجد مواعيد اليوم',
              style: TextStyle(
                fontFamily: 'ProductSans-Medium',
                fontSize: 15,
                color: Color(0xFF6D7A77),
              ),
            ),
          ],
        ),
      );
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentData appointment;
  const _AppointmentCard({required this.appointment});

  static const _primary = Color(0xFF00685d);
  static const _primaryContainer = Color(0xFF008376);

  bool get _isOnline => (appointment.type ?? 1) == 0;

  @override
  Widget build(BuildContext context) {
    final patientName =
        appointment.patient?.fullname ?? appointment.user?.fullname ?? '—';
    final timeStr = appointment.time ?? '';
    final timeFormatted = _formatTime(timeStr);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: .07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Patient avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _primaryContainer.withValues(alpha: .3),
                      _primary.withValues(alpha: .2),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                  style: const TextStyle(
                    fontFamily: 'ProductSans-Bold',
                    fontSize: 18,
                    color: _primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      patientName,
                      style: const TextStyle(
                        fontFamily: 'ProductSans-Bold',
                        fontSize: 15,
                        color: Color(0xFF171D1B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _isOnline
                                ? _primary.withValues(alpha: .1)
                                : const Color(0xFFF59E2A).withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _isOnline ? 'أونلاين' : 'عيادة',
                            style: TextStyle(
                              fontFamily: 'ProductSans-Medium',
                              fontSize: 11,
                              color: _isOnline
                                  ? _primary
                                  : const Color(0xFFF59E2A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Time badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F5F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 14, color: _primary),
                    const SizedBox(height: 2),
                    Text(
                      timeFormatted,
                      style: const TextStyle(
                        fontFamily: 'ProductSans-Bold',
                        fontSize: 12,
                        color: _primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _OutlineBtn(
                  label: 'التفاصيل',
                  onTap: () => Get.to(() => AppointmentDetailScreen(
                      appointmentData: appointment)),
                ),
              ),
              const SizedBox(width: 10),
              if (_isOnline)
                Expanded(
                  child: _GradientBtn(
                    label: 'بدء الجلسة',
                    onTap: () => Get.to(() => AppointmentDetailScreen(
                        appointmentData: appointment)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(String raw) {
    try {
      final dt = DateFormat('HH:mm:ss').parse(raw);
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return raw;
    }
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF00685d)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'ProductSans-Medium',
              fontSize: 13,
              color: Color(0xFF00685d),
            ),
          ),
        ),
      );
}

class _GradientBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GradientBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF008376), Color(0xFF00685d)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'ProductSans-Bold',
              fontSize: 13,
              color: Colors.white,
            ),
          ),
        ),
      );
}
