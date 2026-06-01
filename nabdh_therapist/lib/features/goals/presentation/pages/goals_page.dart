import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import 'goal_detail_page.dart';
import 'add_goal_page.dart';

/// Therapist: list of goals for a specific patient.
class GoalsPage extends StatefulWidget {
  final int patientId;
  final String patientName;

  const GoalsPage({
    required this.patientId,
    required this.patientName,
    super.key,
  });

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
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
      final r = await ApiClient.instance.get(
        '/therapist/goals',
        queryParameters: {'patient_id': widget.patientId},
      );
      setState(() {
        _goals = (r.data as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addGoal() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddGoalPage(
          patientId: widget.patientId,
          patientName: widget.patientName,
        ),
      ),
    );
    if (created == true) _load();
  }

  Color _statusColor(String status) {
    return switch (status) {
      'completed' => Colors.green,
      'cancelled' => AppColors.error,
      _ => AppColors.primary,
    };
  }

  String _statusLabel(String status) {
    return switch (status) {
      'completed' => 'مكتمل',
      'cancelled' => 'ملغى',
      _ => 'نشط',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('الأهداف العلاجية',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          Text(widget.patientName,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'إضافة هدف',
            onPressed: _addGoal,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addGoal,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('هدف جديد', style: TextStyle(color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _goals.isEmpty
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.track_changes_rounded, size: 64,
                            color: AppColors.textHint.withOpacity(0.4)),
                        const SizedBox(height: 12),
                        const Text('لا توجد أهداف بعد',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _addGoal,
                          child: const Text('إضافة أول هدف'),
                        ),
                      ]),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _goals.length,
                      itemBuilder: (_, i) {
                        final g = _goals[i];
                        final progress = (g['current_progress'] as num?)?.toInt() ?? 0;
                        final status = g['status'] as String? ?? 'active';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GoalDetailPage(
                                  goalId: (g['id'] as num).toInt(),
                                  goal: g,
                                  canEdit: true,
                                ),
                              ),
                            ).then((_) => _load()),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Expanded(
                                    child: Text(g['title'] as String? ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700, fontSize: 15)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _statusColor(status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(_statusLabel(status),
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: _statusColor(status))),
                                  ),
                                ]),
                                if ((g['description'] as String? ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(g['description'] as String,
                                      style: const TextStyle(
                                          fontSize: 13, color: AppColors.textSecondary),
                                      maxLines: 2, overflow: TextOverflow.ellipsis),
                                ],
                                const SizedBox(height: 12),
                                // Progress bar
                                Row(children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: progress / 100,
                                        backgroundColor: AppColors.border,
                                        color: _statusColor(status),
                                        minHeight: 8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text('$progress%',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: _statusColor(status))),
                                ]),
                                const SizedBox(height: 8),
                                Row(children: [
                                  const Icon(Icons.calendar_today_rounded,
                                      size: 13, color: AppColors.textHint),
                                  const SizedBox(width: 4),
                                  Text(
                                    'الموعد النهائي: ${g['effective_date'] ?? g['target_date'] ?? '—'}',
                                    style: const TextStyle(
                                        fontSize: 12, color: AppColors.textHint),
                                  ),
                                ]),
                              ]),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
