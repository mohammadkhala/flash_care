import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

String _fixUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  return url
      .replaceAll('localhost', '192.168.1.3')
      .replaceAll('127.0.0.1', '192.168.1.3');
}

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});
  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  List<Map<String, dynamic>> _docs = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiClient.instance.get('/patient/documents');
      if (!mounted) return;
      final list = (r.data is List ? r.data : (r.data['data'] ?? r.data)) as List;
      setState(() { _docs = list.cast<Map<String, dynamic>>(); _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: const Text('وثائقي الطبية'),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_rounded),
          onPressed: () => _showAddSheet(),
          tooltip: 'إضافة وثيقة',
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _showAddSheet(),
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
      label: const Text('رفع وثيقة', style: TextStyle(color: Colors.white)),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _load,
            child: _docs.isEmpty
                ? _EmptyState(onAdd: _showAddSheet)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: _docs.length,
                    itemBuilder: (_, i) => _DocCard(
                      doc: _docs[i],
                      onDelete: () => _delete(_docs[i]),
                    ),
                  ),
          ),
  );

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddDocumentSheet(onAdded: () { Navigator.pop(context); _load(); }),
    );
  }

  Future<void> _delete(Map doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الوثيقة'),
        content: const Text('هل تريد حذف هذه الوثيقة نهائياً؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ApiClient.instance.delete('/patient/documents/${doc['id']}');
      _load();
    } catch (_) {}
  }
}

// ── Document Card ─────────────────────────────────────────────────────────────
class _DocCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  final VoidCallback onDelete;
  const _DocCard({required this.doc, required this.onDelete});

  static const _typeIcons = {
    'diagnosis':    Icons.medical_information_rounded,
    'report':       Icons.description_rounded,
    'prescription': Icons.medication_rounded,
    'scan':         Icons.image_rounded,
    'lab':          Icons.science_rounded,
    'other':        Icons.attach_file_rounded,
  };

  static const _typeColors = {
    'diagnosis':    Color(0xFF1565C0),
    'report':       Color(0xFF2E7D32),
    'prescription': Color(0xFFE65100),
    'scan':         Color(0xFF6A1B9A),
    'lab':          Color(0xFF00838F),
    'other':        AppColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    final type     = doc['type'] as String? ?? 'other';
    final fileUrl  = _fixUrl(doc['file_url'] as String?);
    final fileName = doc['file_name'] as String? ?? '';
    final date     = doc['document_date'] as String?;
    final doctor   = doc['doctor_name'] as String?;
    final notes    = doc['notes'] as String?;
    final icon     = _typeIcons[type] ?? Icons.attach_file_rounded;
    final color    = _typeColors[type] ?? AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: fileUrl.isNotEmpty ? () async {
          final uri = Uri.tryParse(fileUrl);
          if (uri != null && await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
        } : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(doc['title'] as String? ?? '—',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 3),
              Text(doc['type_label'] as String? ?? type,
                style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
              if (doctor != null && doctor.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text('د. $doctor', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
              if (date != null) ...[
                const SizedBox(height: 2),
                Text(_fmtDate(date), style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
              ],
              if (notes != null && notes.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(notes, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
              if (fileName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.attach_file_rounded, size: 13, color: AppColors.textHint),
                  const SizedBox(width: 3),
                  Expanded(child: Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.textHint))),
                ]),
              ],
            ])),
            Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              if (fileUrl.isNotEmpty)
                const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.primary),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  String _fmtDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    return DateFormat('d MMMM y', 'ar').format(dt);
  }
}

// ── Empty State ────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 100, height: 100,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.folder_open_rounded, size: 50, color: AppColors.primary),
      ),
      const SizedBox(height: 20),
      const Text('لا توجد وثائق بعد',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 8),
      const Text('ارفع تقاريرك وتشخيصاتك الطبية\nلتبقى دائماً في متناول يدك',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
      const SizedBox(height: 28),
      ElevatedButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('رفع أول وثيقة'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    ]),
  );
}

