import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json_utils.dart';
import '../../core/services/notification_service.dart';

String _resolveUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  return url.replaceAll('localhost', '192.168.1.3')
            .replaceAll('127.0.0.1', '192.168.1.3');
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? _user;
  List<Map<String, dynamic>> _upcoming = [];
  List<Map<String, dynamic>> _therapists = [];
  List<Map<String, dynamic>> _reels = [];
  bool _loading = true;
  int _unread = 0;
  int? _mood; // 1-5

  @override
  void initState() {
    super.initState();
    NotificationService.instance.unreadCount.addListener(_onUnread);
    _unread = NotificationService.instance.unreadCount.value;
    _loadAll();
    _loadMood();
  }

  @override
  void dispose() {
    NotificationService.instance.unreadCount.removeListener(_onUnread);
    super.dispose();
  }

  void _onUnread() {
    if (mounted) setState(() => _unread = NotificationService.instance.unreadCount.value);
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final futures = await Future.wait([
        ApiClient.instance.get('/me'),
        ApiClient.instance.get('/patient/appointments',
            queryParameters: {'status': 'confirmed', 'per_page': 1}),
        ApiClient.instance.get('/therapists',
            queryParameters: {'sort': 'rating', 'per_page': 5}),
        ApiClient.instance.get('/reels', queryParameters: {'per_page': 3}),
      ]);
      if (!mounted) return;
      setState(() {
        _user = (futures[0].data as Map<String, dynamic>)['user'] as Map<String, dynamic>?;
        final appts = (futures[1].data['data'] as List?) ?? [];
        _upcoming = appts.cast<Map<String, dynamic>>();
        final therapistsData = (futures[2].data['data'] as List?) ?? [];
        _therapists = therapistsData.cast<Map<String, dynamic>>();
        final reelsData = (futures[3].data['data'] as List?) ?? [];
        _reels = reelsData.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _patientName {
    final patient = _user?['patient'] as Map<String, dynamic>?;
    return patient?['full_name'] as String? ?? 'مستخدم';
  }

  Future<void> _loadMood() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _mood = prefs.getInt('mood_today'));
  }

  Future<void> _saveMood(int v) async {
    setState(() => _mood = v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('mood_today', v);
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مساء الخير';
    return 'مساء النور';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadAll,
        color: AppColors.primary,
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()))
          else ...[
            SliverToBoxAdapter(child: _buildMoodTracker()),
            SliverToBoxAdapter(child: _buildUpcoming()),
            SliverToBoxAdapter(child: _buildQuickActions()),
            SliverToBoxAdapter(child: _buildFeaturedTherapists()),
            SliverToBoxAdapter(child: _buildReelsPreview()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ]),
      ),
    );
  }

  Widget _buildHeader() => Container(
    decoration: const BoxDecoration(gradient: AppGradients.primary),
    padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 28),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_greeting, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
        const SizedBox(height: 2),
        Text(_patientName,
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(DateFormat('EEEE، d MMMM', 'ar').format(DateTime.now()),
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
      ])),
      Stack(children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
          onPressed: () => context.push('/notifications'),
        ),
        if (_unread > 0) Positioned(
          top: 8, left: 8,
          child: Container(
            width: 18, height: 18,
            decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
            child: Center(child: Text('$_unread',
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
          ),
        ),
      ]),
    ]),
  );

  static const _moodEmojis  = ['😢', '😟', '😐', '🙂', '😄'];
  static const _moodLabels  = ['سيء', 'حزين', 'عادي', 'جيد', 'ممتاز'];
  static const _moodColors  = [
    Color(0xFFEF5350), Color(0xFFFF7043),
    Color(0xFF78909C), Color(0xFF66BB6A), Color(0xFF26C6DA),
  ];

  Widget _buildMoodTracker() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('💭', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          const Text('كيف تشعر اليوم؟',
            style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary)),
          const Spacer(),
          if (_mood != null) Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _moodColors[_mood! - 1].withOpacity(0.12),
              borderRadius: BorderRadius.circular(20)),
            child: Text(_moodLabels[_mood! - 1],
              style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: _moodColors[_mood! - 1])),
          ),
        ]),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) {
            final val = i + 1;
            final selected = _mood == val;
            return GestureDetector(
              onTap: () => _saveMood(val),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: selected
                    ? _moodColors[i].withOpacity(0.15)
                    : AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? _moodColors[i] : AppColors.borderLight,
                    width: selected ? 2.5 : 1.5),
                  boxShadow: selected ? [
                    BoxShadow(
                      color: _moodColors[i].withOpacity(0.25),
                      blurRadius: 8, offset: const Offset(0, 3)),
                  ] : null,
                ),
                child: Center(child: Text(_moodEmojis[i],
                  style: TextStyle(fontSize: selected ? 26 : 22))),
              ),
            );
          }),
        ),
      ]),
    ),
  );

  Widget _buildUpcoming() {
    if (_upcoming.isEmpty) return const SizedBox.shrink();
    final appt = _upcoming.first;
    final therapist = (appt['therapist'] as Map<String, dynamic>?) ?? {};
    final scheduledAt = appt['scheduled_at'] as String? ?? '';
    DateTime? dt;
    try { dt = DateTime.parse(scheduledAt); } catch (_) {}

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('موعدك القادم',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppGradients.card,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white24,
              backgroundImage: therapist['avatar'] != null
                ? CachedNetworkImageProvider(_resolveUrl(therapist['avatar'] as String)) : null,
              child: therapist['avatar'] == null
                ? const Icon(Icons.person, color: Colors.white, size: 28) : null,
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(therapist['full_name'] as String? ?? 'الأخصائي',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 3),
              Text(therapist['title'] as String? ?? '',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
              if (dt != null) ...[
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.access_time, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text(DateFormat('d MMM - HH:mm', 'ar').format(dt),
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
                ]),
              ],
            ])),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
          ]),
        ),
      ]),
    );
  }

  Widget _buildQuickActions() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('إجراءات سريعة',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _QuickAction(
          icon: Icons.calendar_month_rounded,
          label: 'احجز موعد',
          color: AppColors.primary,
          onTap: () => context.push('/therapists'),
        )),
        const SizedBox(width: 12),
        Expanded(child: _QuickAction(
          icon: Icons.fitness_center_rounded,
          label: 'برامجي',
          color: AppColors.accent,
          onTap: () => context.push('/programs'),
        )),
        const SizedBox(width: 12),
        Expanded(child: _QuickAction(
          icon: Icons.quiz_rounded,
          label: 'التقييمات',
          color: AppColors.purple,
          onTap: () {},
        )),
      ]),
    ]),
  );

  Widget _buildFeaturedTherapists() {
    if (_therapists.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            const Text('أخصائيون مميزون',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/therapists'),
              child: const Text('عرض الكل',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
          ]),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _therapists.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _TherapistCard(therapist: _therapists[i]),
          ),
        ),
      ]),
    );
  }

  Widget _buildReelsPreview() {
    if (_reels.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            const Text('ريلز الصحة النفسية',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/reels'),
              child: const Text('عرض الكل',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
          ]),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _reels.length.clamp(0, 3),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _ReelPreviewCard(reel: _reels[i]),
          ),
        ),
      ]),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label,
    required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ]),
    ),
  );
}

