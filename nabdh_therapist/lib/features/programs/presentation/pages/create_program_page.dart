import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

/// Re-anchor a server-supplied media URL onto the API host.
///
/// The server may hand back a URL built from a stale APP_URL (localhost, an old
/// LAN IP) or a bare relative path — all of which are unreachable from a phone.
/// Only the path is trusted; the host always comes from [AppConstants.baseUrl].
String _fix(String? url) {
  if (url == null || url.isEmpty) return '';
  final base = AppConstants.baseUrl.replaceAll('/api', '');

  // Relative path (e.g. /storage/exercises/...) → just prefix the host.
  if (url.startsWith('/')) return '$base$url';

  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme) return '$base/${url.replaceFirst(RegExp('^/+'), '')}';

  // Any loopback / private-LAN host is unreachable from the device: keep the
  // path, swap the origin. Public hosts are left untouched.
  const localHosts = {'localhost', '127.0.0.1', '10.0.2.2', '0.0.0.0'};
  final isPrivateLan = RegExp(r'^(192\.168\.|10\.|172\.(1[6-9]|2\d|3[01])\.)')
      .hasMatch(uri.host);
  if (localHosts.contains(uri.host) || isPrivateLan) {
    final tail = uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;
    return '$base$tail';
  }
  return url;
}

class CreateProgramPage extends StatefulWidget {
  const CreateProgramPage({super.key});
  @override
  State<CreateProgramPage> createState() => _CreateProgramPageState();
}

class _CreateProgramPageState extends State<CreateProgramPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  bool _saving = false;

  // Patient selection
  List<Map<String, dynamic>> _patients = [];
  int? _selectedPatientId;
  String? _selectedPatientName;
  bool _loadingPatients = true;

  // Dates
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  // Exercises
  final List<_ExerciseData> _exercises = [];

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    try {
      final res = await ApiClient.instance.get('/therapist/patients');
      final list = (res.data as List?) ?? [];
      if (mounted) {
        setState(() {
          _patients = list.cast<Map<String, dynamic>>();
          _loadingPatients = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingPatients = false);
    }
  }

  Future<void> _pickStartDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _startDate = d);
  }

  Future<void> _pickEndDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 14)),
      firstDate: _startDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (d != null) setState(() => _endDate = d);
  }

  void _addExercise() async {
    final result = await showModalBottomSheet<_ExerciseData>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _ExerciseFormSheet(),
    );
    if (result != null) setState(() => _exercises.add(result));
  }

  void _editExercise(int index) async {
    final result = await showModalBottomSheet<_ExerciseData>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ExerciseFormSheet(initial: _exercises[index]),
    );
    if (result != null) setState(() => _exercises[index] = result);
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      _snack('أدخل عنوان البرنامج');
      return;
    }
    if (_selectedPatientId == null) {
      _snack('اختر المريض');
      return;
    }
    if (_exercises.isEmpty) {
      _snack('أضف تمريناً واحداً على الأقل');
      return;
    }

    setState(() => _saving = true);
    try {
      final exercisesList = _exercises.asMap().entries.map((e) {
        final ex = e.value;
        return {
          'title':            ex.title,
          'description':      ex.description,
          'sets':             ex.sets,
          'reps':             ex.reps,
          'duration_seconds': ex.durationSeconds,
          'frequency':        ex.frequency,
          'media_type':       ex.mediaType,
          'media_url':        ex.mediaUrl,
          'media_name':       ex.mediaName,
          'order':            e.key,
        };
      }).toList();

      await ApiClient.instance.post('/therapist/home-programs', data: {
        'patient_id':  _selectedPatientId,
        'title':       _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'start_date':  DateFormat('yyyy-MM-dd').format(_startDate),
        if (_endDate != null) 'end_date': DateFormat('yyyy-MM-dd').format(_endDate!),
        'exercises':   exercisesList,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ تم إنشاء البرنامج وإرسال إشعار للمريض')));
        context.pop();
      }
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String? ?? 'حدث خطأ';
      _snack(msg);
    } catch (e) {
      _snack('خطأ: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: const Text('برنامج منزلي جديد'),
      leading: BackButton(onPressed: () => context.pop()),
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _saving
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('حفظ', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Patient ─────────────────────────────────────────────────
        _SectionCard(
          icon: Icons.person_outline,
          title: 'المريض',
          color: AppColors.primary,
          child: _loadingPatients
            ? const Center(child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(strokeWidth: 2)))
            : DropdownButtonFormField<int>(
                value: _selectedPatientId,
                decoration: const InputDecoration(
                  hintText: 'اختر المريض',
                  prefixIcon: Icon(Icons.search),
                ),
                items: _patients.map((p) => DropdownMenuItem<int>(
                  value: p['id'] as int,
                  child: Text(p['full_name'] as String? ?? ''),
                )).toList(),
                onChanged: (v) => setState(() {
                  _selectedPatientId = v;
                  _selectedPatientName = _patients
                    .firstWhere((p) => p['id'] == v, orElse: () => {})['full_name'] as String?;
                }),
              ),
        ),
        const SizedBox(height: 16),

        // ── Title & Description ──────────────────────────────────────
        _SectionCard(
          icon: Icons.edit_outlined,
          title: 'تفاصيل البرنامج',
          color: AppColors.accent,
          child: Column(children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'عنوان البرنامج *',
                hintText: 'مثال: برنامج تقوية عضلات الكتف',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'الوصف (اختياري)',
                hintText: 'أضف تعليمات عامة للمريض...',
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Dates ───────────────────────────────────────────────────
        _SectionCard(
          icon: Icons.calendar_today_outlined,
          title: 'مدة البرنامج',
          color: const Color(0xFF5C35D4),
          child: Row(children: [
            Expanded(child: _DateTile(
              label: 'تاريخ البداية',
              date: _startDate,
              onTap: _pickStartDate,
            )),
            const SizedBox(width: 12),
            Expanded(child: _DateTile(
              label: 'تاريخ النهاية',
              date: _endDate,
              onTap: _pickEndDate,
              optional: true,
            )),
          ]),
        ),
        const SizedBox(height: 16),

        // ── Exercises ────────────────────────────────────────────────
        Row(children: [
          const Icon(Icons.fitness_center_rounded, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('التمارين والمهام (${_exercises.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const Spacer(),
          TextButton.icon(
            onPressed: _addExercise,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('إضافة'),
          ),
        ]),
        const SizedBox(height: 8),

        if (_exercises.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(children: [
              Icon(Icons.add_task_rounded, size: 48, color: AppColors.border),
              const SizedBox(height: 12),
              const Text('أضف تمارين أو مهام للبرنامج',
                style: TextStyle(color: AppColors.textSecondary)),
            ]),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _exercises.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = _exercises.removeAt(oldIndex);
                _exercises.insert(newIndex, item);
              });
            },
            itemBuilder: (_, i) => _ExerciseCard(
              key: ValueKey(i),
              index: i,
              data: _exercises[i],
              onEdit: () => _editExercise(i),
              onDelete: () => setState(() => _exercises.removeAt(i)),
            ),
          ),

        const SizedBox(height: 24),

        // ── Save Button ──────────────────────────────────────────────
        ElevatedButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.save_rounded),
          label: Text(_saving ? 'جارٍ الحفظ...' : 'حفظ البرنامج',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 80),
      ]),
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _addExercise,
      icon: const Icon(Icons.add),
      label: const Text('إضافة تمرين'),
      backgroundColor: AppColors.accent,
    ),
  );
}

