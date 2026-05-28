import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

class ProgramsPage extends StatefulWidget {
  const ProgramsPage({super.key});

  @override
  State<ProgramsPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends State<ProgramsPage> {
  List<Map<String, dynamic>> _programs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get('/patient/home-programs');
      if (!mounted) return;
      final list = (res.data as List?) ?? [];
      setState(() {
        _programs = list.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: const Text('برامجي')),
    body: _loading
      ? const Center(child: CircularProgressIndicator())
      : RefreshIndicator(
          onRefresh: _load,
          child: _programs.isEmpty
            ? ListView(children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.fitness_center_rounded, size: 64, color: AppColors.textHint),
                    SizedBox(height: 12),
                    Text('لا توجد برامج بعد',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                    SizedBox(height: 6),
                    Text('سيقوم أخصائيك بتعيين برامج لك',
                      style: TextStyle(color: AppColors.textHint, fontSize: 13)),
                  ])),
                ),
              ])
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _programs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _ProgramCard(program: _programs[i]),
              ),
        ),
  );
}

class _ProgramCard extends StatelessWidget {
  final Map<String, dynamic> program;
  const _ProgramCard({required this.program});

  @override
  Widget build(BuildContext context) {
    final id = program['id'];
    final exercises = (program['exercises'] as List?) ?? [];
    final completed = exercises.where((e) => (e as Map)['completed'] == true).length;
    final total = exercises.length;
    final progress = total > 0 ? completed / total : 0.0;
    final therapist = (program['therapist'] as Map<String, dynamic>?) ?? {};
    final startDate = program['start_date'] as String?;
    final endDate = program['end_date'] as String?;

    String dateRange = '';
    if (startDate != null) {
      try {
        final start = DateFormat('d MMM', 'ar').format(DateTime.parse(startDate));
        final end = endDate != null
          ? ' - ${DateFormat('d MMM', 'ar').format(DateTime.parse(endDate))}'
          : '';
        dateRange = '$start$end';
      } catch (_) {}
    }

    return GestureDetector(
      onTap: () => context.push('/programs/$id'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.fitness_center_rounded,
                color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(program['title'] as String? ?? '',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              if (therapist['full_name'] != null) Text(
                'من: ${therapist['full_name']}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ])),
            const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.textHint),
          ]),
          if (dateRange.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(dateRange, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
            ]),
          ],
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.borderLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 8,
              ),
            )),
            const SizedBox(width: 10),
            Text('$completed/$total', style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ]),
          const SizedBox(height: 4),
          Text('تمرين مكتمل من أصل $total',
            style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
        ]),
      ),
    );
  }
}
