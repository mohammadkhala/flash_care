import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

class GoalDetailPage extends StatefulWidget {
  final int goalId;
  final Map<String, dynamic> goal;
  final bool canEdit;

  const GoalDetailPage({
    required this.goalId,
    required this.goal,
    this.canEdit = false,
    super.key,
  });

  @override
  State<GoalDetailPage> createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends State<GoalDetailPage> {
  late Map<String, dynamic> _goal;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _goal = widget.goal;
    _loadFresh();
  }

  Future<void> _loadFresh() async {
    try {
      final prefix = widget.canEdit ? '/therapist' : '/patient';
      final r = await ApiClient.instance.get('$prefix/goals/${widget.goalId}');
      if (mounted) setState(() => _goal = r.data as Map<String, dynamic>);
    } catch (_) {}
  }

  Future<void> _updateProgress() async {
    if (!widget.canEdit) return;

    double sliderValue = ((_goal['current_progress'] as num?)?.toDouble() ?? 0);
    final notesCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('تحديث التقدم',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${sliderValue.round()}%',
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.w900,
                    color: AppColors.primary)),
            Slider(
              value: sliderValue,
              min: 0, max: 100, divisions: 20,
              activeColor: AppColors.primary,
              onChanged: (v) => setDialogState(() => sliderValue = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('حفظ', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    try {
      await ApiClient.instance.post(
        '/therapist/goals/${widget.goalId}/progress',
        data: {
          'progress': sliderValue.round(),
          'notes': notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
        },
      );
      await _loadFresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذّر التحديث: $e'),
              backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _extendDate() async {
    if (!widget.canEdit) return;

    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      locale: const Locale('ar'),
      helpText: 'تمديد إلى تاريخ',
    );
    if (d == null || !mounted) return;

    try {
      await ApiClient.instance.put('/therapist/goals/${widget.goalId}', data: {
        'extended_date': '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}',
      });
      await _loadFresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تمديد الهدف ✅')));
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final progress = ((_goal['current_progress'] as num?)?.toInt() ?? 0);
    final status   = _goal['status'] as String? ?? 'active';
    final logs     = (_goal['progress_logs'] as List? ?? []).cast<Map<String, dynamic>>();
    final isCompleted = status == 'completed';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('تفاصيل الهدف',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          if (widget.canEdit && !isCompleted)
            TextButton.icon(
              onPressed: _extendDate,
              icon: const Icon(Icons.calendar_month_rounded, size: 18),
              label: const Text('تمديد'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ── Header card ──────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(
                        child: Text(_goal['title'] as String? ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 18)),
                      ),
                      _StatusBadge(status: status),
                    ]),
                    if ((_goal['description'] as String? ?? '').isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(_goal['description'] as String,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 14, height: 1.6)),
                    ],
                    const SizedBox(height: 16),
                    Row(children: [
                      const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textHint),
                      const SizedBox(width: 6),
                      Text(
                        'الموعد النهائي: ${_goal['effective_date'] ?? _goal['target_date'] ?? '—'}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      if (_goal['extended_date'] != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('ممتد',
                              style: TextStyle(fontSize: 11, color: Colors.orange,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ]),
                  ]),
                ),
                const SizedBox(height: 16),

                // ── Progress meter ───────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(children: [
                    Row(children: [
                      const Icon(Icons.percent_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      const Text('نسبة الإنجاز',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      const Spacer(),
                      Text('$progress%',
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 22,
                              color: AppColors.primary)),
                    ]),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: AppColors.border,
                        color: isCompleted ? Colors.green : AppColors.primary,
                        minHeight: 16,
                      ),
                    ),
                    if (widget.canEdit && !isCompleted) ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _updateProgress,
                        icon: const Icon(Icons.edit_rounded, color: Colors.white),
                        label: const Text('تحديث التقدم',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ]),
                ),
                const SizedBox(height: 16),

                // ── Progress chart ───────────────────────────────
                if (logs.length >= 2) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Row(children: [
                        Icon(Icons.show_chart_rounded, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text('مسار التقدم',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      ]),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 180,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: true, drawVerticalLine: false),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                  getTitlesWidget: (v, _) {
                                    final i = v.toInt();
                                    if (i < 0 || i >= logs.length) return const SizedBox();
                                    final dt = logs[i]['created_at'] as String? ?? '';
                                    final parts = dt.split(' ').first.split('-');
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(parts.length >= 2
                                          ? '${parts[2]}/${parts[1]}' : '',
                                          style: const TextStyle(fontSize: 9)),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 36,
                                  getTitlesWidget: (v, _) =>
                                      Text('${v.toInt()}%',
                                          style: const TextStyle(fontSize: 10)),
                                ),
                              ),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
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
                                color: AppColors.primary,
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppColors.primary.withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Progress logs ────────────────────────────────
                if (logs.isNotEmpty) ...[
                  const Row(children: [
                    Icon(Icons.history_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text('سجل التقدم',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  ]),
                  const SizedBox(height: 10),
                  ...logs.map((l) {
                    final p = (l['progress'] as num?)?.toInt() ?? 0;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(children: [
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text('$p%',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, children: [
                            if ((l['notes'] as String? ?? '').isNotEmpty)
                              Text(l['notes'] as String,
                                  style: const TextStyle(fontSize: 13)),
                            Text(
                              (l['created_at'] as String? ?? '').split(' ').first,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textHint),
                            ),
                          ])),
                        ]),
                      ),
                    );
                  }),
                ],

                const SizedBox(height: 40),
              ]),
            ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'completed' => ('مكتمل', Colors.green),
      'cancelled' => ('ملغى', AppColors.error),
      _ => ('نشط', AppColors.primary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
