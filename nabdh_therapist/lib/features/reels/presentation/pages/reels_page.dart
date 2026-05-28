import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:dio/dio.dart';

class ReelsPage extends StatefulWidget {
  const ReelsPage({super.key});
  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  List _reels = [];
  bool _loading = true;
  bool _uploading = false;
  double _uploadProgress = 0;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get('/therapist/reels');
      if (mounted) setState(() {
        _reels = res.data is List ? res.data : (res.data['data'] ?? []);
        _loading = false;
      });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _upload() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(type: FileType.video, allowCompression: true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في اختيار الفيديو: $e'), backgroundColor: AppColors.error));
      return;
    }

    if (!mounted) return;
    if (result == null || result.files.single.path == null) return;

    final path       = result.files.single.path!;
    final fileName   = result.files.single.name;
    final fileSizeMb = (result.files.single.size / (1024 * 1024)).toStringAsFixed(1);

    final details = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UploadDetailsSheet(fileName: fileName, fileSizeMb: fileSizeMb),
    );

    if (!mounted || details == null) return;

    setState(() { _uploading = true; _uploadProgress = 0; });
    try {
      final form = FormData.fromMap({
        'title':       details['title'],
        'description': details['desc'],
        'video':       await MultipartFile.fromFile(path, filename: fileName),
      });
      await ApiClient.instance.post(
        '/therapist/reels',
        data: form,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 2),
        ),
        onSendProgress: (sent, total) {
          if (total > 0 && mounted) setState(() => _uploadProgress = sent / total);
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تم رفع الريل بنجاح ✓'), backgroundColor: AppColors.success));
        _load();
      }
    } on DioException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('خطأ: ${e.response?.data?['message'] ?? e.message}'),
          backgroundColor: AppColors.error));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() { _uploading = false; _uploadProgress = 0; });
    }
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('حذف الريل'),
      content: const Text('هل تريد حذف هذا الريل نهائياً؟'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
        TextButton(onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: AppColors.error))),
      ],
    ));
    if (ok == true && mounted) {
      try { await ApiClient.instance.delete('/therapist/reels/$id'); _load(); } catch (_) {}
    }
  }

  String _resolveUrl(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    // Already a full URL pointing to our server
    if (raw.startsWith('http')) {
      // Replace localhost/127.0.0.1 with actual server IP (for old records)
      return raw
          .replaceFirst('http://localhost', 'http://192.168.1.3')
          .replaceFirst('http://127.0.0.1', 'http://192.168.1.3');
    }
    // Relative path — build full URL from API base
    final base = ApiClient.instance.options.baseUrl.replaceAll('/api', '');
    return '$base/storage/$raw';
  }

  void _openPlayer(Map reel) {
    final url = _resolveUrl(reel['video_url'] as String?);
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('رابط الفيديو غير متوفر')));
      return;
    }
    Navigator.push(context, MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _ReelPlayerPage(
        title: reel['title'] as String? ?? '',
        videoUrl: url,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: const Text('الريلز'),
      actions: [
        if (!_uploading)
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: _upload,
          ),
      ],
    ),
    body: Column(children: [
      if (_uploading) _UploadProgressBar(progress: _uploadProgress),
      Expanded(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _reels.isEmpty
                ? _empty()
                : RefreshIndicator(
                    onRefresh: _load,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75),
                      itemCount: _reels.length,
                      itemBuilder: (_, i) {
                        final r = _reels[i] as Map;
                        return _ReelCard(
                          reel: r,
                          onTap: () => _openPlayer(r),
                          onDelete: () => _delete(r['id'] as int),
                        );
                      },
                    ),
                  ),
      ),
    ]),
  );

  Widget _empty() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(width: 90, height: 90,
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.06), shape: BoxShape.circle),
      child: const Icon(Icons.video_library_outlined, size: 44, color: AppColors.primary)),
    const SizedBox(height: 16),
    const Text('لا توجد ريلز بعد',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
    const SizedBox(height: 8),
    const Text('ارفع أول ريل لك لمشاركة محتواك',
        style: TextStyle(color: AppColors.textHint, fontSize: 13)),
    const SizedBox(height: 20),
    ElevatedButton.icon(
      onPressed: _upload,
      icon: const Icon(Icons.add),
      label: const Text('رفع ريل'),
      style: ElevatedButton.styleFrom(minimumSize: const Size(160, 48)),
    ),
  ]));
}

// ── Video Player Page ────────────────────────────────────────────
class _ReelPlayerPage extends StatefulWidget {
  final String title, videoUrl;
  const _ReelPlayerPage({required this.title, required this.videoUrl});
  @override
  State<_ReelPlayerPage> createState() => _ReelPlayerPageState();
}