// ── Add Document Sheet ─────────────────────────────────────────────────────────
class _AddDocumentSheet extends StatefulWidget {
  final VoidCallback onAdded;
  const _AddDocumentSheet({required this.onAdded});
  @override
  State<_AddDocumentSheet> createState() => _AddDocumentSheetState();
}

class _AddDocumentSheetState extends State<_AddDocumentSheet> {
  final _formKey   = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _drCtrl    = TextEditingController();

  String _type = 'report';
  DateTime? _docDate;
  File? _file;
  String? _fileName;
  bool _saving = false;

  static const _types = {
    'diagnosis':    'تشخيص',
    'report':       'تقرير طبي',
    'prescription': 'وصفة طبية',
    'scan':         'صورة أشعة',
    'lab':          'تحليل مختبري',
    'other':        'أخرى',
  };

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _file     = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final data = FormData.fromMap({
        'title': _titleCtrl.text.trim(),
        'type':  _type,
        if (_notesCtrl.text.isNotEmpty) 'notes': _notesCtrl.text.trim(),
        if (_drCtrl.text.isNotEmpty)    'doctor_name': _drCtrl.text.trim(),
        if (_docDate != null)           'document_date': DateFormat('yyyy-MM-dd').format(_docDate!),
        if (_file != null) 'file': await MultipartFile.fromFile(
          _file!.path, filename: _fileName ?? _file!.path.split('/').last),
      });
      await ApiClient.instance.post('/patient/documents', data: data,
          options: Options(contentType: 'multipart/form-data'));
      widget.onAdded();
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] ?? 'تعذّر الحفظ';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
    child: SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('إضافة وثيقة طبية',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 20),

          // Title
          TextFormField(
            controller: _titleCtrl,
            decoration: _inputDec('عنوان الوثيقة *', Icons.title_rounded),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
          ),
          const SizedBox(height: 14),

          // Type
          DropdownButtonFormField<String>(
            value: _type,
            decoration: _inputDec('نوع الوثيقة *', Icons.category_rounded),
            items: _types.entries.map((e) =>
              DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 14),

          // Doctor name
          TextFormField(
            controller: _drCtrl,
            decoration: _inputDec('اسم الطبيب/الأخصائي', Icons.person_rounded),
          ),
          const SizedBox(height: 14),

          // Date
          GestureDetector(
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (d != null) setState(() => _docDate = d);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const Icon(Icons.calendar_today_rounded, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 12),
                Text(
                  _docDate != null ? DateFormat('d MMMM y', 'ar').format(_docDate!) : 'تاريخ الوثيقة',
                  style: TextStyle(color: _docDate != null ? AppColors.textPrimary : AppColors.textHint),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 14),

          // Notes
          TextFormField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: _inputDec('ملاحظات', Icons.notes_rounded),
          ),
          const SizedBox(height: 14),

          // File picker
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: _file != null ? AppColors.primary : AppColors.border,
                  style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(12),
                color: _file != null ? AppColors.primary.withValues(alpha: 0.05) : null,
              ),
              child: Row(children: [
                Icon(_file != null ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                  color: _file != null ? AppColors.primary : AppColors.textSecondary, size: 22),
                const SizedBox(width: 12),
                Expanded(child: Text(
                  _fileName ?? 'اختر ملف (PDF، صورة، Word)',
                  style: TextStyle(
                    color: _file != null ? AppColors.primary : AppColors.textHint,
                    fontWeight: _file != null ? FontWeight.w600 : FontWeight.w400,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                )),
                if (_file != null)
                  GestureDetector(
                    onTap: () => setState(() { _file = null; _fileName = null; }),
                    child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                  ),
              ]),
            ),
          ),
          const SizedBox(height: 24),

          // Submit
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _saving
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('حفظ الوثيقة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    ),
  );

  InputDecoration _inputDec(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 20),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
