import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/json_utils.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map _therapist = {}, _user = {}, _stats = {};
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final [meRes, statsRes] = await Future.wait([
        ApiClient.instance.get('/me'),
        ApiClient.instance.get('/therapist/statistics'),
      ]);
      setState(() {
        _user      = meRes.data['user']           as Map? ?? {};
        _therapist = (_user['therapist']          as Map?) ?? {};
        _stats     = (statsRes.data['statistics'] as Map?) ?? {};
        _loading   = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف الحساب نهائياً'),
        content: const Text(
          'سيتم حذف جميع بياناتك ومواعيدك ووثائقك بشكل نهائي.\n\nهل أنت متأكد من هذا الإجراء؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('نعم، احذف حسابي')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final passCtrl = TextEditingController();
    final passwordOk = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تأكيد كلمة المرور'),
        content: TextField(
          controller: passCtrl,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'كلمة المرور الحالية',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('تأكيد الحذف',
              style: TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (passwordOk != true || !mounted) return;

    try {
      await ApiClient.instance.delete('/account', data: {'password': passCtrl.text});
      await ApiClient.clearToken();
      if (!mounted) return;
      context.go('/auth');
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?
          ?? 'كلمة المرور غير صحيحة';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ، حاول مجدداً')));
      }
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('تسجيل الخروج'),
      content: const Text('هل تريد تسجيل الخروج؟'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
        TextButton(onPressed: () => Navigator.pop(context, true),
            child: const Text('خروج', style: TextStyle(color: AppColors.error))),
      ],
    ));
    if (ok == true && mounted) {
      try { await ApiClient.instance.post('/logout'); } catch (_) {}
      await ApiClient.clearToken();
      if (mounted) context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final name  = _therapist['full_name'] as String? ?? '';
    final title = _therapist['title']     as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(slivers: [

          // ── Hero header ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            actions: [
              IconButton(
                icon: Container(padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                  child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18)),
                onPressed: () => context.push('/profile/edit').then((_) => _load()),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: _HeroHeader(therapist: _therapist, user: _user, stats: _stats),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
            sliver: SliverList(delegate: SliverChildListDelegate([

              // ── Quick stats row ──────────────────────────────
              _QuickStatsRow(stats: _stats, therapist: _therapist),
              const SizedBox(height: 16),

              // ── Bio card ─────────────────────────────────────
              if ((_therapist['bio'] as String? ?? '').isNotEmpty) ...[
                _ProfileSection(
                  icon: Icons.auto_stories_rounded,
                  iconColor: AppColors.primary,
                  title: 'نبذة شخصية',
                  child: Text(_therapist['bio'],
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.7)),
                ),
                const SizedBox(height: 12),
              ],

              // ── Info card ─────────────────────────────────────
              _ProfileSection(
                icon: Icons.badge_rounded,
                iconColor: const Color(0xFF7C3AED),
                title: 'المعلومات الأساسية',
                child: Column(children: [
                  _PhoneRow(phone: _user['phone']?.toString() ?? '—'),
                  _divider(),
                  _InfoRow(Icons.location_on_outlined, 'المدينة', _therapist['city']?.toString() ?? '—'),
                  _divider(),
                  _InfoRow(Icons.school_outlined, 'الدرجة العلمية', _therapist['degree']?.toString() ?? '—'),
                  _divider(),
                  _InfoRow(Icons.work_history_outlined, 'سنوات الخبرة',
                      '${_therapist['years_experience'] ?? 0} سنة'),
                  _divider(),
                  _InfoRow(Icons.person_2_outlined, 'الجنس',
                      _therapist['gender'] == 'male' ? 'ذكر' : 'أنثى'),
                ]),
              ),
              const SizedBox(height: 12),

              // ── Specializations ───────────────────────────────
              if ((_therapist['specializations'] as List? ?? []).isNotEmpty) ...[
                _ProfileSection(
                  icon: Icons.psychology_rounded,
                  iconColor: AppColors.accent,
                  title: 'التخصصات',
                  child: Wrap(spacing: 8, runSpacing: 8,
                    children: (_therapist['specializations'] as List).map<Widget>((s) =>
                      _SpecChip(label: (s as Map)['name_ar'] ?? '')).toList()),
                ),
                const SizedBox(height: 12),
              ],

              // ── Languages ─────────────────────────────────────
              if ((_therapist['languages'] as List? ?? []).isNotEmpty) ...[
                _ProfileSection(
                  icon: Icons.language_rounded,
                  iconColor: const Color(0xFFEF6C00),
                  title: 'اللغات',
                  child: Column(
                    children: (_therapist['languages'] as List).map<Widget>((l) {
                      final m = l as Map;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(children: [
                          Container(width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF6C00).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10)),
                            child: const Center(child: Icon(Icons.translate_rounded,
                                color: Color(0xFFEF6C00), size: 18))),
                          const SizedBox(width: 12),
                          Expanded(child: Text(m['language'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                          _LevelBadge(level: m['proficiency'] as String? ?? ''),
                        ]),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ── Education ─────────────────────────────────────
              if ((_therapist['educations'] as List? ?? []).isNotEmpty) ...[
                _ProfileSection(
                  icon: Icons.school_rounded,
                  iconColor: const Color(0xFF0288D1),
                  title: 'المؤهلات العلمية',
                  child: Column(
                    children: (_therapist['educations'] as List).map<Widget>((e) {
                      final m = e as Map;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(color: const Color(0xFF0288D1), shape: BoxShape.circle)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(m['degree'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            Text(m['institution'] ?? '',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            if (m['graduation_year'] != null)
                              Text('${m['graduation_year']}',
                                  style: const TextStyle(color: AppColors.primary, fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                          ])),
                        ]),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ── Links ─────────────────────────────────────────
              _ProfileSection(
                icon: Icons.link_rounded,
                iconColor: AppColors.primary,
                title: 'الصفحات',
                child: Column(children: [
                  _NavRow(Icons.article_outlined, 'مقالاتي التثقيفية', '/articles',
                      '${_stats['articles_count'] ?? ''}', AppColors.accent),
                  _divider(),
                  _NavRow(Icons.video_collection_outlined, 'الريلز', '/reels',
                      '${_stats['reels_count'] ?? ''}', AppColors.primary),
                  _divider(),
                  _NavRow(Icons.bar_chart_rounded, 'الإحصائيات التفصيلية', '/statistics',
                      '', const Color(0xFF7C3AED)),
                ]),
              ),
              const SizedBox(height: 24),

              // ── Logout ────────────────────────────────────────
              OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('تسجيل الخروج', style: TextStyle(fontSize: 15)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 8),
              // ── Delete Account ─────────────────────────────────
              TextButton(
                onPressed: _deleteAccount,
                child: const Text('حذف الحساب نهائياً',
                  style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                  )),
              ),
            ])),
          ),
        ]),
      ),
    );
  }

  Widget _divider() => const Divider(height: 16, thickness: 1, color: AppColors.border);
}

// ── Hero Header ─────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final Map therapist, user, stats;
  const _HeroHeader({required this.therapist, required this.user, required this.stats});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF0A2A38), AppColors.primary, Color(0xFF2D8EAD)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
    ),
    child: SafeArea(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(height: 16),
        // Avatar with glow ring
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.6), Colors.white.withOpacity(0.1)],
            ),
          ),
          child: _buildAvatar(),
        ),
        const SizedBox(height: 14),
        Text(therapist['full_name'] as String? ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        if ((therapist['title'] as String? ?? '').isNotEmpty)
          Text(therapist['title'] as String,
              style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
        const SizedBox(height: 10),
        Row(mainAxisSize: MainAxisSize.min, children: [
          if (therapist['is_approved'] == true)
            _badge(Icons.verified_rounded, 'موثق', Colors.greenAccent),
          if (therapist['is_approved'] == true) const SizedBox(width: 8),
          _badge(Icons.location_on_rounded, therapist['city'] as String? ?? '', Colors.white70),
        ]),
      ]),
    ),
  );

  Widget _buildAvatar() {
    final path = therapist['avatar'] as String?;
    if (path != null) {
      final base = ApiClient.instance.options.baseUrl.replaceAll('/api', '');
      return CircleAvatar(radius: 52,
          backgroundImage: CachedNetworkImageProvider('$base/storage/$path'));
    }
    final n = therapist['full_name'] as String? ?? 'م';
    return CircleAvatar(radius: 52,
        backgroundColor: Colors.white.withOpacity(0.2),
        child: Text(n.isNotEmpty ? n[0] : 'م',
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)));
  }

  Widget _badge(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: color, size: 13),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    ]),
  );
}

