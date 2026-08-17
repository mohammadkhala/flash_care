import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

/// Re-anchor a server-supplied file URL onto the API host, since the server may
/// build it from a stale APP_URL or hand back a bare relative path.
String _fixUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  final base = AppConstants.baseUrl.replaceAll('/api', '');
  if (url.startsWith('/')) return '$base$url';

  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme) {
    return '$base/${url.replaceFirst(RegExp('^/+'), '')}';
  }

  const localHosts = {'localhost', '127.0.0.1', '10.0.2.2', '0.0.0.0'};
  final isPrivateLan = RegExp(r'^(192\.168\.|10\.|172\.(1[6-9]|2\d|3[01])\.)')
      .hasMatch(uri.host);
  if (localHosts.contains(uri.host) || isPrivateLan) {
    return '$base${uri.path}';
  }
  return url;
}

/// Lets a therapist manage their verification documents after registration.
///
/// Documents used to be uploadable only during the one-off profile-setup flow,
/// so anyone who skipped that step — or hit a failed upload — had no way to
/// supply them, and the admin panel showed nothing to review.
class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  List<Map<String, dynamic>> _docs = [];
  bool _loading = true;
  bool _uploading = false;

  static const _types = <String, ({String label, IconData icon})>{
    'cv':          (label: 'السيرة الذاتية',  icon: Icons.description_outlined),
    'license':     (label: 'الترخيص المهني',  icon: Icons.badge_outlined),
    'certificate': (label: 'شهادة / دبلوم',   icon: Icons.school_outlined),
    'other':       (label: 'وثيقة أخرى',      icon: Icons.folder_outlined),
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get('/therapist/documents');
      final list = (res.data['documents'] as List?) ?? [];
      if (!mounted) return;
      setState(() {
        _docs = list.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _upload(String type) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (picked == null || picked.files.isEmpty) return;

    final path = picked.files.single.path;
    if (path == null) return;
    final name = picked.files.single.name;

    // The server caps documents at 10 MB — check before spending the upload.
    final sizeMb = File(path).lengthSync() / (1024 * 1024);
    if (sizeMb > 10) {
      _snack('حجم الملف ${sizeMb.toStringAsFixed(1)} ميجابايت — الحد الأقصى 10 ميجابايت',
          error: true);
      return;
    }

    setState(() => _uploading = true);
    try {
      final fd = FormData.fromMap({
        'file':  await MultipartFile.fromFile(path, filename: name),
        'type':  type,
        'label': _types[type]?.label ?? type,
      });
      await ApiClient.instance.post('/therapist/documents', data: fd);
      if (!mounted) return;
      _snack('✓ تم رفع ${_types[type]?.label ?? 'الوثيقة'}');
      await _load();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final msg = switch (status) {
        413 => 'الملف كبير جداً بالنسبة لحدود السيرفر',
        422 => (e.response?.data as Map?)?['message'] as String? ??
                 'صيغة الملف غير مدعومة (PDF أو صورة فقط)',
        _   => (e.response?.data as Map?)?['message'] as String? ??
                 'تعذّر الاتصال بالسيرفر${status != null ? ' ($status)' : ''}',
      };
      _snack('فشل الرفع: $msg', error: true);
    } catch (e) {
      _snack('فشل الرفع: $e', error: true);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _delete(Map<String, dynamic> doc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الوثيقة'),
        content: Text('هل تريد حذف "${doc['label'] ?? doc['file_name'] ?? 'الوثيقة'}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ApiClient.instance.delete('/therapist/documents/${doc['id']}');
      if (!mounted) return;
      _snack('تم حذف الوثيقة');
      await _load();
    } catch (_) {
      _snack('تعذّر حذف الوثيقة', error: true);
    }
  }

  Future<void> _open(Map<String, dynamic> doc) async {
    final raw = (doc['file_url'] ?? doc['url'] ?? doc['file_path']) as String?;
    if (raw == null || raw.isEmpty) {
      _snack('لا يوجد رابط لهذه الوثيقة', error: true);
      return;
    }
    var url = _fixUrl(raw);
    // A bare storage path needs the public prefix before it resolves.
    if (!url.contains('/storage/') && !raw.startsWith('http')) {
      final base = AppConstants.baseUrl.replaceAll('/api', '');
      url = '$base/storage/${raw.replaceFirst(RegExp('^/+'), '')}';
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      _snack('رابط الوثيقة غير صالح', error: true);
      return;
    }
    for (final mode in [LaunchMode.externalApplication, LaunchMode.platformDefault]) {
      try {
        if (await launchUrl(uri, mode: mode)) return;
      } catch (_) {
        // Try the next mode.
      }
    }
    _snack('لا يوجد تطبيق يستطيع فتح هذه الوثيقة', error: true);
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.error : AppColors.success,
    ));
  }

  void _pickType() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
            decoration: BoxDecoration(
                color: AppColors.border, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 16),
          const Text('نوع الوثيقة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ..._types.entries.map((e) => ListTile(
                leading: Icon(e.value.icon, color: AppColors.primary),
                title: Text(e.value.label),
                onTap: () {
                  Navigator.pop(ctx);
                  _upload(e.key);
                },
              )),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('وثائق التوثيق')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _uploading ? null : _pickType,
          backgroundColor: AppColors.primary,
          icon: _uploading
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.upload_file_rounded, color: Colors.white),
          label: Text(_uploading ? 'جارٍ الرفع...' : 'رفع وثيقة',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'ارفع ترخيصك المهني وشهاداتك ليتمكن فريق نبض من توثيق حسابك. '
                            'الصيغ المدعومة: PDF أو صورة، بحد أقصى 10 ميجابايت.',
                            style: TextStyle(fontSize: 12, height: 1.5),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    if (_docs.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(children: [
                          Icon(Icons.folder_off_outlined, size: 52, color: AppColors.border),
                          const SizedBox(height: 12),
                          const Text('لم تُرفع أي وثيقة بعد',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          const Text('اضغط "رفع وثيقة" للبدء',
                              style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                        ]),
                      )
                    else
                      ..._docs.map(_docCard),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
      );

  Widget _docCard(Map<String, dynamic> doc) {
    final type = doc['type'] as String? ?? 'other';
    final meta = _types[type] ?? _types['other']!;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(meta.icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(doc['label'] as String? ?? meta.label,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 3),
            Text(
              [
                doc['file_name'] as String?,
                doc['file_size'] as String?,
              ].whereType<String>().join(' · '),
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ]),
        ),
        IconButton(
          icon: const Icon(Icons.open_in_new_rounded,
              size: 20, color: AppColors.primary),
          onPressed: () => _open(doc),
          tooltip: 'فتح',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
          onPressed: () => _delete(doc),
          tooltip: 'حذف',
        ),
      ]),
    );
  }
}
