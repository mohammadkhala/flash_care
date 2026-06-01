import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/l10n/s.dart';

String _resolveUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  return url.replaceAll('localhost', '192.168.1.3')
            .replaceAll('127.0.0.1', '192.168.1.3');
}

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<Map<String, dynamic>> _upcoming = [];
  List<Map<String, dynamic>> _past = [];
  bool _loadingUpcoming = true;
  bool _loadingPast = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadUpcoming();
    _loadPast();
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  Future<void> _loadUpcoming() async {
    setState(() => _loadingUpcoming = true);
    try {
      final res = await ApiClient.instance.get('/patient/appointments',
        queryParameters: {'per_page': 50});
      if (!mounted) return;
      final list = ((res.data['data'] ?? res.data) as List?) ?? [];
      final all = list.cast<Map<String, dynamic>>();
      setState(() {
        _upcoming = all.where((a) {
          final s = a['status'] as String? ?? '';
          return s == 'confirmed' || s == 'pending';
        }).toList();
        _loadingUpcoming = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingUpcoming = false);
    }
  }

  Future<void> _loadPast() async {
    setState(() => _loadingPast = true);
    try {
      final res = await ApiClient.instance.get('/patient/appointments',
        queryParameters: {'per_page': 50});
      if (!mounted) return;
      final list = ((res.data['data'] ?? res.data) as List?) ?? [];
      final all = list.cast<Map<String, dynamic>>();
      setState(() {
        _past = all.where((a) {
          final s = a['status'] as String? ?? '';
          return s == 'completed' || s == 'cancelled';
        }).toList();
        _loadingPast = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingPast = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: Text(S.appointments),
      bottom: TabBar(
        controller: _tabCtrl,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
        tabs: [Tab(text: S.upcoming), Tab(text: S.previous)],
      ),
    ),
    body: TabBarView(
      controller: _tabCtrl,
      children: [
        _AppointmentList(
          items: _upcoming,
          loading: _loadingUpcoming,
          onRefresh: _loadUpcoming,
          emptyText: S.noUpcomingAppts,
        ),
        _AppointmentList(
          items: _past,
          loading: _loadingPast,
          onRefresh: _loadPast,
          emptyText: S.noPreviousAppts,
        ),
      ],
    ),
  );
}

class _AppointmentList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final bool loading;
  final Future<void> Function() onRefresh;
  final String emptyText;

  const _AppointmentList({
    required this.items,
    required this.loading,
    required this.onRefresh,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: items.isEmpty
        ? ListView(children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.calendar_today_outlined,
                  size: 64, color: AppColors.textHint),
                const SizedBox(height: 12),
                Text(emptyText,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
              ])),
            ),
          ])
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _AppointmentCard(appointment: items[i]),
          ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final therapist = (appointment['therapist'] as Map<String, dynamic>?) ?? {};
    final avatar = _resolveUrl(therapist['avatar'] as String?);
    final status = appointment['status'] as String? ?? '';
    final type = appointment['type'] as String? ?? '';
    final scheduledAt = appointment['scheduled_at'] as String? ?? '';
    DateTime? dt;
    try { dt = DateTime.parse(scheduledAt); } catch (_) {}

    return GestureDetector(
      onTap: () => context.push('/appointments/${appointment['id']}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.surfaceAlt,
            backgroundImage: avatar.isNotEmpty ? CachedNetworkImageProvider(avatar) : null,
            child: avatar.isEmpty ? const Icon(Icons.person, size: 28, color: AppColors.textHint) : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(therapist['full_name'] as String? ?? 'الأخصائي',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 2),
            Text(therapist['title'] as String? ?? '',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            if (dt != null) Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(DateFormat('d MMM yyyy - HH:mm', 'ar').format(dt),
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              _TypeBadge(type: type),
              const SizedBox(width: 8),
              _StatusBadge(status: status),
            ]),
          ])),
          const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.textHint),
        ]),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isOnline = type == 'online';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOnline ? AppColors.primary.withOpacity(0.1) : AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(isOnline ? Icons.videocam_outlined : Icons.location_on_outlined,
          size: 12, color: isOnline ? AppColors.primary : AppColors.accent),
        const SizedBox(width: 4),
        Text(isOnline ? S.online : S.inPerson,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
            color: isOnline ? AppColors.primary : AppColors.accent)),
      ]),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case 'confirmed': return AppColors.success;
      case 'pending': return AppColors.warning;
      case 'completed': return AppColors.primary;
      case 'cancelled': return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  String get _label {
    switch (status) {
      case 'confirmed': return S.confirmed;
      case 'pending':   return S.pending;
      case 'completed': return S.statusCompleted;
      case 'cancelled': return S.statusCancelled;
      default:          return status;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: _color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(_label, style: TextStyle(
      fontSize: 11, fontWeight: FontWeight.w600, color: _color)),
  );
}
