import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/json_utils.dart';

String _fix(String? url) {
  if (url == null || url.isEmpty) return '';
  return url.replaceAll('localhost', '192.168.1.3').replaceAll('127.0.0.1', '192.168.1.3');
}

class TherapistDetailPage extends StatefulWidget {
  final int id;
  const TherapistDetailPage({required this.id, super.key});
  @override
  State<TherapistDetailPage> createState() => _TherapistDetailPageState();
}

class _TherapistDetailPageState extends State<TherapistDetailPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _therapist;
  Map<String, dynamic>  _stats = {};
  bool   _loading = true;
  String? _error;
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final r    = await ApiClient.instance.get('/therapists/${widget.id}');
      final body = r.data as Map<String, dynamic>;
      final t    = (body['therapist'] ?? body) as Map<String, dynamic>;
      setState(() {
        _therapist = t;
        _stats     = (body['stats'] as Map<String, dynamic>?) ?? {};
        _loading   = false;
      });
    } catch (e) {
      setState(() { _error = 'تعذّر تحميل البيانات'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          ),
        ])),
      );
    }

    final t           = _therapist!;
    final avatar      = _fix(t['avatar'] as String?);
    final name        = t['full_name'] as String? ?? '—';
    final title       = t['title']    as String? ?? '';
    final bio         = t['bio']      as String? ?? '';
    final city        = t['city']     as String? ?? '';
    final gender      = t['gender']   as String?;
    final years       = jsonInt(t['years_experience']);
    final online      = t['accepts_online']    as bool? ?? false;
    final inPerson    = t['accepts_in_person'] as bool? ?? false;
    final onlineP     = jsonDouble(t['online_session_price']);
    final inPersonP   = jsonDouble(t['in_person_session_price']);
    final specs       = (t['specializations'] as List?)?.cast<Map>() ?? [];
    final langs       = (t['languages']       as List?)?.cast<Map>() ?? [];
    final edus        = (t['educations']      as List?)?.cast<Map>() ?? [];
    final certs       = (t['certifications']  as List?)?.cast<Map>() ?? [];
    final reviews     = (t['reviews']         as List?)?.cast<Map>() ?? [];
    final rating      = jsonDouble(_stats['rating_average']);
    final ratingCount = jsonInt(_stats['rating_count']);
    final sessions    = jsonInt(_stats['total_sessions']);
    final patients    = jsonInt(_stats['total_patients']);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primaryDark,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white24,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: _HeroHeader(
                avatar: avatar, name: name, title: title,
                city: city, gender: gender,
                rating: rating, ratingCount: ratingCount,
                sessions: sessions, patients: patients, years: years,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: ColoredBox(
                color: AppColors.primaryDark,
                child: TabBar(
                  controller: _tab,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  tabs: const [
                    Tab(text: 'الملف الشخصي'),
                    Tab(text: 'الإحصائيات'),
                    Tab(text: 'التقييمات'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tab,
          children: [
            _ProfileTab(
              bio: bio, specs: specs, langs: langs,
              edus: edus, certs: certs,
              online: online, inPerson: inPerson,
              onlinePrice: onlineP, inPersonPrice: inPersonP,
            ),
            _StatsTab(stats: _stats),
            _ReviewsTab(reviews: reviews),
          ],
        ),
      ),
      bottomNavigationBar: _BottomBar(t: t),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Header
// ─────────────────────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final String avatar, name, title, city;
  final String? gender;
  final double rating;
  final int ratingCount, sessions, patients, years;
  const _HeroHeader({
    required this.avatar, required this.name, required this.title,
    required this.city, this.gender,
    required this.rating, required this.ratingCount,
    required this.sessions, required this.patients, required this.years,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF0F1D48), Color(0xFF1B2E6E), Color(0xFF2D4A9E)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 3),
                boxShadow: [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: CircleAvatar(
                radius: 46,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: avatar.isNotEmpty
                    ? CachedNetworkImageProvider(avatar) : null,
                child: avatar.isEmpty
                    ? Text(name.isNotEmpty ? name[0] : '؟',
                        style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.w800))
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2)),
              if (title.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(fontSize: 13, color: Colors.white70)),
              ],
              const SizedBox(height: 8),
              Row(children: [
                if (city.isNotEmpty) ...[
                  const Icon(Icons.location_on_rounded, size: 13, color: Colors.white54),
                  const SizedBox(width: 3),
                  Text(city, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                  const SizedBox(width: 8),
                ],
                if (gender != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(gender == 'male' ? '♂ ذكر' : '♀ أنثى',
                      style: const TextStyle(fontSize: 11, color: Colors.white70)),
                  ),
              ]),
              const SizedBox(height: 10),
              // Stars
              Row(children: [
                ...List.generate(5, (i) => Icon(
                  i < rating.round()
                      ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 16,
                  color: i < rating.round()
                      ? const Color(0xFFFBBF24) : Colors.white30,
                )),
                const SizedBox(width: 6),
                Text('${rating.toStringAsFixed(1)} ($ratingCount)',
                  style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ]),
            ])),
          ]),
          const SizedBox(height: 20),
          // Stats row
          Row(children: [
            _HeroStat(value: '$years', label: 'سنوات خبرة', icon: Icons.workspace_premium_rounded),
            _HeroStat(value: '$sessions', label: 'جلسة منجزة', icon: Icons.event_available_rounded),
            _HeroStat(value: '$patients', label: 'مريض', icon: Icons.people_rounded),
          ]),
        ]),
      ),
    ),
  );
}

