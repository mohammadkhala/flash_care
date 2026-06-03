import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/json_utils.dart';
import 'package:dio/dio.dart';

String _resolveUrl(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  if (raw.startsWith('http')) {
    return raw
        .replaceFirst('http://localhost', 'http://192.168.1.10')
        .replaceFirst('http://127.0.0.1', 'http://192.168.1.10');
  }
  final base = ApiClient.instance.options.baseUrl.replaceAll('/api', '');
  return '$base/storage/$raw';
}

// ══════════════════════════════════════════════════════════════════════════════
// Root page — TikTok-style: no AppBar, floating tab strip at top
// ══════════════════════════════════════════════════════════════════════════════

class ReelsPage extends StatefulWidget {
  const ReelsPage({super.key});
  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.black,
      // No AppBar — content goes edge-to-edge at the top
      body: Stack(children: [
        // ── Full-height tab content ──────────────────────────────────────────
        TabBarView(
          controller: _tabCtrl,
          // Disable swipe so vertical PageView in feed doesn't conflict
          physics: const NeverScrollableScrollPhysics(),
          children: const [_MyReelsTab(), _ReelsFeedTab()],
        ),

        // ── Floating top bar (TikTok style) ─────────────────────────────────
        Positioned(
          top: 0, left: 0, right: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(0, topPad + 4, 0, 0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black87, Colors.black45, Colors.transparent],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
            child: TabBar(
              controller: _tabCtrl,
              dividerColor: Colors.transparent,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: Colors.white, width: 2.5),
                insets: EdgeInsets.symmetric(horizontal: 40),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 16),
              unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 16),
              tabs: const [
                Tab(text: 'ريلزي'),
                Tab(text: 'استكشف'),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Tab 1 — My Reels  (dark grid + floating upload button)
// ══════════════════════════════════════════════════════════════════════════════

class _MyReelsTab extends StatefulWidget {
  const _MyReelsTab();
  @override
  State<_MyReelsTab> createState() => _MyReelsTabState();
}

class _MyReelsTabState extends State<_MyReelsTab>
    with AutomaticKeepAliveClientMixin {
  List _reels = [];
  bool _loading = true;
  bool _uploading = false;
  double _uploadProgress = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get('/therapist/reels');
      if (mounted) setState(() {
        _reels = res.data is List ? res.data : (res.data['data'] ?? []);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _upload() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform
          .pickFiles(type: FileType.video, allowCompression: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('خطأ في اختيار الفيديو: $e'),
            backgroundColor: AppColors.error));
      }
      return;
    }
    if (!mounted) return;
    if (result == null || result.files.single.path == null) return;

    final path      = result.files.single.path!;
    final fileName  = result.files.single.name;
    final sizeMb    = (result.files.single.size / (1024 * 1024))
        .toStringAsFixed(1);

    final details = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _UploadDetailsSheet(fileName: fileName, fileSizeMb: sizeMb),
    );
    if (!mounted || details == null) return;

    setState(() {
      _uploading = true;
      _uploadProgress = 0;
    });
    try {
      final form = FormData.fromMap({
        'title': details['title'],
        'description': details['desc'],
        'video': await MultipartFile.fromFile(path, filename: fileName),
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
          if (total > 0 && mounted) {
            setState(() => _uploadProgress = sent / total);
          }
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تم رفع الريل بنجاح ✓'),
            backgroundColor: AppColors.success));
        _load();
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('خطأ: ${e.response?.data?['message'] ?? e.message}'),
            backgroundColor: AppColors.error));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() { _uploading = false; _uploadProgress = 0; });
    }
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف الريل',
            style: TextStyle(color: Colors.white)),
        content: const Text('هل تريد حذف هذا الريل نهائياً؟',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء',
                  style: TextStyle(color: Colors.white54))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حذف',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (ok == true && mounted) {
      try {
        await ApiClient.instance.delete('/therapist/reels/$id');
        _load();
      } catch (_) {}
    }
  }

  void _openPlayer(Map reel) {
    final url = _resolveUrl(reel['video_url'] as String?);
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('رابط الفيديو غير متوفر')));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _ReelPlayerPage(
          title: reel['title'] as String? ?? '',
          videoUrl: url,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final topPad = MediaQuery.of(context).padding.top + 56; // header height

    return Stack(children: [
      // Upload progress bar
      if (_uploading)
        Positioned(
          top: topPad, left: 0, right: 0,
          child: _UploadProgressBar(progress: _uploadProgress),
        ),

      // Grid
      if (_loading)
        const Center(child: CircularProgressIndicator(color: Colors.white))
      else if (_reels.isEmpty)
        _buildEmpty(topPad)
      else
        RefreshIndicator(
          onRefresh: _load,
          color: AppColors.primary,
          child: GridView.builder(
            padding: EdgeInsets.fromLTRB(12, topPad + 12, 12, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.72,
            ),
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

      // Floating upload button (bottom-right, TikTok "+" style)
      Positioned(
        bottom: 24,
        right: 20,
        child: GestureDetector(
          onTap: _uploading ? null : _upload,
          child: Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              gradient: _uploading
                  ? null
                  : const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight]),
              color: _uploading ? Colors.white24 : null,
              shape: BoxShape.circle,
              boxShadow: _uploading
                  ? null
                  : [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 4)),
                    ],
            ),
            child: _uploading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white))
                : const Icon(Icons.add_rounded,
                    color: Colors.white, size: 30),
          ),
        ),
      ),
    ]);
  }

  Widget _buildEmpty(double topPad) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(height: topPad),
      Container(
        width: 90, height: 90,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.video_library_outlined,
            size: 44, color: Colors.white54),
      ),
      const SizedBox(height: 16),
      const Text('لا توجد ريلز بعد',
          style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      const Text('اضغط + لرفع أول ريل',
          style: TextStyle(color: Colors.white38, fontSize: 13)),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// Tab 2 — Explore Feed  (full-screen vertical PageView, TikTok style)
// ══════════════════════════════════════════════════════════════════════════════

class _ReelsFeedTab extends StatefulWidget {
  const _ReelsFeedTab();
  @override
  State<_ReelsFeedTab> createState() => _ReelsFeedTabState();
}

class _ReelsFeedTabState extends State<_ReelsFeedTab>
    with AutomaticKeepAliveClientMixin {
  final List<Map<String, dynamic>> _reels = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _loading = true;
  final PageController _pageCtrl = PageController();
  int _currentIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadReels();
    _pageCtrl.addListener(_onPageChange);
  }

  @override
  void dispose() {
    _pageCtrl.removeListener(_onPageChange);
    _pageCtrl.dispose();
    super.dispose();
  }

  void _onPageChange() {
    final page = _pageCtrl.page?.round() ?? 0;
    if (page != _currentIndex) {
      setState(() => _currentIndex = page);
      if (page >= _reels.length - 2 && _hasMore) _loadReels();
    }
  }

  Future<void> _loadReels() async {
    if (!_hasMore) return;
    try {
      final res = await ApiClient.instance.get('/reels',
          queryParameters: {'page': _currentPage, 'per_page': 5});
      if (!mounted) return;
      final list = ((res.data['data'] ?? res.data) as List?) ?? [];
      final meta = res.data['meta'] as Map<String, dynamic>?;
      final lastPage = jsonInt(meta?['last_page'], 1);
      setState(() {
        _reels.addAll(list.cast<Map<String, dynamic>>());
        _currentPage++;
        _hasMore = _currentPage - 1 < lastPage;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }
    if (_reels.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.videocam_off_outlined,
              size: 64, color: Colors.white38),
          const SizedBox(height: 16),
          const Text('لا توجد ريلز منشورة',
              style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ]),
      );
    }
    return PageView.builder(
      controller: _pageCtrl,
      scrollDirection: Axis.vertical,
      itemCount: _reels.length,
      itemBuilder: (_, i) => _FeedReelCard(
        reel: _reels[i],
        isActive: i == _currentIndex,
      ),
    );
  }
}

