import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/json_utils.dart';

class ColleaguesPage extends StatefulWidget {
  const ColleaguesPage({super.key});

  @override
  State<ColleaguesPage> createState() => _ColleaguesPageState();
}

class _ColleaguesPageState extends State<ColleaguesPage> {
  final _search = TextEditingController();
  List _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load([String? q]) async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get(
        '/therapist/colleagues',
        queryParameters: {
          if (q != null && q.trim().isNotEmpty) 'search': q.trim(),
          'per_page': 30,
        },
      );
      final raw = res.data;
      setState(() {
        _items = raw is List ? raw : (raw['data'] ?? []);
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _openChat(Map t) {
    final id = jsonInt(t['id']);
    final name = t['full_name'] as String? ?? 'أخصائي';
    if (id == 0) return;
    context.push('/messages/new', extra: {
      'name': name,
      'partnerId': id,
      'partnerType': 'therapist',
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: const Text('الأخصائيون'),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    body: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: TextField(
          controller: _search,
          textInputAction: TextInputAction.search,
          onSubmitted: _load,
          decoration: InputDecoration(
            hintText: 'ابحث بالاسم أو التخصص أو المدينة',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      Expanded(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
                ? const Center(child: Text('لا يوجد أخصائيون'))
                : RefreshIndicator(
                    onRefresh: () => _load(_search.text),
                    child: ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 80),
                      itemBuilder: (_, i) {
                        final t = _items[i] as Map;
                        final name = t['full_name'] as String? ?? 'أخصائي';
                        final title = t['title'] as String? ?? '';
                        final city = t['city'] as String? ?? '';
                        final specs = (t['specializations'] as List?)
                                ?.map((s) => (s as Map)['name_ar'] ?? '')
                                .where((s) => s.toString().isNotEmpty)
                                .join(' · ') ??
                            '';
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Text(
                              name.isNotEmpty ? name[0] : '؟',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(name,
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(
                            [title, city, specs]
                                .where((s) => s.toString().isNotEmpty)
                                .join(' · '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.chat_outlined,
                              color: AppColors.primary),
                          onTap: () => _openChat(t),
                        );
                      },
                    ),
                  ),
      ),
    ]),
  );
}