class _HeroStat extends StatelessWidget {
  final String value, label;
  final IconData icon;
  const _HeroStat({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile Tab
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  final String bio;
  final List<Map> specs, langs, edus, certs;
  final bool online, inPerson;
  final double onlinePrice, inPersonPrice;
  const _ProfileTab({
    required this.bio, required this.specs, required this.langs,
    required this.edus, required this.certs,
    required this.online, required this.inPerson,
    required this.onlinePrice, required this.inPersonPrice,
  });

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
    children: [
      // Session types
      Row(children: [
        if (online) Expanded(child: _PriceCard(
          icon: Icons.videocam_rounded, label: 'أونلاين',
          price: onlinePrice, color: AppColors.primary)),
        if (online && inPerson) const SizedBox(width: 12),
        if (inPerson) Expanded(child: _PriceCard(
          icon: Icons.location_on_rounded, label: 'حضوري',
          price: inPersonPrice, color: AppColors.accent)),
      ]),
      const SizedBox(height: 20),

      // Bio
      if (bio.isNotEmpty) ...[
        const _SectionTitle(title: 'نبذة تعريفية', icon: Icons.info_outline_rounded),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(bio, style: const TextStyle(
              fontSize: 14, color: AppColors.textSecondary, height: 1.8)),
        ),
        const SizedBox(height: 20),
      ],

      // Specializations
      if (specs.isNotEmpty) ...[
        const _SectionTitle(title: 'التخصصات', icon: Icons.psychology_rounded),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: specs.map((s) =>
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(s['name_ar'] as String? ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 12,
                  fontWeight: FontWeight.w600)),
          )).toList()),
        const SizedBox(height: 20),
      ],

      // Languages
      if (langs.isNotEmpty) ...[
        const _SectionTitle(title: 'اللغات', icon: Icons.translate_rounded),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: langs.map((l) =>
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(l['language'] as String? ?? '',
              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600)),
          )).toList()),
        const SizedBox(height: 20),
      ],

      // Education
      if (edus.isNotEmpty) ...[
        const _SectionTitle(title: 'التعليم والمؤهلات', icon: Icons.school_rounded),
        const SizedBox(height: 10),
        ...edus.map((e) => _TimelineCard(
          title: e['degree'] as String? ?? '',
          subtitle: e['institution'] as String? ?? '',
          year: e['year']?.toString(),
          color: AppColors.primary,
        )),
        const SizedBox(height: 20),
      ],

      // Certifications
      if (certs.isNotEmpty) ...[
        const _SectionTitle(title: 'الشهادات والدورات', icon: Icons.workspace_premium_rounded),
        const SizedBox(height: 10),
        ...certs.map((c) => _TimelineCard(
          title: c['name'] as String? ?? '',
          subtitle: c['issuer'] as String? ?? '',
          year: c['year']?.toString(),
          color: AppColors.accent,
        )),
      ],
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Statistics Tab
// ─────────────────────────────────────────────────────────────────────────────
class _StatsTab extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _StatsTab({required this.stats});

  @override
  Widget build(BuildContext context) {
    final rating      = jsonDouble(stats['rating_average']);
    final ratingCount = jsonInt(stats['rating_count']);
    final sessions    = jsonInt(stats['total_sessions']);
    final patients    = jsonInt(stats['total_patients']);
    final years       = jsonInt(stats['years_experience']);
    final dist        = (stats['rating_distribution'] as Map?)?.cast<String, dynamic>() ?? {};
    final monthly     = (stats['monthly_sessions']    as Map?)?.cast<String, dynamic>() ?? {};

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Stat cards grid
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.35,
          children: [
            _StatCard(value: rating.toStringAsFixed(1), suffix: '/ 5',
              label: 'متوسط التقييم', icon: Icons.star_rounded,
              color: const Color(0xFFF59E0B)),
            _StatCard(value: '$ratingCount',
              label: 'عدد التقييمات', icon: Icons.rate_review_rounded,
              color: AppColors.primary),
            _StatCard(value: '$sessions',
              label: 'إجمالي الجلسات', icon: Icons.event_available_rounded,
              color: AppColors.accent),
            _StatCard(value: '$patients',
              label: 'إجمالي المرضى', icon: Icons.people_rounded,
              color: const Color(0xFF059669)),
          ],
        ),
        const SizedBox(height: 24),

        // Rating distribution
        if (ratingCount > 0) ...[
          const _SectionTitle(title: 'توزيع التقييمات', icon: Icons.bar_chart_rounded),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(children: [
              for (int star = 5; star >= 1; star--) ...[
                _RatingBar(
                  star: star,
                  count: jsonInt(dist[star.toString()]),
                  total: ratingCount,
                ),
                if (star > 1) const SizedBox(height: 10),
              ],
            ]),
          ),
          const SizedBox(height: 24),
        ],

        // Monthly sessions chart
        if (monthly.isNotEmpty) ...[
          const _SectionTitle(
              title: 'الجلسات الشهرية (آخر 6 أشهر)',
              icon: Icons.show_chart_rounded),
          const SizedBox(height: 12),
          Container(
            height: 190,
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: _MonthlyChart(data: monthly),
          ),
        ],

        // Years experience highlight
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                  color: Colors.white12, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.workspace_premium_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$years سنوات',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                    color: Colors.white)),
              const Text('من الخبرة المهنية',
                style: TextStyle(fontSize: 13, color: Colors.white70)),
            ]),
          ]),
        ),
      ],
    );
  }
}

