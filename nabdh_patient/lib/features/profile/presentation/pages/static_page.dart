import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

/// Fetches and renders a CMS page (terms | privacy) from the backend.
class StaticPage extends StatefulWidget {
  final String slug;
  const StaticPage({required this.slug, super.key});

  @override
  State<StaticPage> createState() => _StaticPageState();
}

class _StaticPageState extends State<StaticPage> {
  Map<String, dynamic>? _page;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiClient.instance.get('/pages/${widget.slug}');
      setState(() { _page = res.data as Map<String, dynamic>?; _loading = false; });
    } catch (_) {
      setState(() { _error = 'تعذّر تحميل الصفحة'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final title   = _page?['title_$locale']   ?? _page?['title_ar']   ?? '';
    final content = _page?['content_$locale'] ?? _page?['content_ar'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title.isNotEmpty ? title : (widget.slug == 'terms' ? 'شروط الاستخدام' : 'سياسة الخصوصية')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.cloud_off_rounded, size: 56, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(onPressed: _load,
                      icon: const Icon(Icons.refresh_rounded), label: const Text('إعادة المحاولة')),
                ]))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: content.isNotEmpty
                      ? _HtmlContent(html: content)
                      : const Center(child: Text('لا يوجد محتوى',
                          style: TextStyle(color: AppColors.textSecondary))),
                ),
    );
  }
}

/// Renders HTML using flutter_html if available, otherwise plain text fallback.
class _HtmlContent extends StatelessWidget {
  final String html;
  const _HtmlContent({required this.html});

  @override
  Widget build(BuildContext context) {
    // Use a simple approach: parse basic HTML tags manually
    // (avoids adding flutter_html dependency)
    return _SimpleHtmlRenderer(html: html);
  }
}

class _SimpleHtmlRenderer extends StatelessWidget {
  final String html;
  const _SimpleHtmlRenderer({required this.html});

  @override
  Widget build(BuildContext context) {
    // Strip HTML tags and render as formatted text sections
    final sections = _parseHtml(html);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((s) => _renderSection(s)).toList(),
    );
  }

  List<_HtmlSection> _parseHtml(String html) {
    final List<_HtmlSection> result = [];
    final regex = RegExp(r'<(h[23]|p|li|ul)[^>]*>(.*?)<\/\1>', dotAll: true);
    for (final match in regex.allMatches(html)) {
      final tag  = match.group(1) ?? 'p';
      final text = match.group(2)?.replaceAll(RegExp(r'<[^>]+>'), '').trim() ?? '';
      if (text.isNotEmpty) result.add(_HtmlSection(tag: tag, text: text));
    }
    if (result.isEmpty) {
      final plain = html.replaceAll(RegExp(r'<[^>]+>'), '').trim();
      if (plain.isNotEmpty) result.add(_HtmlSection(tag: 'p', text: plain));
    }
    return result;
  }

  Widget _renderSection(_HtmlSection s) {
    switch (s.tag) {
      case 'h2':
        return Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(s.text, style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
        );
      case 'h3':
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(s.text, style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        );
      case 'li':
        return Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(
              padding: EdgeInsets.only(top: 6, left: 8),
              child: Icon(Icons.circle, size: 6, color: AppColors.primary)),
            Expanded(child: Text(s.text,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.7))),
          ]),
        );
      default:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(s.text,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary, height: 1.8)),
        );
    }
  }
}

class _HtmlSection {
  final String tag, text;
  const _HtmlSection({required this.tag, required this.text});
}
