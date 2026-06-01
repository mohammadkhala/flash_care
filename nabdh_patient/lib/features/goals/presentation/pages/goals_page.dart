import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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

                // Chart
                if (logs.length >= 2) ...[
                  const Text('مسار التقدم',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 150,
                    child: LineChart(LineChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: const FlTitlesData(
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (v, _) => Text('${v.toInt()}%',
                              style: const TextStyle(fontSize: 9)),
                        )),
                      ),
                      minY: 0, maxY: 100,
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            const FlSpot(0, 0),
                            ...logs.reversed.toList().asMap().entries.map(
                              (e) => FlSpot(
                                (e.key + 1).toDouble(),
                                ((e.value['progress'] as num?)?.toDouble() ?? 0),
                              ),
                            ),
                          ],
                          isCurved: true,
                          color: color,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: color.withOpacity(0.1),
                          ),
                        ),
                      ],
                    )),
                  ),
                  const SizedBox(height: 20),
                ],

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
