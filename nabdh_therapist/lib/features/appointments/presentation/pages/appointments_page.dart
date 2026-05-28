import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});
  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _statuses = [null, 'pending', 'confirmed', 'completed', 'cancelled_by_therapist'];
  final _labels   = ['الكل', 'انتظار', 'مؤكدة', 'مكتملة', 'ملغية'];
  List _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _labels.length, vsync: this);
    // Belt-and-suspenders: listen for settled state AND handle via onTap
    _tab.addListener(() {
      if (!_tab.indexIsChanging) _load();
    });
    _load();
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final s = _statuses[_tab.index];
      final res = await ApiClient.instance.get('/therapist/appointments',
          queryParameters: s != null ? {'status': s} : null);
      final data = res.data;
      setState(() {
        _list = data is List ? data : (data['data'] ?? []);
        _loading = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: NestedScrollView(
      headerSliverBuilder: (_, __) => [
        SliverAppBar(
          pinned: true,
          floating: true,
          expandedHeight: 110,
          backgroundColor: AppColors.surface,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
              ),
              child: const SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text('المواعيد',
                      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: AppColors.surface,
              child: TabBar(
                controller: _tab,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                onTap: (_) => _load(),
                tabs: _labels.map((l) => Tab(text: l)).toList(),
              ),
            ),
          ),
        ),
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
              ? RefreshIndicator(onRefresh: _load, child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(height: 400, child: _empty())))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                    itemCount: _list.length,
                    itemBuilder: (_, i) => _AppCard(
                      apt: _list[i] as Map,
                      onTap: () => context.push('/appointments/${(_list[i] as Map)['id']}').then((_) => _load()),
                    ),
                  ),
                ),
    ),
  );

  Widget _empty() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(width: 90, height: 90,
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.06), shape: BoxShape.circle),
      child: const Icon(Icons.calendar_today_outlined, size: 44, color: AppColors.primary)),
    const SizedBox(height: 16),
    const Text('لا توجد مواعيد', style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
  ]));
}

class _AppCard extends StatelessWidget {
  final Map apt;
  final VoidCallback onTap;
  const _AppCard({required this.apt, required this.onTap});

  static const _statusConfig = {
    'pending':   ('بانتظار التأكيد', AppColors.warningLight, Color(0xFFFFF8E1), Icons.pending_outlined),
    'confirmed': ('مؤكد',           AppColors.primary,      Color(0xFFE3F2FD), Icons.event_available_rounded),
    'completed': ('مكتمل',          AppColors.successLight,  Color(0xFFE8F5E9), Icons.done_all_rounded),
  };

  @override
  Widget build(BuildContext context) {
    final patient   = apt['patient'] as Map?;
    final scheduled = DateTime.tryParse(apt['scheduled_at'] as String? ?? '');
    final status    = apt['status'] as String? ?? '';
    final name      = (patient?['full_name'] ?? patient?['user']?['name'] ?? 'مريض') as String;
    final isOnline  = apt['type'] == 'online';

    final cfg = _statusConfig[status] ?? ('ملغي', AppColors.errorLight, const Color(0xFFFFEBEE), Icons.cancel_outlined);
    final color = cfg.$2;
    final bg    = cfg.$3;
    final icon  = cfg.$4;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              // Avatar with color accent
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withOpacity(0.7), AppColors.primaryLight],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Text(name.isNotEmpty ? name[0] : '؟',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20))),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      overflow: TextOverflow.ellipsis)),
                  if (isOnline)
                    Container(margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.videocam_rounded, size: 11, color: AppColors.accent),
                        SizedBox(width: 3),
                        Text('أونلاين', style: TextStyle(fontSize: 10, color: AppColors.accent, fontWeight: FontWeight.w700)),
                      ])),
                ]),
                const SizedBox(height: 5),
                if (scheduled != null)
                  Row(children: [
                    const Icon(Icons.schedule_rounded, size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(DateFormat('dd/MM/yyyy  hh:mm a').format(scheduled),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ]),
                const SizedBox(height: 8),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(icon, size: 12, color: color),
                    const SizedBox(width: 4),
                    Text(cfg.$1, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ])),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary, size: 22),
            ]),
          ),
        ),
      ),
    );
  }
}
