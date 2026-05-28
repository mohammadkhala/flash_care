import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

class CreateArticlePage extends StatefulWidget {
  final Map? article; // non-null → edit mode
  const CreateArticlePage({this.article, super.key});
  @override
  State<CreateArticlePage> createState() => _CreateArticlePageState();
}

class _CreateArticlePageState extends State<CreateArticlePage> {
  final _titleCtrl   = TextEditingController();
  final _contentCtrl = TextEditingController();
  String _category   = 'عام';
  bool _published    = false;
  bool _saving       = false;
  File? _cover;

  static const _categories = ['عام', 'القلق', 'الاكتئاب', 'النوم', 'إدارة الضغط', 'العلاقات', 'تطوير الذات', 'الأطفال'];

  bool get _isEdit => widget.article != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _titleCtrl.text   = widget.article!['title'] ?? '';
      _contentCtrl.text = widget.article!['content'] ?? '';
      _category         = widget.article!['category'] ?? 'عام';
      _published        = widget.article!['is_published'] as bool? ?? false;
    }
  }

  @override
  void dispose() { _titleCtrl.dispose(); _contentCtrl.dispose(); super.dispose(); }

  Future<void> _pickCover() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 1200);
    if (img != null) setState(() => _cover = File(img.path));
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل عنوان المقال')));
      return;
    }
    if (_contentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل محتوى المقال')));
      return;
    }
    setState(() => _saving = true);
    try {
      String? coverPath;
      if (_cover != null) {
        final res = await ApiClient.multipartPost('/therapist/articles/cover', _cover!.path, 'cover');
        coverPath = res.data['cover_path'] as String?;
      }

      final data = {
        'title':        _titleCtrl.text.trim(),
        'content':      _contentCtrl.text.trim(),
        'category':     _category,
        'is_published': _published,
        if (coverPath != null) 'cover_image': coverPath,
      };

      if (_isEdit) {
        await ApiClient.instance.put('/therapist/articles/${widget.article!['id']}', data: data);
      } else {
        await ApiClient.instance.post('/therapist/articles', data: data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_isEdit ? 'تم تحديث المقال ✓' : 'تم نشر المقال ✓')));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error));
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: Text(_isEdit ? 'تعديل المقال' : 'مقال جديد'),
      leading: BackButton(onPressed: () => context.pop()),
      actions: [
        TextButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('حفظ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
        ),
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Cover image
        GestureDetector(
          onTap: _pickCover,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
              image: _cover != null
                  ? DecorationImage(image: FileImage(_cover!), fit: BoxFit.cover)
                  : null,
            ),
            child: _cover == null
                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: 8),
                    const Text('أضف صورة غلاف (اختياري)',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ])
                : Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: GestureDetector(
                        onTap: () => setState(() => _cover = null),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),

        // Title
        _lbl('عنوان المقال *'),
        TextField(
          controller: _titleCtrl,
          decoration: const InputDecoration(hintText: 'مثال: كيف تتغلب على القلق اليومي'),
          maxLength: 120,
        ),
        const SizedBox(height: 16),

        // Category
        _lbl('التصنيف'),
        DropdownButtonFormField<String>(
          value: _category,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            filled: true, fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) { if (v != null) setState(() => _category = v); },
        ),
        const SizedBox(height: 16),

        // Content
        _lbl('محتوى المقال *'),
        TextField(
          controller: _contentCtrl,
          maxLines: 15,
          maxLength: 5000,
          decoration: const InputDecoration(
            hintText: 'اكتب محتوى المقال هنا...',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),

        // Publish switch
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(children: [
            const Icon(Icons.public, color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            const Expanded(child: Text('نشر المقال', style: TextStyle(fontWeight: FontWeight.w600))),
            Switch.adaptive(
              value: _published,
              onChanged: (v) => setState(() => _published = v),
              activeColor: AppColors.primary,
            ),
          ]),
        ),
        const SizedBox(height: 40),
      ]),
    ),
  );

  Widget _lbl(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)));
}