// ── Quick stats row ──────────────────────────────────────────────
class _QuickStatsRow extends StatelessWidget {
  final Map stats, therapist;
  const _QuickStatsRow({required this.stats, required this.therapist});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: Row(children: [
      _stat('${stats['total_appointments'] ?? 0}', 'جلسة', Icons.event_note_rounded, AppColors.primary),
      _divV(),
      _stat('${stats['total_patients'] ?? 0}', 'مريض', Icons.people_alt_rounded, const Color(0xFF7C3AED)),
      _divV(),
      _statRating(therapist),
    ]),
  );

  Widget _stat(String val, String lbl, IconData icon, Color color) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        Text(lbl, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    ),
  );

  Widget _statRating(Map t) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(children: [
        const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
        const SizedBox(height: 6),
        Text(
          jsonDouble(t['rating_average']).toStringAsFixed(1),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.amber),
        ),
        Text('من ${t['rating_count'] ?? 0} تقييم',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    ),
  );

  Widget _divV() => Container(width: 1, height: 56, color: AppColors.border);
}

// ── Section card ─────────────────────────────────────────────────
class _ProfileSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;
  const _ProfileSection({required this.icon, required this.iconColor, required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 18)),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      ]),
      const SizedBox(height: 16),
      child,
    ]),
  );
}

