import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

/// Patient: view their therapeutic goals set by their therapist.
class PatientGoalsPage extends StatefulWidget {
  const PatientGoalsPage({super.key});

  @override
  State<PatientGoalsPage> createState() => _PatientGoalsPageState();
}

class _PatientGoalsPageState extends State<PatientGoalsPage> {
  List<Map<String, dynamic>> _goals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiClient.instance.get('/patient/goals');
      setState(() {
        _goals = (r.data as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) => switch (status) {
    'completed' => Colors.green,
    'cancelled' => AppColors.error,
    _ => AppColors.primary,
  };

  String _statusLabel(String status) => switch (status) {
    'completed' => 'مكتمل ✅',
    'cancelled' => 'ملغى',
    _ => 'نشط',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('أهدافي العلاجية 🎯',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _goals.isEmpty
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.track_changes_rounded, size: 72,
                            color: AppColors.textHint.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        const Text('لا توجد أهداف بعد',
                            style: TextStyle(
                                fontSize: 16, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        const Text('سيضع معالجك أهدافاً علاجية تخصك هنا',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textHint)),
                      ]),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _goals.length,
                      itemBuilder: (_, i) {
                        final g = _goals[i];
                        return _GoalCard(goal: g, onTap: () => _showDetail(g));
                      },
                    ),
            ),
    );
  }

  void _showDetail(Map<String, dynamic> goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GoalDetailSheet(goal: goal),
    );
  }
}

// ─── Goal Card ───────────────────────────────────────────────────────────────
class _GoalCard extends StatelessWidget {
  final Map<String, dynamic> goal;
  final VoidCallback onTap;

  const _GoalCard({required this.goal, required this.onTap});

  Color _color(String s) => switch (s) {
    'completed' => Colors.green,
    'cancelled' => AppColors.error,
    _ => AppColors.primary,
  };