// ── Single feed reel ──────────────────────────────────────────────────────────

class _FeedReelCard extends StatefulWidget {
  final Map<String, dynamic> reel;
  final bool isActive;
  const _FeedReelCard({required this.reel, required this.isActive});

  @override
  State<_FeedReelCard> createState() => _FeedReelCardState();
}

class _FeedReelCardState extends State<_FeedReelCard> {
  VideoPlayerController? _ctrl;
  bool _initialized = false;
  bool _showPauseIcon = false;
  bool _liked = false;
  int  _likesCount = 0;
  bool _liking = false;

  @override
  void initState() {
    super.initState();
    _liked = widget.reel['liked_by_me'] == true;
    _likesCount = jsonInt(widget.reel['likes_count']);
    _initVideo();
  }

  @override
  void didUpdateWidget(_FeedReelCard old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _ctrl?.play();
    } else if (!widget.isActive && old.isActive) {
      _ctrl?.pause();
    }
  }

  Future<void> _initVideo() async {
    final url = _resolveUrl(widget.reel['video_url'] as String?);
    if (url.isEmpty) return;
    _ctrl = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await _ctrl!.initialize();
      if (!mounted) return;
      _ctrl!.setLooping(true);
      if (widget.isActive) _ctrl!.play();
      setState(() => _initialized = true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_ctrl == null) return;
    if (_ctrl!.value.isPlaying) {
      _ctrl!.pause();
    } else {
      _ctrl!.play();
    }
    setState(() => _showPauseIcon = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showPauseIcon = false);
    });
  }

  Future<void> _toggleLike() async {
    if (_liking) return;
    setState(() {
      _liking = true;
      _liked = !_liked;
      _likesCount += _liked ? 1 : -1;
    });
    try {
      final res = await ApiClient.instance
          .post('/reels/${widget.reel['id']}/like');
      if (!mounted) return;
      setState(() {
        _liked = res.data['liked'] == true;
        _likesCount = jsonInt(res.data['likes_count'], _likesCount);
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _liked = !_liked;
          _likesCount += _liked ? 1 : -1;
        });
      }
    } finally {
      if (mounted) setState(() => _liking = false);
    }
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) =>
          _CommentsSheet(reelId: widget.reel['id'] as int),
    );
  }

  @override
  Widget build(BuildContext context) {
    final therapist =
        (widget.reel['therapist'] as Map<String, dynamic>?) ?? {};
    final avatar   = _resolveUrl(therapist['avatar'] as String?);
    final commentsCount = jsonInt(widget.reel['comments_count']);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(fit: StackFit.expand, children: [
        // ── Video ──────────────────────────────────────────────────────
        Container(color: Colors.black),
        if (_initialized && _ctrl != null)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width:  _ctrl!.value.size.width,
              height: _ctrl!.value.size.height,
              child:  VideoPlayer(_ctrl!),
            ),
          )
        else
          const Center(
              child: CircularProgressIndicator(
                  color: Colors.white38, strokeWidth: 2)),

        // ── Tap-to-pause indicator ─────────────────────────────────────
        if (_showPauseIcon)
          Center(
            child: AnimatedOpacity(
              opacity: _showPauseIcon ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _ctrl?.value.isPlaying ?? false
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white, size: 40,
                ),
              ),
            ),
          ),

        // ── Bottom gradient ────────────────────────────────────────────
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Color(0x88000000),
                  Color(0xCC000000),
                ],
                stops: [0.0, 0.45, 0.75, 1.0],
              ),
            ),
          ),
        ),

        // ── Author + description (bottom-left) ─────────────────────────
        Positioned(
          bottom: bottomPad + 20,
          left: 16,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Author row
              Row(children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white24,
                    backgroundImage: avatar.isNotEmpty
                        ? CachedNetworkImageProvider(avatar)
                        : null,
                    child: avatar.isEmpty
                        ? const Icon(Icons.person,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        therapist['name'] as String? ??
                            therapist['full_name'] as String? ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 4)
                          ],
                        ),
                      ),
                      if ((therapist['title'] as String? ?? '').isNotEmpty)
                        Text(
                          therapist['title'] as String,
                          style: const TextStyle(
                            color: Colors.white70, fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              // Title
              if ((widget.reel['title'] as String? ?? '').isNotEmpty)
                Text(
                  widget.reel['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                  ),
                ),
              // Description
              if ((widget.reel['description'] as String? ?? '').isNotEmpty)
                ...[
                const SizedBox(height: 4),
                Text(
                  widget.reel['description'] as String,
                  style: const TextStyle(
                    color: Colors.white70, fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),

        // ── Right-side actions ─────────────────────────────────────────
        Positioned(
          right: 14,
          bottom: bottomPad + 90,
          child: Column(children: [
            // Like
            _ActionBtn(
              icon: _liked
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              iconColor: _liked ? Colors.red : Colors.white,
              count: _likesCount,
              onTap: _toggleLike,
            ),
            const SizedBox(height: 24),
            // Comment
            _ActionBtn(
              icon: Icons.chat_bubble_outline_rounded,
              count: commentsCount,
              onTap: _showComments,
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int? count;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
    this.count,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Icon(
        icon,
        color: iconColor,
        size: 32,
        shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
      ),
      if (count != null) ...[
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
          ),
        ),
      ],
    ]),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// Comments sheet
// ══════════════════════════════════════════════════════════════════════════════

class _CommentsSheet extends StatefulWidget {
  final int reelId;
  const _CommentsSheet({required this.reelId});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final List<Map<String, dynamic>> _comments = [];
  bool _loading = true;
  final _commentCtrl = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final res = await ApiClient.instance
          .get('/reels/${widget.reelId}/comments');
      if (!mounted) return;
      final list = ((res.data['data'] ?? res.data) as List?) ?? [];
      setState(() {
        _comments
          ..clear()
          ..addAll(list.cast<Map<String, dynamic>>());
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendComment() async {
    final body = _commentCtrl.text.trim();
    if (body.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ApiClient.instance.post(
          '/reels/${widget.reelId}/comments', data: {'body': body});
      _commentCtrl.clear();
      await _loadComments();
    } catch (_) {} finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.7,
    maxChildSize: 0.95,
    minChildSize: 0.4,
    builder: (ctx, scroll) => Column(children: [
      Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: 40, height: 4,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const Text(
        'التعليقات',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
      ),
      const SizedBox(height: 10),
      Expanded(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : _comments.isEmpty
                ? const Center(
                    child: Text('لا توجد تعليقات',
                        style: TextStyle(color: Colors.white54)))
                : ListView.separated(
                    controller: scroll,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _comments.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: Colors.white12),
                    itemBuilder: (_, i) {
                      final c  = _comments[i];
                      final ua = _resolveUrl(c['user_avatar'] as String?);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: ua.isNotEmpty
                                  ? CachedNetworkImageProvider(ua)
                                  : null,
                              backgroundColor: Colors.white12,
                              child: ua.isEmpty
                                  ? const Icon(Icons.person,
                                      size: 16, color: Colors.white54)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c['user_name'] as String? ?? 'مستخدم',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    c['body'] as String? ?? '',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(
            16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _commentCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'أضف تعليقاً...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sending ? null : _sendComment,
            child: Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
              child: _sending
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
            ),
          ),
        ]),
      ),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// Full-screen video player page (my reels)
// ══════════════════════════════════════════════════════════════════════════════

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
        placeholder:
            const Center(child: CircularProgressIndicator()),
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
    extendBodyBehindAppBar: true,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
      title: Text(widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          overflow: TextOverflow.ellipsis),
      leading: IconButton(
        icon: const Icon(Icons.close_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: _error
        ? Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.white54, size: 64),
              const SizedBox(height: 16),
              const Text('تعذّر تشغيل الفيديو',
                  style: TextStyle(color: Colors.white70, fontSize: 15)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() => _error = false);
                  _init();
                },
                child: const Text('إعادة المحاولة',
                    style:
                        TextStyle(color: AppColors.primaryLight)),
              ),
            ]))
        : _chewieCtrl == null
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : Center(child: Chewie(controller: _chewieCtrl!)),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// Upload helpers
// ══════════════════════════════════════════════════════════════════════════════

class _UploadProgressBar extends StatelessWidget {
  final double progress;
  const _UploadProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black87,
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const SizedBox(
          width: 18, height: 18,
          child: CircularProgressIndicator(
              strokeWidth: 2.5, color: AppColors.primary)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            progress > 0
                ? 'جاري رفع الريل... ${(progress * 100).toInt()}%'
                : 'جاري التحضير...',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white),
          ),
        ),
        Text(
          '${(progress * 100).toInt()}%',
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryLight),
        ),
      ]),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: progress > 0 ? progress : null,
          minHeight: 5,
          backgroundColor: Colors.white12,
          valueColor:
              const AlwaysStoppedAnimation(AppColors.primary),
        ),
      ),
    ]),
  );
}