class _TherapistCard extends StatelessWidget {
  final Map<String, dynamic> therapist;
  const _TherapistCard({required this.therapist});

  @override
  Widget build(BuildContext context) {
    final id = therapist['id'];
    final avatar = _resolveUrl(therapist['avatar'] as String?);
    final rating = jsonDouble(therapist['rating_average']);
    return GestureDetector(
      onTap: () => context.push('/therapists/$id'),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.surfaceAlt,
            backgroundImage: avatar.isNotEmpty ? CachedNetworkImageProvider(avatar) : null,
            child: avatar.isEmpty ? const Icon(Icons.person, size: 36, color: AppColors.textHint) : null,
          ),
          const SizedBox(height: 8),
          Text(therapist['full_name'] as String? ?? '',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
            textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(therapist['title'] as String? ?? '',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.star_rounded, color: AppColors.warning, size: 14),
            const SizedBox(width: 2),
            Text(rating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ]),
        ]),
      ),
    );
  }
}

class _ReelPreviewCard extends StatelessWidget {
  final Map<String, dynamic> reel;
  const _ReelPreviewCard({required this.reel});

  @override
  Widget build(BuildContext context) {
    final therapist = (reel['therapist'] as Map<String, dynamic>?) ?? {};
    final avatar = _resolveUrl(therapist['avatar'] as String?);
    return GestureDetector(
      onTap: () => context.go('/reels'),
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(children: [
          if (avatar.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(imageUrl: avatar,
                fit: BoxFit.cover, width: 120, height: 140,
                errorWidget: (_, __, ___) => const SizedBox()),
            ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)]),
            ),
          ),
          Positioned(
            bottom: 8, left: 8, right: 8,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(reel['title'] as String? ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          ),
          const Positioned(
            top: 8, right: 8,
            child: Icon(Icons.play_circle_filled_rounded, color: Colors.white70, size: 28)),
        ]),
      ),
    );
  }
}