// ────────────────────────────────────────────────────────────────
// Exercise Data model
// ────────────────────────────────────────────────────────────────
class _ExerciseData {
  final String title;
  final String description;
  final int? sets;
  final int? reps;
  final int? durationSeconds;
  final String? frequency;
  final String mediaType;  // none | image | video | file | link
  final String? mediaUrl;
  final String? mediaName;

  const _ExerciseData({
    required this.title,
    this.description = '',
    this.sets,
    this.reps,
    this.durationSeconds,
    this.frequency,
    this.mediaType = 'none',
    this.mediaUrl,
    this.mediaName,
  });
}

// ────────────────────────────────────────────────────────────────
// Exercise Card
// ────────────────────────────────────────────────────────────────
class _ExerciseCard extends StatelessWidget {
  final int index;
  final _ExerciseData data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ExerciseCard({
    required super.key, required this.index, required this.data,
    required this.onEdit, required this.onDelete,
  });

  static const _mediaIcons = {
    'image': Icons.image_outlined,
    'video': Icons.videocam_outlined,
    'file':  Icons.insert_drive_file_outlined,
    'link':  Icons.link_rounded,
  };

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        // Drag handle + number
        Column(children: [
          const Icon(Icons.drag_handle_rounded, color: AppColors.textHint, size: 20),
          const SizedBox(height: 4),
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text('${index + 1}', style: const TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 11)),
          ),
        ]),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(data.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          if (data.description.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(data.description, style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 6),
          Wrap(spacing: 6, children: [
            if (data.sets != null || data.reps != null)
              _chip('${data.sets ?? '?'} × ${data.reps ?? '?'}',
                Icons.repeat_rounded, AppColors.accent),
            if (data.durationSeconds != null)
              _chip('${data.durationSeconds}ث', Icons.timer_outlined, const Color(0xFF5C35D4)),
            if (data.mediaType != 'none' && _mediaIcons.containsKey(data.mediaType))
              _chip(data.mediaName ?? data.mediaType,
                _mediaIcons[data.mediaType]!, AppColors.primary),
          ]),
        ])),
        Column(children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
            onPressed: onDelete,
          ),
        ]),
      ]),
    ),
  );

  Widget _chip(String label, IconData icon, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    ]),
  );
}