class _MonthlyChart extends StatelessWidget {
  final Map<String, dynamic> data;
  const _MonthlyChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final sorted = data.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    if (sorted.isEmpty) return const Center(child: Text('لا توجد بيانات'));
    final maxVal = sorted
        .map((e) => jsonDouble(e.value))
        .fold(0.0, (a, b) => a > b ? a : b);
    final maxY = (maxVal + 2).ceilToDouble();

    const monthNames = [
      '', 'يناير','فبراير','مارس','أبريل','مايو','يونيو',
      'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'
    ];

    return LineChart(LineChartData(
      minY: 0, maxY: maxY,
      gridData: FlGridData(
        show: true,
        horizontalInterval: maxY > 4 ? (maxY / 4).ceilToDouble() : 1,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: AppColors.borderLight, strokeWidth: 1),
        drawVerticalLine: false,
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true, reservedSize: 28,
          getTitlesWidget: (v, _) => v == 0 ? const SizedBox() : Text(
            v.toInt().toString(),
            style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
        )),
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true, reservedSize: 22,
          getTitlesWidget: (v, _) {
            final i = v.toInt();
            if (i < 0 || i >= sorted.length) return const SizedBox();
            final parts = sorted[i].key.split('-');
            final month = parts.length >= 2 ? (int.tryParse(parts[1]) ?? 0) : 0;
            return Text(monthNames[month],
              style: const TextStyle(fontSize: 9, color: AppColors.textHint));
          },
        )),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: sorted.asMap().entries.map((e) =>
            FlSpot(e.key.toDouble(), jsonDouble(e.value.value))).toList(),
          isCurved: true,
          color: AppColors.primary,
          barWidth: 3,
          dotData: FlDotData(show: true,
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
              radius: 4, color: AppColors.primary,
              strokeWidth: 2, strokeColor: Colors.white)),
          belowBarData: BarAreaData(show: true,
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.22),
                AppColors.primary.withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            )),
        ),
      ],
    ));
  }
}

