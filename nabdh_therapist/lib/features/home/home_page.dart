import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/l10n/s.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map _stats    = {};
  List _today   = [];
  String _name  = '';
  int _unread   = 0;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final [meRes, statsRes, apptRes] = await Future.wait([
        ApiClient.instance.get('/me'),
        ApiClient.instance.get('/therapist/statistics'),
        ApiClient.instance.get('/therapist/appointments?filter=today&per_page=3'),
      ]);
      final t = meRes.data['user']?['therapist'] as Map? ?? {};
      final appts = apptRes.data is List ? apptRes.data : (apptRes.data['data'] ?? []);
      // backend wraps stats under 'statistics' key
      final rawStats = statsRes.data;
      setState(() {
        _name   = t['full_name'] ?? meRes.data['user']?['name'] ?? 'دكتور';
        _stats  = rawStats is Map ? ((rawStats['statistics'] as Map?) ?? rawStats) : {};
        _today  = appts as List;
        _unread = (_stats['unread_messages'] as int?) ?? 0;
        _loading = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.surface,
          title: Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
              child: const Center(child: Text('نبض',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, fontFamily: 'Cairo'))),
            ),
            const SizedBox(width: 10),
            Text(_loading ? 'مرحباً' : 'مرحباً، $_name',
                style: const TextStyle(fontSize: 15, fontFamily: 'Cairo')),
          ]),
          actions: [
            Stack(children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/notifications'),
              ),
              if (_unread > 0)
                Positioned(top: 8, right: 8, child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                )),
            ]),
          ],
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(delegate: SliverChildListDelegate([
            _SummaryCard(stats: _stats, loading: _loading),
            const SizedBox(height: 20),

            Text(S.quickActions,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
            const SizedBox(height: 12),
            _QuickActions(),
            const SizedBox(height: 20),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(S.todayAppointments,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
              TextButton(onPressed: () => context.go('/appointments'), child: Text(S.allLabel)),
            ]),
            const SizedBox(height: 8),
            _TodayAppointments(appointments: _today, loading: _loading),
            const SizedBox(height: 20),

            Text(S.assessmentTools,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
            const SizedBox(height: 12),
            _AssessmentCards(),
            const SizedBox(height: 40),
          ])),
        ),
      ]),
    ),
  );
}

class _SummaryCard extends StatelessWidget {
  final Map stats;
  final bool loading;
  const _SummaryCard({required this.stats, required this.loading});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.primary, AppColors.primaryLight],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('اليوم', style: const TextStyle(color: Colors.white70, fontFamily: 'Cairo', fontSize: 13)),
      const SizedBox(height: 4),
      Text(_todayDate(), style: const TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w600)),
      const SizedBox(height: 20),
      Row(children: [
        _StatItem(value: loading ? '-' : '${stats['today_appointments'] ?? 0}', label: 'مواعيد اليوم', icon: Icons.calendar_today),
        const SizedBox(width: 24),
        _StatItem(value: loading ? '-' : '${stats['pending_appointments'] ?? 0}', label: 'في الانتظار', icon: Icons.pending_outlined),
        const SizedBox(width: 24),
        _StatItem(value: loading ? '-' : '${stats['unread_messages'] ?? 0}', label: 'رسائل جديدة', icon: Icons.chat_bubble_outline),
      ]),
    ]),
  );

  String _todayDate() {
    final now = DateTime.now();
    const months = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    const days = ['الأحد','الاثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت'];
    return '${days[now.weekday % 7]}، ${now.day} ${months[now.month - 1]}';
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  final IconData icon;
  const _StatItem({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, color: Colors.white70, size: 20),
    const SizedBox(height: 4),
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
    Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'Cairo')),
  ]);
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      (icon: Icons.article_outlined,       label: S.myArticles,    route: '/articles',   color: AppColors.accent),
      (icon: Icons.video_call_outlined,    label: S.myReels,       route: '/reels',      color: AppColors.primary),
      (icon: Icons.bar_chart,              label: S.myStatistics,  route: '/statistics', color: const Color(0xFF7C3AED)),
      (icon: Icons.fitness_center_outlined,label: S.myPrograms,    route: '/programs',   color: const Color(0xFFEF6C00)),
    ];

    return Row(
      children: actions.map((a) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GestureDetector(
            onTap: () => context.go(a.route),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: a.color.withAlpha(25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: a.color.withAlpha(50)),
              ),
              child: Column(children: [
                Icon(a.icon, color: a.color, size: 26),
                const SizedBox(height: 6),
                Text(a.label,
                    style: TextStyle(fontSize: 11, color: a.color, fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
      )).toList(),
    );
  }
}

class _TodayAppointments extends StatelessWidget {
  final List appointments;
  final bool loading;
  const _TodayAppointments({required this.appointments, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: Padding(
        padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
    if (appointments.isEmpty) return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(child: Text(S.noAppointmentsToday,
          style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Cairo'))),
    );

    return Column(children: appointments.map((a) {
      final appt = a as Map;
      final patient = (appt['patient'] as Map?)?['user'] as Map? ?? {};
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              (patient['name'] as String? ?? '?').substring(0, 1),
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
          title: Text(patient['name'] as String? ?? 'مريض',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text(appt['scheduled_at'] != null
              ? _formatTime(appt['scheduled_at'] as String)
              : '', style: const TextStyle(fontSize: 12)),
          trailing: _statusBadge(appt['status'] as String? ?? ''),
          onTap: () => context.push('/appointments/${appt['id']}'),
        ),
      );
    }).toList());
  }

  String _formatTime(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _statusBadge(String status) {
    Color c; String label;
    switch (status) {
      case 'confirmed': c = AppColors.success; label = S.confirmed; break;
      case 'pending':   c = AppColors.warning; label = S.waitingStatus; break;
      default:          c = AppColors.textSecondary; label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _AssessmentCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: _AssessCard(
      title: 'NRS',
      subtitle: 'مقياس تقييم الألم',
      icon: Icons.monitor_heart_outlined,
      color: const Color(0xFF7C3AED),
      onTap: () => context.push('/assessment', extra: {'patientId': 0, 'type': 'nrs'}),
    )),
    const SizedBox(width: 12),
    Expanded(child: _AssessCard(
      title: 'ROM',
      subtitle: 'تقييم نطاق الحركة',
      icon: Icons.accessibility_new_rounded,
      color: AppColors.accent,
      onTap: () => context.push('/assessment', extra: {'patientId': 0, 'type': 'rom'}),
    )),
  ]);
}

class _AssessCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _AssessCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 10),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color, fontFamily: 'Cairo')),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo')),
      ]),
    ),
  );
}