// ────────────────────────────────────────────────────────────────
// Exercise Form Sheet
// ────────────────────────────────────────────────────────────────
class _ExerciseFormSheet extends StatefulWidget {
  final _ExerciseData? initial;
  const _ExerciseFormSheet({this.initial});
  @override
  State<_ExerciseFormSheet> createState() => _ExerciseFormSheetState();
}

class _ExerciseFormSheetState extends State<_ExerciseFormSheet> {
  final _titleCtrl    = TextEditingController();
  final _descCtrl     = TextEditingController();
  final _setsCtrl     = TextEditingController();
  final _repsCtrl     = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _freqCtrl     = TextEditingController();
  final _linkCtrl     = TextEditingController();

  String _mediaType = 'none';
  String? _mediaUrl;
  String? _mediaName;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    final d = widget.initial;
    if (d != null) {
      _titleCtrl.text    = d.title;
      _descCtrl.text     = d.description;
      _setsCtrl.text     = d.sets?.toString() ?? '';
      _repsCtrl.text     = d.reps?.toString() ?? '';
      _durationCtrl.text = d.durationSeconds?.toString() ?? '';
      _freqCtrl.text     = d.frequency ?? '';
      _mediaType         = d.mediaType;
      _mediaUrl          = d.mediaUrl;
      _mediaName         = d.mediaName;
      if (d.mediaType == 'link') _linkCtrl.text = d.mediaUrl ?? '';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose();
    _setsCtrl.dispose();  _repsCtrl.dispose();
    _durationCtrl.dispose(); _freqCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload(String type) async {
    setState(() => _uploading = true);
    try {
      File? file;
      String? name;

      if (type == 'image') {
        final xf = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
        if (xf == null) { setState(() => _uploading = false); return; }
        file = File(xf.path);
        name = xf.name;
      } else {
        FileType ft = type == 'video' ? FileType.video : FileType.any;
        final result = await FilePicker.platform.pickFiles(type: ft);
        if (result == null || result.files.isEmpty) { setState(() => _uploading = false); return; }
        file = File(result.files.single.path!);
        name = result.files.single.name;
      }

      final fd = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: name),
        'type': type,
      });
      final res = await ApiClient.instance.post('/therapist/exercises/upload', data: fd);
      setState(() {
        _mediaType = type;
        _mediaUrl  = _fix(res.data['media_url'] as String?);
        _mediaName = res.data['media_name'] as String? ?? name;
      });
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // 413 / 422 on a large file almost always means the *server* upload limit
      // is lower than the file, which is worth saying plainly.
      final msg = switch (status) {
        413 => 'الملف كبير جداً بالنسبة لحدود السيرفر. جرّب ملفاً أصغر.',
        422 => (e.response?.data as Map?)?['message'] as String? ?? 'الملف مرفوض',
        _   => (e.response?.data as Map?)?['message'] as String?
                 ?? 'تعذّر الاتصال بالسيرفر${status != null ? ' ($status)' : ''}',
      };
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الرفع: $msg'), backgroundColor: AppColors.error));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الرفع: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty) return;
    String? url;
    String? mediaName;
    if (_mediaType == 'link') {
      url = _linkCtrl.text.trim().isEmpty ? null : _linkCtrl.text.trim();
    } else {
      url = _mediaUrl;
      mediaName = _mediaName;
    }
    Navigator.pop(context, _ExerciseData(
      title:           _titleCtrl.text.trim(),
      description:     _descCtrl.text.trim(),
      sets:            int.tryParse(_setsCtrl.text),
      reps:            int.tryParse(_repsCtrl.text),
      durationSeconds: int.tryParse(_durationCtrl.text),
      frequency:       _freqCtrl.text.trim().isEmpty ? null : _freqCtrl.text.trim(),
      mediaType:       _mediaType,
      mediaUrl:        url,
      mediaName:       mediaName,
    ));
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom,
      left: 20, right: 20, top: 8),
    child: SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Handle
        Center(child: Container(
          width: 40, height: 4,
          decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)))),
        const SizedBox(height: 16),

        Text(widget.initial == null ? 'إضافة تمرين/مهمة' : 'تعديل التمرين',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),

        // Title
        TextField(
          controller: _titleCtrl,
          decoration: const InputDecoration(labelText: 'العنوان *', hintText: 'مثال: تمرين الضغط على الكتف'),
        ),
        const SizedBox(height: 12),

        // Description
        TextField(
          controller: _descCtrl,
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'الوصف / التعليمات'),
        ),
        const SizedBox(height: 12),

        // Sets / Reps
        Row(children: [
          Expanded(child: TextField(
            controller: _setsCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'عدد الجلسات'),
          )),
          const SizedBox(width: 12),
          Expanded(child: TextField(
            controller: _repsCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'عدد التكرارات'),
          )),
        ]),
        const SizedBox(height: 12),

        // Duration / Frequency
        Row(children: [
          Expanded(child: TextField(
            controller: _durationCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'المدة (ثانية)'),
          )),
          const SizedBox(width: 12),
          Expanded(child: TextField(
            controller: _freqCtrl,
            decoration: const InputDecoration(labelText: 'التكرار اليومي'),
          )),
        ]),
        const SizedBox(height: 20),

        // Media section
        const Text('المحتوى المرفق (اختياري)',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 10),

        // Media type buttons
        Wrap(spacing: 8, children: [
          _mediaBtn('بدون',    'none',  Icons.block_outlined,             AppColors.textHint),
          _mediaBtn('صورة',   'image', Icons.image_outlined,              AppColors.accent),
          _mediaBtn('فيديو',  'video', Icons.videocam_outlined,           const Color(0xFF5C35D4)),
          _mediaBtn('ملف',    'file',  Icons.insert_drive_file_outlined,  AppColors.primary),
          _mediaBtn('رابط',   'link',  Icons.link_rounded,                AppColors.warning),
        ]),
        const SizedBox(height: 12),

        // Media input area
        if (_mediaType == 'link')
          TextField(
            controller: _linkCtrl,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'الرابط',
              hintText: 'https://youtube.com/...',
              prefixIcon: Icon(Icons.link_rounded),
            ),
          )
        else if (_mediaType != 'none') ...[
          if (_uploading)
            const Center(child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator()))
          else if (_mediaUrl != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(_mediaName ?? 'تم الرفع',
                  style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
                TextButton(
                  onPressed: () => setState(() { _mediaUrl = null; _mediaName = null; }),
                  child: const Text('تغيير', style: TextStyle(fontSize: 12)),
                ),
              ]),
            )
          else
            OutlinedButton.icon(
              onPressed: () => _pickAndUpload(_mediaType),
              icon: const Icon(Icons.upload_rounded),
              label: Text(_mediaType == 'image' ? 'اختر صورة'
                : _mediaType == 'video' ? 'اختر فيديو' : 'اختر ملف'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
        ],
        const SizedBox(height: 20),

        // Submit
        ElevatedButton(
          onPressed: _titleCtrl.text.trim().isNotEmpty ? _submit : null,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(widget.initial == null ? 'إضافة التمرين' : 'حفظ التعديلات',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 20),
      ]),
    ),
  );

  Widget _mediaBtn(String label, String type, IconData icon, Color color) {
    final selected = _mediaType == type;
    return GestureDetector(
      onTap: () => setState(() {
        _mediaType = type;
        if (type != 'link' && type != 'none') { _mediaUrl = null; _mediaName = null; }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 2 : 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: selected ? color : AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(
            fontSize: 12, fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: selected ? color : AppColors.textSecondary)),
        ]),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Helpers
// ────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;
  const _SectionCard({required this.icon, required this.title,
    required this.color, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      ]),
      const SizedBox(height: 14),
      child,
    ]),
  );
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final bool optional;
  const _DateTile({required this.label, required this.date,
    required this.onTap, this.optional = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: date != null ? AppColors.primary.withOpacity(0.05) : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: date != null ? AppColors.primary : AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(
          date != null
            ? DateFormat('d MMM yyyy', 'ar').format(date!)
            : optional ? 'اختياري' : 'اختر',
          style: TextStyle(
            fontWeight: FontWeight.w700, fontSize: 13,
            color: date != null ? AppColors.primary : AppColors.textHint),
        ),
      ]),
    ),
  );
}