class _UploadDetailsSheet extends StatefulWidget {
  final String fileName, fileSizeMb;
  const _UploadDetailsSheet(
      {required this.fileName, required this.fileSizeMb});
  @override
  State<_UploadDetailsSheet> createState() =>
      _UploadDetailsSheetState();
}

class _UploadDetailsSheetState extends State<_UploadDetailsSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.video_call_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('تفاصيل الريل',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                Text(widget.fileName,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.white54),
                    overflow: TextOverflow.ellipsis),
              ]),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${widget.fileSizeMb} MB',
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          const Text('العنوان *',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70)),
          const SizedBox(height: 8),
          TextField(
            controller: _titleCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'مثال: تمارين تقوية الظهر',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            maxLength: 100,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          const Text('الوصف',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70)),
          const SizedBox(height: 8),
          TextField(
            controller: _descCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'وصف مختصر للمحتوى...',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            maxLines: 2,
            maxLength: 200,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  side: const BorderSide(color: Colors.white24),
                  foregroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('إلغاء'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  final title = _titleCtrl.text.trim();
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('أدخل عنوان الريل أولاً')));
                    return;
                  }
                  Navigator.pop(context,
                      {'title': title, 'desc': _descCtrl.text.trim()});
                },
                icon: const Icon(Icons.upload_rounded),
                label: const Text('رفع الريل'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Reel card (my reels dark grid) ───────────────────────────────────────────

class _ReelCard extends StatelessWidget {
  final Map reel;
  final VoidCallback onTap, onDelete;
  const _ReelCard(
      {required this.reel, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isApproved = reel['is_approved'] == true;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Color(0xFF0A1628), Color(0xFF12243A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white10),
        ),
        child: Stack(children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(height: 10),
                Text(
                  reel['title'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isApproved
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isApproved
                          ? Colors.green.withOpacity(0.4)
                          : Colors.orange.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    isApproved ? '✓ معتمد' : 'مراجعة',
                    style: TextStyle(
                      color: isApproved
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ]),
            ),
          ),
          // Delete button
          Positioned(
            top: 8, left: 8,
            child: GestureDetector(
              onTap: onDelete,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white70, size: 14),
              ),
            ),
          ),
          // Likes count
          Positioned(
            bottom: 8, right: 10,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.favorite_rounded,
                  color: Colors.redAccent, size: 12),
              const SizedBox(width: 3),
              Text(
                '${reel['likes_count'] ?? 0}',
                style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
