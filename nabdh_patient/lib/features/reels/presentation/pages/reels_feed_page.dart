import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/json_utils.dart';

String _resolveUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  if (url.startsWith('http')) {
    return url
        .replaceAll('localhost', '192.168.1.10')
        .replaceAll('127.0.0.1', '192.168.1.10');
  }
  // Relative path — build full URL from API base
  final base = ApiClient.instance.options.baseUrl.replaceAll('/api', '');
  return '$base/storage/$url';
}

class ReelsFeedPage extends StatefulWidget {
  const ReelsFeedPage({super.key});

  @override
  State<ReelsFeedPage> createState() => _ReelsFeedPageState();
}

class _ReelsFeedPageState extends State<ReelsFeedPage> {
  final List<Map<String, dynamic>> _reels = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _loading = true;
  final PageController _pageCtrl = PageController();
  int _currentIndex = 0;

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
    if (_loading) return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator(color: Colors.white)));

    if (_reels.isEmpty) return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Text('لا توجد ريلز',
        style: TextStyle(color: Colors.white))));

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageCtrl,
        scrollDirection: Axis.vertical,
        itemCount: _reels.length,
        itemBuilder: (_, i) => _ReelCard(
          reel: _reels[i],
          isActive: i == _currentIndex,
        ),
      ),
    );
  }
}

class _ReelCard extends StatefulWidget {
  final Map<String, dynamic> reel;
  final bool isActive;
  const _ReelCard({required this.reel, required this.isActive});

  @override
  State<_ReelCard> createState() => _ReelCardState();
}

class _ReelCardState extends State<_ReelCard> {
  VideoPlayerController? _ctrl;
  bool _initialized = false;
  bool _liked = false;
  int _likesCount = 0;
  bool _liking = false;

  @override
  void initState() {
    super.initState();
    _liked = widget.reel['liked_by_me'] == true;
    _likesCount = jsonInt(widget.reel['likes_count']);
    _initVideo();
  }

  @override
  void didUpdateWidget(_ReelCard old) {
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

  Future<void> _toggleLike() async {
    if (_liking) return;
    setState(() { _liking = true; _liked = !_liked; _likesCount += _liked ? 1 : -1; });
    try {
      final res = await ApiClient.instance.post('/reels/${widget.reel['id']}/like');
      if (!mounted) return;
      setState(() {
        _liked = res.data['liked'] == true;
        _likesCount = jsonInt(res.data['likes_count'], _likesCount);
      });
    } catch (_) {
      if (mounted) setState(() { _liked = !_liked; _likesCount += _liked ? 1 : -1; });
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
      builder: (_) => _CommentsSheet(reelId: widget.reel['id'] as int),
    );
  }

  @override
  Widget build(BuildContext context) {
    final therapist = (widget.reel['therapist'] as Map<String, dynamic>?) ?? {};
    final avatar = _resolveUrl(therapist['avatar'] as String?);
    final commentsCount = jsonInt(widget.reel['comments_count']);

    return Stack(fit: StackFit.expand, children: [
      // Video
      if (_initialized && _ctrl != null)
        GestureDetector(
          onTap: () => _ctrl!.value.isPlaying ? _ctrl!.pause() : _ctrl!.play(),
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _ctrl!.value.size.width,
              height: _ctrl!.value.size.height,
              child: VideoPlayer(_ctrl!),
            ),
          ),
        )
      else
        Container(color: Colors.black26),

      // Gradient overlay
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.transparent, Colors.black54],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
      ),

      // Top safe area padding
      Positioned(
        top: MediaQuery.of(context).padding.top + 8,
        left: 0, right: 0,
        child: const SizedBox.shrink(),
      ),

      // Bottom info
      Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 16,
        left: 16, right: 72,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: avatar.isNotEmpty ? CachedNetworkImageProvider(avatar) : null,
              backgroundColor: Colors.white24,
              child: avatar.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 18) : null,
            ),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(therapist['name'] as String? ?? therapist['full_name'] as String? ?? '',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              Text(therapist['title'] as String? ?? '',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ])),
          ]),
          const SizedBox(height: 8),
          if ((widget.reel['title'] as String? ?? '').isNotEmpty)
            Text(widget.reel['title'] as String,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
          if ((widget.reel['description'] as String? ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(widget.reel['description'] as String,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ]),
      ),

      // Right side actions
      Positioned(
        right: 12,
        bottom: MediaQuery.of(context).padding.bottom + 80,
        child: Column(children: [
          _ActionButton(
            icon: _liked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
            iconColor: _liked ? Colors.red : Colors.white,
            count: _likesCount,
            onTap: _toggleLike,
          ),
          const SizedBox(height: 20),
          _ActionButton(
            icon: Icons.comment_outlined,
            count: commentsCount,
            onTap: _showComments,
          ),
          const SizedBox(height: 20),
          _ActionButton(
            icon: Icons.share_outlined,
            onTap: () {},
          ),
        ]),
      ),
    ]);
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int? count;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
    this.count,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Icon(icon, color: iconColor, size: 30,
        shadows: const [Shadow(color: Colors.black54, blurRadius: 4)]),
      if (count != null) ...[
        const SizedBox(height: 4),
        Text('$count', style: const TextStyle(
          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700,
          shadows: [Shadow(color: Colors.black54, blurRadius: 4)])),
      ],
    ]),
  );
}

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
  void dispose() { _commentCtrl.dispose(); super.dispose(); }

  Future<void> _loadComments() async {
    try {
      final res = await ApiClient.instance.get('/reels/${widget.reelId}/comments');
      if (!mounted) return;
      final list = ((res.data['data'] ?? res.data) as List?) ?? [];
      setState(() { _comments.clear(); _comments.addAll(list.cast<Map<String, dynamic>>()); _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendComment() async {
    final body = _commentCtrl.text.trim();
    if (body.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ApiClient.instance.post('/reels/${widget.reelId}/comments', data: {'body': body});
      _commentCtrl.clear();
      await _loadComments();
    } catch (_) {} finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (ctx, scroll) => Column(children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
        const Text('التعليقات',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 10),
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _comments.isEmpty
            ? const Center(child: Text('لا توجد تعليقات',
                style: TextStyle(color: Colors.white54)))
            : ListView.separated(
                controller: scroll,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _comments.length,
                separatorBuilder: (_, __) => const Divider(color: Colors.white12),
                itemBuilder: (_, i) {
                  final c = _comments[i];
                  final ua = _resolveUrl(c['user_avatar'] as String?);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: ua.isNotEmpty ? CachedNetworkImageProvider(ua) : null,
                        backgroundColor: Colors.white12,
                        child: ua.isEmpty ? const Icon(Icons.person, size: 16, color: Colors.white54) : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(c['user_name'] as String? ?? 'مستخدم',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(c['body'] as String? ?? '',
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ])),
                    ]),
                  );
                },
              )),
        // Input
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _commentCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'أضف تعليقاً...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            )),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sending ? null : _sendComment,
              child: Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
                child: _sending
                  ? const Padding(padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
