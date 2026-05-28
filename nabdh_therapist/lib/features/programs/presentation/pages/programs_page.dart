import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

class ProgramsPage extends StatefulWidget {
  const ProgramsPage({super.key});
  @override
  State<ProgramsPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends State<ProgramsPage> {
  List _programs = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get('/therapist/home-programs');
      setState(() { _programs = res.data is List ? res.data : (res.data['data'] ?? []); _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('حذف البرنامج'),
      content: const Text('هل تريد حذف هذا البرنامج؟'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
        TextButton(onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: AppColors.error))),
      ],
    ));
    if (ok == true) {
      await ApiClient.instance.delete('/therapist/home-programs/$id');
      _load();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: const Text('البرامج العلاجية')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => context.push('/programs/create').then((_) => _load()),
      icon: const Icon(Icons.add),
      label: const Text('برنامج جديد'),
      backgroundColor: AppColors.primary,
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _programs.isEmpty
            ? _empty()
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _programs.length,
                  itemBuilder: (_, i) {
                    final p = _programs[i] as Map;
                    final exercises = p['exercises'] as List? ?? [];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(child: Text(p['title'] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error),
                              onPressed: () => _delete(p['id'] as int),
                            ),
                          ]),
                          if (p['description'] != null) ...[
                            const SizedBox(height: 4),
                            Text(p['description'], style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                          const SizedBox(height: 10),
                          Row(children: [
                            _chip('${exercises.length} تمرين', Icons.fitness_center, AppColors.accent),
                            const SizedBox(width: 8),
                            if (p['patient'] != null)
                              _chip(p['patient']['full_name'] ?? '', Icons.person_outline, AppColors.primary),
                          ]),
                        ]),
                      ),
                    );
                  },
                ),
              ),
  );

  Widget _chip(String label, IconData icon, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    ]),
  );

  Widget _empty() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.fitness_center_outlined, size: 64, color: AppColors.border),
    const SizedBox(height: 16),
    const Text('لا توجد برامج علاجية', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
    const SizedBox(height: 8),
    const Text('أنشئ برنامجاً لمرضاك', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
  ]));
}
