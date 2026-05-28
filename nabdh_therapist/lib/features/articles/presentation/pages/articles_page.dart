import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});
  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  List _articles = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get('/therapist/articles');
      setState(() {
        _articles = res.data is List ? res.data : (res.data['data'] ?? []);
        _loading = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('حذف المقال'),
      content: const Text('هل تريد حذف هذا المقال؟'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
        TextButton(onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: AppColors.error))),
      ],
    ));
    if (ok == true) {
      await ApiClient.instance.delete('/therapist/articles/$id');
      _load();
    }
  }

  Future<void> _togglePublish(Map article) async {
    try {
      await ApiClient.instance.put('/therapist/articles/${article['id']}',
          data: {'is_published': !(article['is_published'] as bool? ?? false)});
      _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: const Text('المقالات التثقيفية')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => context.push('/articles/create').then((_) => _load()),
      icon: const Icon(Icons.add),
      label: const Text('مقال جديد'),
      backgroundColor: AppColors.primary,
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _articles.isEmpty
            ? _empty()
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _articles.length,
                  itemBuilder: (_, i) => _ArticleCard(
                    article: _articles[i] as Map,
                    onDelete: () => _delete((_articles[i] as Map)['id'] as int),
                    onToggle: () => _togglePublish(_articles[i] as Map),
                    onEdit: () => context.push('/articles/edit', extra: _articles[i]).then((_) => _load()),
                  ),
                ),
              ),
  );

  Widget _empty() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.article_outlined, size: 64, color: AppColors.border),
    const SizedBox(height: 16),
    const Text('لا توجد مقالات', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
    const SizedBox(height: 8),
    const Text('شارك معرفتك مع المرضى', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
  ]));
}

class _ArticleCard extends StatelessWidget {
  final Map article;
  final VoidCallback onDelete, onToggle, onEdit;
  const _ArticleCard({required this.article, required this.onDelete, required this.onToggle, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final published = article['is_published'] as bool? ?? false;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(article['title'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: published ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(published ? 'منشور' : 'مسودة',
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: published ? AppColors.success : AppColors.warning,
                    )),
              ),
            ]),
            if ((article['content'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(article['content'].toString().replaceAll('\n', ' '),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
            const SizedBox(height: 10),
            Row(children: [
              if (article['category'] != null)
                _chip(article['category'], Icons.label_outline, AppColors.accent),
              const SizedBox(width: 8),
              _chip('${article['views_count'] ?? 0} مشاهدة', Icons.visibility_outlined, AppColors.primary),
              const Spacer(),
              IconButton(
                icon: Icon(published ? Icons.unpublished_outlined : Icons.publish,
                    color: published ? AppColors.warning : AppColors.success, size: 20),
                onPressed: onToggle,
                tooltip: published ? 'إخفاء' : 'نشر',
                padding: EdgeInsets.zero, constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                onPressed: onDelete,
                padding: EdgeInsets.zero, constraints: const BoxConstraints(),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _chip(String label, IconData icon, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    ]),
  );
}