class _ReelPlayerPageState extends State<_ReelPlayerPage> {
  VideoPlayerController? _vpc;
  ChewieController?      _chewieCtrl;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _init();
  }

  Future<void> _init() async {
    try {
      _vpc = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _vpc!.initialize();
      if (!mounted) return;
      _chewieCtrl = ChewieController(
        videoPlayerController: _vpc!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        placeholder: const Center(child: CircularProgressIndicator()),
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primaryLight,
          bufferedColor: AppColors.border,
          backgroundColor: Colors.black26,
        ),
      );
      setState(() {});
    } catch (e) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _chewieCtrl?.dispose();
    _vpc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      title: Text(widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 15), overflow: TextOverflow.ellipsis),
      leading: IconButton(
        icon: const Icon(Icons.close_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: _error
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            const Text('تعذّر تشغيل الفيديو', style: TextStyle(color: Colors.white70, fontSize: 15)),
            const SizedBox(height: 8),
            TextButton(onPressed: () { setState(() => _error = false); _init(); },
                child: const Text('إعادة المحاولة', style: TextStyle(color: AppColors.primaryLight))),
          ]))
        : _chewieCtrl == null
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Center(child: Chewie(controller: _chewieCtrl!)),
  );
}

// ── Upload progress bar ──────────────────────────────────────────
class _UploadProgressBar extends StatelessWidget {
  final double progress;
  const _UploadProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.surface,
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const SizedBox(width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary)),
        const SizedBox(width: 10),
        Expanded(child: Text(
          progress > 0 ? 'جاري رفع الريل... ${(progress * 100).toInt()}%' : 'جاري التحضير...',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        )),
        Text('${(progress * 100).toInt()}%',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
      ]),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: progress > 0 ? progress : null,
          minHeight: 6,
          backgroundColor: AppColors.border,
          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
        ),
      ),
    ]),
  );
}

// ── Upload details bottom sheet ──────────────────────────────────
class _UploadDetailsSheet extends StatefulWidget {
  final String fileName, fileSizeMb;
  const _UploadDetailsSheet({required this.fileName, required this.fileSizeMb});
  @override
  State<_UploadDetailsSheet> createState() => _UploadDetailsSheetState();
}

class _UploadDetailsSheetState extends State<_UploadDetailsSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Row(children: [
          Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
              borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.video_call_rounded, color: Colors.white, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('تفاصيل الريل', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            Text(widget.fileName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text('${widget.fileSizeMb} MB',
                style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 24),
        const Text('العنوان *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(controller: _titleCtrl,
            decoration: const InputDecoration(hintText: 'مثال: تمارين تقوية الظهر'),
            maxLength: 100, textInputAction: TextInputAction.next),
        const SizedBox(height: 12),
        const Text('الوصف', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(controller: _descCtrl,
            decoration: const InputDecoration(hintText: 'وصف مختصر للمحتوى...'),
            maxLines: 2, maxLength: 200, textInputAction: TextInputAction.done),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: const Text('إلغاء'),
          )),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: ElevatedButton.icon(
            onPressed: () {
              final title = _titleCtrl.text.trim();
              if (title.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('أدخل عنوان الريل أولاً')));
                return;
              }
              Navigator.pop(context, {'title': title, 'desc': _descCtrl.text.trim()});
            },
            icon: const Icon(Icons.upload_rounded),
            label: const Text('رفع الريل'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52)),
          )),
        ]),
      ]),
    );
  }
}

// ── Reel card ────────────────────────────────────────────────────
class _ReelCard extends StatelessWidget {
  final Map reel;
  final VoidCallback onTap, onDelete;
  const _ReelCard({required this.reel, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isApproved = reel['is_approved'] == true;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF0A2A38), Color(0xFF1B5E7B)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Stack(children: [
          // Main content
          Positioned.fill(child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32)),
              const SizedBox(height: 10),
              Text(reel['title'] ?? '',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                  maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isApproved ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isApproved ? '✓ معتمد' : '⏳ مراجعة',
                  style: TextStyle(
                    color: isApproved ? Colors.greenAccent : Colors.orangeAccent,
                    fontSize: 10, fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ]),
          )),

          // Delete button
          Positioned(top: 8, left: 8, child: GestureDetector(
            onTap: onDelete,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
            ),
          )),

          // Likes count
          Positioned(bottom: 8, right: 10, child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 13),
            const SizedBox(width: 3),
            Text('${reel['likes_count'] ?? 0}',
                style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
          ])),
        ]),
      ),
    );
  }
}