class _RatingBar extends StatelessWidget {
  final int star, count, total;
  const _RatingBar({required this.star, required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? count / total : 0.0;
    return Row(children: [
      Text('$star', style: const TextStyle(fontSize: 12,
          fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
      const SizedBox(width: 4),
      const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
      const SizedBox(width: 8),
      Expanded(child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: pct, minHeight: 8,
          backgroundColor: AppColors.surfaceAlt,
          valueColor: const AlwaysStoppedAnimation(Color(0xFFF59E0B)),
        ),
      )),
      const SizedBox(width: 8),
      SizedBox(width: 28, child: Text('$count',
        style: const TextStyle(fontSize: 11, color: AppColors.textHint),
        textAlign: TextAlign.end)),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reviews Tab
// ─────────────────────────────────────────────────────────────────────────────
class _ReviewsTab extends StatelessWidget {
  final List<Map> reviews;
  const _ReviewsTab({required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.star_border_rounded, size: 64, color: AppColors.textHint),
        SizedBox(height: 12),
        Text('لا توجد تقييمات بعد',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: reviews.length,
      itemBuilder: (_, i) {
        final r       = reviews[i];
        final patient = r['patient'] as Map?;
        final pName   = patient?['full_name'] as String?
            ?? r['patient_name'] as String? ?? 'مريض';
        final rating  = jsonInt(r['rating']);
        final comment = r['comment'] as String?;
        final date    = r['created_at'] as String?;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(
                radius: 20, backgroundColor: AppColors.primary,
                child: Text(pName.isNotEmpty ? pName[0] : '؟',
                  style: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(pName, style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13)),
                if (date != null) Text(_fmtDate(date),
                  style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
              ])),
              Row(children: List.generate(5, (j) => Icon(
                j < rating
                    ? Icons.star_rounded : Icons.star_border_rounded,
                size: 16,
                color: j < rating
                    ? const Color(0xFFF59E0B) : AppColors.border,
              ))),
            ]),
            if (comment != null && comment.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(comment, style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
              ),
            ],
          ]),
        );
      },
    );
  }

  String _fmtDate(String iso) {
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    return DateFormat('d MMMM y', 'ar').format(dt);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Bar
// ─────────────────────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final Map<String, dynamic> t;
  const _BottomBar({required this.t});

  @override
  Widget build(BuildContext context) {
    final id    = jsonInt(t['id']);
    final name  = t['full_name'] as String? ?? '';
    final phone = (t['user'] as Map?)?['phone'] as String?;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: Row(children: [

          // ── Phone call button ──────────────────────────────────
          if (phone != null && phone.isNotEmpty) ...[
            _IconBtn(
              icon: Icons.phone_rounded,
              color: AppColors.success,
              tooltip: phone,
              onTap: () => launchUrl(Uri.parse('tel:$phone')),
            ),
            const SizedBox(width: 8),
          ],

          // ── Message button ─────────────────────────────────────
          OutlinedButton.icon(
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            label: const Text('رسالة'),
            onPressed: () => context.push('/messages/new',
                extra: {'partnerId': id, 'name': name}),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(width: 12),

          // ── Book button ────────────────────────────────────────
          Expanded(child: ElevatedButton.icon(
            icon: const Icon(Icons.calendar_month_rounded, size: 18),
            label: const Text('احجز موعداً',
                style: TextStyle(fontWeight: FontWeight.w700)),
            onPressed: () => context.push('/therapists/$id/book'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          )),
        ]),
      ),
    );
  }
}

// Small icon button used in the bottom bar
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  const _IconBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Widgets
// ─────────────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 17, color: AppColors.primary),
    ),
    const SizedBox(width: 10),
    Text(title, style: const TextStyle(
        fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
  ]);
}

class _PriceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double price;
  final Color color;
  const _PriceCard({required this.icon, required this.label,
      required this.price, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Row(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, color: color,
            fontWeight: FontWeight.w600)),
        Text(price > 0 ? '${price.toInt()} ₪' : 'مجاناً',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: color)),
      ]),
    ]),
  );
}

class _TimelineCard extends StatelessWidget {
  final String title, subtitle;
  final String? year;
  final Color color;
  const _TimelineCard({required this.title, required this.subtitle,
      this.year, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(children: [
      Container(width: 4, height: 44,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(
            fontWeight: FontWeight.w700, fontSize: 13)),
        if (subtitle.isNotEmpty)
          Text(subtitle, style: const TextStyle(
              fontSize: 12, color: AppColors.textSecondary)),
      ])),
      if (year != null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(year!, style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w700)),
        ),
    ]),
  );
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final String? suffix;
  final IconData icon;
  final Color color;
  const _StatCard({required this.value, required this.label,
      required this.icon, required this.color, this.suffix});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 19),
      ),
      const SizedBox(height: 8),
      Row(crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic, children: [
        Text(value, style: TextStyle(fontSize: 22,
            fontWeight: FontWeight.w900, color: color)),
        if (suffix != null)
          Text(suffix!, style: const TextStyle(
              fontSize: 11, color: AppColors.textHint)),
      ]),
      Text(label, style: const TextStyle(
          fontSize: 11, color: AppColors.textSecondary)),
    ]),
  );
}
