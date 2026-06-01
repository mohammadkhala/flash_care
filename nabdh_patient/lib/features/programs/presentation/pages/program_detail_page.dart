import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/json_utils.dart';

class ProgramDetailPage extends StatefulWidget {
  final int id;
  const ProgramDetailPage({required this.id, super.key});

  @override
  State<ProgramDetailPage> createState() => _ProgramDetailPageState();
}

class _ProgramDetailPageState extends State<ProgramDetailPage> {
  Map<String, dynamic>? _program;
  bool _loading = true;
  final Set<int> _toggling = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get('/patient/home-programs/${widget.id}');
      if (!mounted) return;
      setState(() {
        _program = (res.data['program'] ?? res.data) as Map<String, dynamic>?;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleExercise(Map<String, dynamic> exercise, int index) async {
    final exerciseId = exercise['id'] as int?;
    if (exerciseId == null) return;
    if (_toggling.contains(exerciseId)) return;
    _toggling.add(exerciseId);
    final wasCompleted = exercise['completed'] == true;
    setState(() => exercise['completed'] = !wasCompleted);
    try {
      await ApiClient.instance.post('/patient/exercises/$exerciseId/complete');
    } on DioException catch (_) {
      // Revert on error
      if (mounted) setState(() => exercise['completed'] = wasCompleted);
    } finally {
      _toggling.remove(exerciseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final p = _program;
    if (p == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('البرنامج غير موجود')));

    final exercises = ((p['exercises'] as List?) ?? []).cast<Map<String, dynamic>>();
    final completed = exercises.where((e) => e['completed'] == true).length;
    final total = exercises.length;
    final progress = total > 0 ? completed / total : 0.0;
    final therapist = (p['therapist'] as Map<String, dynamic>?) ?? {};
    final startDate = p['start_date'] as String?;
    final endDate = p['end_date'] as String?;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(p['title'] as String? ?? 'البرنامج')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppGradients.card,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p['title'] as String? ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                if (therapist['full_name'] != null) ...[
                  const SizedBox(height: 4),
                  Text('الأخصائي: ${therapist['full_name']}',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                ],
                if (startDate != null || endDate != null) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.calendar_today_outlined, color: Colors.white70, size: 14),
                    const SizedBox(width: 6),
                    Text(_formatDateRange(startDate, endDate),
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                  ]),
                ],
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  )),
                  const SizedBox(width: 10),
                  Text('$completed/$total', style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                ]),
                const SizedBox(height: 4),
                Text('${(progress * 100).toInt()}% مكتمل',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
              ]),
            ),
            // Description
            if ((p['description'] as String? ?? '').isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('وصف البرنامج',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(p['description'] as String,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6)),
            ],
            // Exercises
            const SizedBox(height: 20),
            const Text('التمارين',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            if (exercises.isEmpty) const Center(
              child: Text('لا توجد تمارين في هذا البرنامج',
                style: TextStyle(color: AppColors.textHint)),
            ) else ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exercises.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _ExerciseCard(
                exercise: exercises[i],
                onToggle: () => _toggleExercise(exercises[i], i),
                isToggling: _toggling.contains(exercises[i]['id']),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  String _formatDateRange(String? start, String? end) {
    if (start == null) return '';
    try {
      final s = DateFormat('d MMM yyyy', 'ar').format(DateTime.parse(start));
      if (end == null) return s;
      final e = DateFormat('d MMM yyyy', 'ar').format(DateTime.parse(end));
      return '$s - $e';
    } catch (_) {
      return start;
    }
  }
}

class _ExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final VoidCallback onToggle;
  final bool isToggling;

  const _ExerciseCard({
    required this.exercise,
    required this.onToggle,
    required this.isToggling,
  });

  @override
  Widget build(BuildContext context) {
    final completed = exercise['completed'] == true;
    final title = exercise['title'] as String? ?? exercise['name'] as String? ?? 'تمرين';
    final description = exercise['description'] as String? ?? '';
    final String? duration = exercise['duration'] as String? ??
      (exercise['duration_minutes'] != null ? '${exercise['duration_minutes']} دقيقة' : null);
    final reps = jsonInt(exercise['repetitions'], jsonInt(exercise['reps']));

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: completed ? AppColors.successLight : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: completed ? AppColors.success.withOpacity(0.4) : AppColors.border),
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28, height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed ? AppColors.success : AppColors.borderLight,
            ),
            child: isToggling
              ? const Padding(padding: EdgeInsets.all(4),
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Icon(
                  completed ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                  color: completed ? Colors.white : AppColors.textHint,
                  size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(
              fontWeight: FontWeight.w700, fontSize: 14,
              color: completed ? AppColors.success : AppColors.textPrimary,
              decoration: completed ? TextDecoration.lineThrough : null)),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(description,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            Row(children: [
              if (duration != null) ...[
                const Icon(Icons.access_time, size: 12, color: AppColors.textHint),
                const SizedBox(width: 3),
                Text(duration, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                const SizedBox(width: 10),
              ],
              if (reps != null) ...[
                const Icon(Icons.repeat_rounded, size: 12, color: AppColors.textHint),
                const SizedBox(width: 3),
                Text('$reps تكرار', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
              ],
            ]),
          ])),
        ]),
      ),
    );
  }
}