  @override
  Widget build(BuildContext context) {
    final progress = ((goal['current_progress'] as num?)?.toInt() ?? 0);
    final status = goal['status'] as String? ?? 'active';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: _color(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text('$progress%',
                      style: TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 13,
                          color: _color(status))),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(goal['title'] as String? ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                if ((goal['therapist_name'] as String? ?? '').isNotEmpty)
                  Text('من: ${goal['therapist_name']}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ])),
              if (status == 'completed')
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
            ]),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: AppColors.border,
                color: _color(status),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 12, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(
                'حتى: ${goal['effective_date'] ?? goal['target_date'] ?? '—'}',
                style: const TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
              const Spacer(),
              const Text('اضغط للتفاصيل',
                  style: TextStyle(fontSize: 11, color: AppColors.primary)),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 11, color: AppColors.primary),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ─── Progress Chart ──────────────────────────────────────────────────────────
class _ProgressChart extends StatelessWidget {
  final List<Map<String, dynamic>> logs;
  final int progress;
  final Color color;

  const _ProgressChart({
    required this.logs,
    required this.progress,
    required this.color,
  });

  // Arabic month names
  static const _arMonths = [
    '', 'يناير', 'فبراير', 'مارس', 'إبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  String _arDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_arMonths[d.month]}';

  @override
  Widget build(BuildContext context) {
    // ── Build (timestamp, progress) pairs ──────────────────────────
    // Sort logs oldest→newest
    final sortedLogs = [...logs]..sort((a, b) {
        final da = DateTime.tryParse(a['created_at'] as String? ?? '') ?? DateTime(2000);
        final db = DateTime.tryParse(b['created_at'] as String? ?? '') ?? DateTime(2000);
        return da.compareTo(db);
      });

    // Collect data points: start with (goalCreatedAt or first log, 0), then each log
    final List<(DateTime date, double pct)> points = [];

    // First point: before the earliest log = 0%
    final firstLogDate = sortedLogs.isNotEmpty
        ? (DateTime.tryParse(sortedLogs.first['created_at'] as String? ?? '') ?? DateTime.now())
        : DateTime.now();
    points.add((firstLogDate.subtract(const Duration(days: 1)), 0));

    for (final log in sortedLogs) {
      final d = DateTime.tryParse(log['created_at'] as String? ?? '');
      final p = ((log['progress'] as num?)?.toDouble() ?? 0);
      if (d != null) points.add((d, p));
    }

    // Last point: today = current progress
    if (points.length < 2 || points.last.$2 != progress.toDouble()) {
      points.add((DateTime.now(), progress.toDouble()));
    }

    if (points.isEmpty) return const SizedBox.shrink();

    // Convert dates to numeric X axis (days since first point)
    final origin = points.first.$1;
    final spots = points.map((p) {
      final x = p.$1.difference(origin).inHours / 24.0;
      return FlSpot(x, p.$2);
    }).toList();

    final maxX = spots.last.x;
    final minY = 0.0;
    final maxY = 100.0;

    // Choose visible X-axis labels (at most 5)
    final labelIndices = <int>[];
    if (points.length <= 5) {
      labelIndices.addAll(List.generate(points.length, (i) => i));
    } else {
      final step = (points.length - 1) / 4;
      for (int i = 0; i < 5; i++) {
        labelIndices.add((i * step).round().clamp(0, points.length - 1));
      }
    }
    final labelX = {for (final i in labelIndices) spots[i].x: points[i].$1};

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Header ────────────────────────────────────────────────────
      Row(children: [
        const Text('مسار التقدم',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('$progress%',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800, color: color)),
        ),
      ]),
      const SizedBox(height: 12),

      // ── Chart ─────────────────────────────────────────────────────
      Container(
        height: 200,
        padding: const EdgeInsets.only(top: 12, right: 8, bottom: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.08)),
        ),
        child: LineChart(
          duration: const Duration(milliseconds: 600),
          LineChartData(
            clipData: const FlClipData.all(),
            minX: 0, maxX: maxX == 0 ? 1 : maxX,
            minY: minY, maxY: maxY,

            // ── Grid ────────────────────────────────────────────────
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              drawHorizontalLine: true,
              horizontalInterval: 25,
              verticalInterval: maxX == 0 ? 1 : maxX / 4,
              getDrawingHorizontalLine: (_) => FlLine(
                color: color.withOpacity(0.07),
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
              getDrawingVerticalLine: (_) => FlLine(
                color: color.withOpacity(0.04),
                strokeWidth: 1,
              ),
            ),

            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(color: color.withOpacity(0.15), width: 1),
                left:   BorderSide(color: color.withOpacity(0.15), width: 1),
              ),
            ),

            // ── Axes ────────────────────────────────────────────────
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

              // X-axis: dates
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: maxX == 0 ? 1 : maxX / 4,
                  getTitlesWidget: (x, meta) {
                    // Find the closest label
                    DateTime? dt;
                    double bestDist = double.infinity;
                    for (final entry in labelX.entries) {
                      final dist = (entry.key - x).abs();
                      if (dist < bestDist) {
                        bestDist = dist;
                        dt = entry.value;
                      }
                    }
                    if (dt == null || bestDist > 0.5) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _arDate(dt),
                        style: TextStyle(
                          fontSize: 9,
                          color: color.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Y-axis: percentages
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 38,
                  interval: 25,
                  getTitlesWidget: (v, _) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      '${v.toInt()}%',
                      style: TextStyle(
                        fontSize: 9,
                        color: color.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Tooltip ─────────────────────────────────────────────
            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => color.withOpacity(0.9),
                tooltipRoundedRadius: 10,
                getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                  final xi = s.x;
                  // Find closest real point date
                  DateTime? dt;
                  double bestDist = double.infinity;
                  for (final p in points) {
                    final px = p.$1.difference(origin).inHours / 24.0;
                    final dist = (px - xi).abs();
                    if (dist < bestDist) { bestDist = dist; dt = p.$1; }
                  }
                  final dateStr = dt != null ? _arDate(dt) : '';
                  return LineTooltipItem(
                    '${s.y.toInt()}%\n',
                    const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                    children: [
                      TextSpan(
                        text: dateStr,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),

            // ── Line data ───────────────────────────────────────────
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.3,
                color: color,
                barWidth: 2.5,
                isStrokeCapRound: true,
                preventCurveOverShooting: true,

                // Dots: show only on data points, larger on last
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, pct, bar, idx) {
                    final isLast = idx == spots.length - 1;
                    return FlDotCirclePainter(
                      radius: isLast ? 5.5 : 3.5,
                      color: isLast ? color : Colors.white,
                      strokeWidth: 2,
                      strokeColor: color,
                    );
                  },
                ),

                // Gradient fill below line — exactly like the reference image
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withOpacity(0.28),
                      color.withOpacity(0.08),
                      color.withOpacity(0.01),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}

// ─── Detail Bottom Sheet ─────────────────────────────────────────────────────
class _GoalDetailSheet extends StatelessWidget {
  final Map<String, dynamic> goal;

  const _GoalDetailSheet({required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = ((goal['current_progress'] as num?)?.toInt() ?? 0);
    final logs = (goal['progress_logs'] as List? ?? []).cast<Map<String, dynamic>>();
    final status = goal['status'] as String? ?? 'active';
    final color = switch (status) {
      'completed' => Colors.green,
      'cancelled' => AppColors.error,
      _ => AppColors.primary,
    };

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.all(20),
              children: [
                Text(goal['title'] as String? ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 20)),
                const SizedBox(height: 4),
                if ((goal['description'] as String? ?? '').isNotEmpty)
                  Text(goal['description'] as String,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 14, height: 1.6)),
                const SizedBox(height: 20),

                // Big progress circle (using a stack + arc)
                Center(child: SizedBox(
                  width: 140, height: 140,
                  child: Stack(alignment: Alignment.center, children: [
                    CircularProgressIndicator(
                      value: progress / 100,
                      strokeWidth: 12,
                      backgroundColor: AppColors.border,
                      color: color,
                    ),
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('$progress%',
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w900, color: color)),
                      Text(switch (status) {
                        'completed' => 'مكتمل',
                        'cancelled' => 'ملغى',
                        _ => 'تقدم',
                      }, style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                    ]),
                  ]),
                )),
                const SizedBox(height: 24),

                // ── Progress Chart ──────────────────────────────────────
                _ProgressChart(logs: logs, progress: progress, color: color),
                const SizedBox(height: 20),

                // Log history
                if (logs.isNotEmpty) ...[
                  const Text('تحديثات المعالج',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 10),
                  ...logs.map((l) {
                    final p = (l['progress'] as num?)?.toInt() ?? 0;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: color.withOpacity(0.1),
                        child: Text('$p%',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, color: color,
                                fontSize: 11)),
                      ),
                      title: Text(
                        (l['notes'] as String? ?? '').isNotEmpty
                            ? l['notes'] as String
                            : 'تحديث تقدم',
                        style: const TextStyle(fontSize: 13),
                      ),
                      subtitle: Text(
                        (l['created_at'] as String? ?? '').split(' ').first,
                        style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
