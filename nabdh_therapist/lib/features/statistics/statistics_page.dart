import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/json_utils.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});
  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  Map _stats = {};
  bool _loading = true;
  int _touchedDonut = -1;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _load();
  }

  @override
  void dispose() { _animCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get('/therapist/statistics');
      final data = res.data['statistics'] ?? res.data;
      setState(() { _stats = data as Map; _loading = false; });
      _animCtrl.forward(from: 0);
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _load,
            child: CustomScrollView(physics: const AlwaysScrollableScrollPhysics(), slivers: [
              _appBar(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                sliver: SliverList(delegate: SliverChildListDelegate([
                  FadeTransition(opacity: _fadeAnim, child: Column(children: [
                    const SizedBox(height: 16),
                    _kpiRow(),
                    const SizedBox(height: 20),
                    _completionCard(),
                    const SizedBox(height: 20),
                    _monthlyBarChart(),
                    const SizedBox(height: 20),
                    _donutAndWeekly(),
                    const SizedBox(height: 20),
                    _ratingCard(),
                  ])),
                ])),
              ),
            ]),
          ),
  );

  Widget _appBar() => SliverAppBar(
    expandedHeight: 140,
    pinned: true,
    flexibleSpace: FlexibleSpaceBar(
      background: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D3B52), AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('الإحصائيات', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('نظرة شاملة على أدائك', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
          ]),
        )),
      ),
    ),
  );

  // ── KPI row ─────────────────────────────────────────────────
  Widget _kpiRow() => Row(children: [
    Expanded(child: _kpi('${_stats['total_appointments'] ?? 0}', 'إجمالي المواعيد',
        Icons.event_note_rounded, AppColors.primary, const Color(0xFFE3F2FD))),
    const SizedBox(width: 10),
    Expanded(child: _kpi('${_stats['total_patients'] ?? 0}', 'المرضى',
        Icons.people_alt_rounded, const Color(0xFF7C3AED), const Color(0xFFF3E8FF))),
    const SizedBox(width: 10),
    Expanded(child: _kpi('${_stats['completion_rate'] ?? 0}%', 'معدل الإنجاز',
        Icons.verified_rounded, AppColors.success, const Color(0xFFE8F5E9))),
  ]);

  Widget _kpi(String val, String lbl, IconData icon, Color fg, Color bg) => AnimatedContainer(
    duration: const Duration(milliseconds: 400),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18)),
    child: Column(children: [
      Container(padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: fg.withOpacity(0.15), shape: BoxShape.circle),
        child: Icon(icon, color: fg, size: 22)),
      const SizedBox(height: 8),
      Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: fg)),
      const SizedBox(height: 2),
      Text(lbl, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          textAlign: TextAlign.center, maxLines: 2),
    ]),
  );

  // ── Completion rate big card ─────────────────────────────────
  Widget _completionCard() {
    final rate = jsonDouble(_stats['completion_rate']);
    final thisMonth = _stats['this_month_appointments'] ?? 0;
    final lastMonth = _stats['last_month_appointments'] ?? 0;
    final diff = thisMonth - lastMonth;
    final isUp = diff >= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF0D3B52)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('هذا الشهر', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text('$thisMonth موعد', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Row(children: [
            Icon(isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: isUp ? Colors.greenAccent : Colors.redAccent, size: 16),
            const SizedBox(width: 4),
            Text('${diff.abs()} ${isUp ? 'أكثر' : 'أقل'} من الشهر الماضي',
                style: TextStyle(color: isUp ? Colors.greenAccent : Colors.redAccent, fontSize: 12)),
          ]),
        ])),
        const SizedBox(width: 20),
        SizedBox(width: 90, height: 90, child: Stack(alignment: Alignment.center, children: [
          PieChart(PieChartData(
            sectionsSpace: 0,
            centerSpaceRadius: 32,
            sections: [
              PieChartSectionData(value: rate, color: Colors.greenAccent, radius: 10, showTitle: false),
              PieChartSectionData(value: 100 - rate, color: Colors.white24, radius: 10, showTitle: false),
            ],
          )),
          Text('${rate.toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
        ])),
      ]),
    );
  }

  // ── Monthly bar chart ────────────────────────────────────────
  Widget _monthlyBarChart() {
    final monthly = _stats['monthly_chart'] as List? ?? [];
    const shortMonths = ['','يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];

    return _sectionCard(
      title: 'الجلسات الشهرية',
      subtitle: 'آخر 6 أشهر',
      icon: Icons.bar_chart_rounded,
      iconColor: AppColors.primary,
      child: SizedBox(height: 180, child: monthly.isEmpty
          ? _emptyChart('لا توجد بيانات بعد')
          : BarChart(BarChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(color: AppColors.border, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true, reservedSize: 28,
                  getTitlesWidget: (v, _) {
                    final idx = v.toInt();
                    if (idx < 0 || idx >= monthly.length) return const SizedBox.shrink();
                    final m = (monthly[idx] as Map)['month'] as int? ?? 0;
                    return Padding(padding: const EdgeInsets.only(top: 6),
                      child: Text(m > 0 && m <= 12 ? shortMonths[m].substring(0, 3) : '',
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)));
                  },
                )),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: List.generate(monthly.length, (i) {
                final count = jsonInt((monthly[i] as Map)['count']);
                return BarChartGroupData(x: i, barRods: [BarChartRodData(
                  toY: count.toDouble(),
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.primary],
                    begin: Alignment.bottomCenter, end: Alignment.topCenter,
                  ),
                  width: 22,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                )]);
              }),
            )),
      ),
    );
  }

  // ── Donut + weekly side by side ──────────────────────────────
  Widget _donutAndWeekly() => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Expanded(child: _donutCard()),
    const SizedBox(width: 12),
    Expanded(child: _weeklyCard()),
  ]);

  Widget _donutCard() {
    final breakdown = _stats['status_breakdown'] as List? ?? [];
    final total = breakdown.fold<int>(0, (s, e) => s + ((e as Map)['count'] as int? ?? 0));

    final colorMap = {
      '4CAF50': AppColors.success,
      '1B5E7B': AppColors.primary,
      'FF9800': AppColors.warning,
      'E53935': AppColors.error,
    };

    return _sectionCard(
      title: 'توزيع\nالمواعيد',
      subtitle: '',
      icon: Icons.donut_large_rounded,
      iconColor: const Color(0xFF7C3AED),
      child: Column(children: [
        SizedBox(height: 130, child: PieChart(PieChartData(
          sectionsSpace: 3,
          centerSpaceRadius: 36,
          pieTouchData: PieTouchData(touchCallback: (e, r) {
            setState(() => _touchedDonut = r?.touchedSection?.touchedSectionIndex ?? -1);
          }),
          sections: List.generate(breakdown.length, (i) {
            final item = breakdown[i] as Map;
            final count = (item['count'] as int?) ?? 0;
            final colorHex = item['color'] as String? ?? '';
            final color = colorMap[colorHex] ?? AppColors.textSecondary;
            final isTouched = _touchedDonut == i;
            return PieChartSectionData(
              value: count.toDouble(),
              color: color,
              radius: isTouched ? 36 : 28,
              showTitle: isTouched,
              title: '${count > 0 && total > 0 ? (count * 100 ~/ total) : 0}%',
              titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
            );
          }),
        ))),
        const SizedBox(height: 8),
        ...breakdown.map((b) {
          final item = b as Map;
          final colorHex = item['color'] as String? ?? '';
          final color = colorMap[colorHex] ?? AppColors.textSecondary;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Expanded(child: Text(item['label'] ?? '', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
              Text('${item['count'] ?? 0}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _weeklyCard() {
    final weekly = _stats['weekly_chart'] as List? ?? [];
    final maxVal = weekly.fold<double>(1, (m, e) {
      final count = jsonDouble((e as Map)['count']);
      return count > m ? count : m;
    });

    return _sectionCard(
      title: 'الأداء\nالأسبوعي',
      subtitle: '',
      icon: Icons.stacked_bar_chart_rounded,
      iconColor: AppColors.accent,
      child: Column(children: [
        ...weekly.asMap().entries.map((e) {
          final item = e.value as Map;
          final count = jsonInt(item['count']);
          final pct = maxVal > 0 ? count / maxVal : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(item['week'] as String? ?? '', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary))),
                Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ]),
              const SizedBox(height: 4),
              ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(
                value: pct,
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(
                  e.key == weekly.length - 1 ? AppColors.accent : AppColors.primary,
                ),
              )),
            ]),
          );
        }),
      ]),
    );
  }

  // ── Rating card ──────────────────────────────────────────────
  Widget _ratingCard() {
    final avg = jsonDouble(_stats['rating_average']);
    final count = _stats['rating_count'] ?? 0;
    final dist = _stats['rating_distribution'] as List? ?? [];

    return _sectionCard(
      title: 'تقييمات المرضى',
      subtitle: 'من $count تقييم',
      icon: Icons.star_rounded,
      iconColor: Colors.amber,
      child: Row(children: [
        Column(children: [
          Text(avg.toStringAsFixed(1),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          Row(mainAxisSize: MainAxisSize.min, children: List.generate(5, (i) =>
            Icon(i < avg.round() ? Icons.star_rounded : Icons.star_border_rounded,
                color: Colors.amber, size: 18))),
          const SizedBox(height: 4),
          Text('من 5', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ]),
        const SizedBox(width: 20),
        Expanded(child: Column(children: dist.map((d) {
          final item = d as Map;
          final star = item['star'] as int? ?? 0;
          final pct = jsonDouble(item['percentage']);
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              Text('$star', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(width: 4),
              const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
              const SizedBox(width: 6),
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(
                value: pct / 100,
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(
                  star >= 4 ? Colors.amber : star == 3 ? Colors.orange : AppColors.error),
              ))),
              const SizedBox(width: 6),
              Text('${pct.toInt()}%', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ]),
          );
        }).toList())),
      ]),
    );
  }

  Widget _sectionCard({
    required String title, required String subtitle,
    required IconData icon, required Color iconColor,
    required Widget child,
  }) => Container(
    margin: const EdgeInsets.only(bottom: 0),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 18)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, height: 1.2)),
          if (subtitle.isNotEmpty)
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ])),
      ]),
      const SizedBox(height: 16),
      child,
    ]),
  );

  Widget _emptyChart(String msg) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.bar_chart_outlined, size: 48, color: AppColors.border),
    const SizedBox(height: 8),
    Text(msg, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
  ]));
}