// ── Info row ─────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: AppColors.primary, size: 20),
    const SizedBox(width: 12),
    Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
    const Spacer(),
    Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
  ]);
}

/// Phone row with tap-to-call button
class _PhoneRow extends StatelessWidget {
  final String phone;
  const _PhoneRow({required this.phone});

  Future<void> _call() async {
    if (phone == '—' || phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) => Row(children: [
    const Icon(Icons.phone_outlined, color: AppColors.primary, size: 20),
    const SizedBox(width: 12),
    const Text('الهاتف', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
    const Spacer(),
    Text(phone, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
    const SizedBox(width: 8),
    GestureDetector(
      onTap: _call,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: AppColors.success.withOpacity(0.35)),
        ),
        child: const Icon(Icons.phone_rounded, color: AppColors.success, size: 16),
      ),
    ),
  ]);
}

// ── Nav row ──────────────────────────────────────────────────────
class _NavRow extends StatelessWidget {
  final IconData icon;
  final String label, route, badge;
  final Color color;
  const _NavRow(this.icon, this.label, this.route, this.badge, this.color);

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(10),
    onTap: () => context.push(route),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
        if (badge.isNotEmpty && badge != '0' && badge != 'null')
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(badge, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700))),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary, size: 20),
      ]),
    ),
  );
}

// ── Specialty chip ───────────────────────────────────────────────
class _SpecChip extends StatelessWidget {
  final String label;
  const _SpecChip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primary.withOpacity(0.08), AppColors.primaryLight.withOpacity(0.12)],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
    ),
    child: Text(label, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
  );
}

// ── Level badge ──────────────────────────────────────────────────
class _LevelBadge extends StatelessWidget {
  final String level;
  const _LevelBadge({required this.level});

  static const _map = {
    'basic': ('أساسية', Color(0xFFEF6C00)),
    'conversational': ('محادثة', Color(0xFF0288D1)),
    'fluent': ('طليقة', AppColors.success),
    'native': ('لغة أم', Color(0xFF7C3AED)),
  };

  @override
  Widget build(BuildContext context) {
    final info = _map[level] ?? (level, AppColors.textSecondary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (info.$2 as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(info.$1 as String,
          style: TextStyle(fontSize: 11, color: info.$2 as Color, fontWeight: FontWeight.w600)),
    );
  }
}
