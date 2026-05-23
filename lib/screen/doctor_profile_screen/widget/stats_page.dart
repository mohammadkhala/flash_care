import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:patient_flutter/model/doctor/doctor_review.dart';
import 'package:patient_flutter/model/doctor/fetch_doctor.dart';
import 'package:patient_flutter/screen/doctor_profile_screen/doctor_profile_screen_controller.dart';
import 'package:patient_flutter/utils/color_res.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Colours
// ─────────────────────────────────────────────────────────────────────────────
const _kTeal       = Color(0xFF00897B);
const _kTealLight  = Color(0xFFE0F2F1);
const _kOrange     = Color(0xFFFF7043);
const _kBlue       = Color(0xFF1E88E5);
const _kPurple     = Color(0xFF7E57C2);
const _kGold       = Color(0xFFFFC107);
const _kBg         = Color(0xFFF5F7FA);
const _kCard       = Colors.white;

// ─────────────────────────────────────────────────────────────────────────────
// Main Stats Page
// ─────────────────────────────────────────────────────────────────────────────
class StatsPage extends StatefulWidget {
  final DoctorProfileScreenController controller;
  const StatsPage({super.key, required this.controller});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _progress;

  DoctorData get doc => widget.controller.doctorData!;
  List<DoctorReviewData> get reviews => widget.controller.review;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _progress = CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
    WidgetsBinding.instance.addPostFrameCallback((_) => _anim.forward());
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  // ── Computed values ──────────────────────────────────────────────────────
  int get totalReviews => reviews.length;

  Map<int, int> get ratingCounts {
    final m = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in reviews) {
      final s = (r.rating ?? 0).clamp(1, 5);
      m[s] = (m[s] ?? 0) + 1;
    }
    return m;
  }

  double get avgRating {
    if (doc.rating != null && doc.rating != 0) return doc.rating!;
    if (reviews.isEmpty) return 0;
    final sum = reviews.fold(0, (p, r) => p + (r.rating ?? 0));
    return sum / reviews.length;
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kBg,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Quick Stat Cards Row ─────────────────────────────────────────
          _sectionTitle('نظرة عامة'),
          const SizedBox(height: 12),
          _quickStatsRow(),
          const SizedBox(height: 20),

          // ── Rating Distribution ──────────────────────────────────────────
          _sectionTitle('توزيع التقييمات'),
          const SizedBox(height: 12),
          _ratingCard(),
          const SizedBox(height: 20),

          // ── Appointment Types ────────────────────────────────────────────
          _sectionTitle('أنواع الاستشارة المتاحة'),
          const SizedBox(height: 12),
          _appointmentTypesRow(),
          const SizedBox(height: 20),

          // ── Activity Donut ───────────────────────────────────────────────
          if (totalReviews > 0) ...[
            _sectionTitle('مستوى الرضا'),
            const SizedBox(height: 12),
            _satisfactionDonut(),
            const SizedBox(height: 20),
          ],

          // ── Expertise Tags ───────────────────────────────────────────────
          if ((doc.expertise?.isNotEmpty ?? false)) ...[
            _sectionTitle('مجالات التخصص'),
            const SizedBox(height: 12),
            _expertiseTags(),
            const SizedBox(height: 20),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Section title
  // ─────────────────────────────────────────────────────────────────────────
  Widget _sectionTitle(String title) => Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: _kTeal,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1A2B3C))),
        ],
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Quick stat cards (4 in a row)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _quickStatsRow() => Row(
        children: [
          _statCard(
            icon: Icons.star_rounded,
            color: _kGold,
            value: avgRating > 0 ? avgRating.toStringAsFixed(1) : '—',
            label: 'التقييم',
          ),
          const SizedBox(width: 10),
          _statCard(
            icon: Icons.rate_review_rounded,
            color: _kTeal,
            value: '$totalReviews',
            label: 'تقييم',
          ),
          const SizedBox(width: 10),
          _statCard(
            icon: Icons.workspace_premium_rounded,
            color: _kPurple,
            value: doc.experienceYear != null ? '${doc.experienceYear}' : '—',
            label: 'سنة خبرة',
          ),
          const SizedBox(width: 10),
          _statCard(
            icon: Icons.attach_money_rounded,
            color: _kOrange,
            value: doc.consultationFee != null
                ? '\$${doc.consultationFee}'
                : '—',
            label: 'رسوم الجلسة',
          ),
        ],
      );

  Widget _statCard({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) =>
      Expanded(
        child: AnimatedBuilder(
          animation: _progress,
          builder: (_, __) => Transform.translate(
            offset: Offset(0, 20 * (1 - _progress.value)),
            child: Opacity(
              opacity: _progress.value.clamp(0.0, 1.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                decoration: BoxDecoration(
                  color: _kCard,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: color.withValues(alpha: .12),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: .15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(value,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: color)),
                    const SizedBox(height: 2),
                    Text(label,
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Rating Distribution Card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _ratingCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: big rating number + stars
            Column(
              children: [
                Text(
                  avgRating > 0 ? avgRating.toStringAsFixed(1) : '—',
                  style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2B3C)),
                ),
                _starRow(avgRating),
                const SizedBox(height: 4),
                Text('$totalReviews تقييم',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
            const SizedBox(width: 20),
            // Right: bar chart
            Expanded(
              child: Column(
                children: [5, 4, 3, 2, 1].map((star) {
                  final count = ratingCounts[star] ?? 0;
                  final pct = totalReviews > 0 ? count / totalReviews : 0.0;
                  return _ratingBar(star, pct, count);
                }).toList(),
              ),
            ),
          ],
        ),
      );

  Widget _starRow(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final full = i < rating.floor();
        final half = !full && i < rating;
        return Icon(
          full
              ? Icons.star_rounded
              : half
                  ? Icons.star_half_rounded
                  : Icons.star_border_rounded,
          size: 16,
          color: _kGold,
        );
      }),
    );
  }

  Widget _ratingBar(int star, double pct, int count) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Text('$star', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            const Icon(Icons.star_rounded, size: 12, color: _kGold),
            const SizedBox(width: 8),
            Expanded(
              child: AnimatedBuilder(
                animation: _progress,
                builder: (_, __) => ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct * _progress.value,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(
                        star >= 4 ? _kTeal : star == 3 ? _kGold : _kOrange),
                    minHeight: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 22,
              child: Text('$count',
                  style:
                      TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  textAlign: TextAlign.end),
            ),
          ],
        ),
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Appointment Types
  // ─────────────────────────────────────────────────────────────────────────
  Widget _appointmentTypesRow() => Row(
        children: [
          _appointmentTypeCard(
            icon: Icons.videocam_rounded,
            color: _kTeal,
            title: 'أونلاين',
            subtitle: 'استشارة عن بُعد',
            available: doc.onlineConsultation == 1,
          ),
          const SizedBox(width: 12),
          _appointmentTypeCard(
            icon: Icons.local_hospital_rounded,
            color: _kBlue,
            title: 'في العيادة',
            subtitle: doc.clinicAddress ?? 'حضوري',
            available: doc.clinicConsultation == 1,
          ),
        ],
      );

  Widget _appointmentTypeCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool available,
  }) =>
      Expanded(
        child: AnimatedBuilder(
          animation: _progress,
          builder: (_, __) => Opacity(
            opacity: _progress.value.clamp(0.0, 1.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: available ? color.withValues(alpha: .08) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: available ? color.withValues(alpha: .3) : Colors.grey.shade300,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: available
                              ? color.withValues(alpha: .15)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon,
                            color: available ? color : Colors.grey.shade400,
                            size: 22),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: available
                              ? Colors.green.withValues(alpha: .15)
                              : Colors.grey.withValues(alpha: .15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: available ? Colors.green : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              available ? 'متاح' : 'غير متاح',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: available
                                      ? Colors.green.shade700
                                      : Colors.grey.shade600,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: available ? color : Colors.grey.shade500)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Satisfaction Donut Chart
  // ─────────────────────────────────────────────────────────────────────────
  Widget _satisfactionDonut() {
    final pos = reviews.where((r) => (r.rating ?? 0) >= 4).length;
    final neu = reviews.where((r) => (r.rating ?? 0) == 3).length;
    final neg = reviews.where((r) => (r.rating ?? 0) <= 2).length;
    final total = reviews.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          // Donut chart
          AnimatedBuilder(
            animation: _progress,
            builder: (_, __) => SizedBox(
              width: 110,
              height: 110,
              child: CustomPaint(
                painter: _DonutPainter(
                  sections: [
                    _DonutSection(
                        value: total > 0 ? pos / total : 0,
                        color: _kTeal),
                    _DonutSection(
                        value: total > 0 ? neu / total : 0,
                        color: _kGold),
                    _DonutSection(
                        value: total > 0 ? neg / total : 0,
                        color: _kOrange),
                  ],
                  progress: _progress.value,
                  centerText: total > 0
                      ? '${((pos / total) * 100).round()}%'
                      : '—',
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Legend
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _legendItem(_kTeal, 'راضون', pos, total),
                const SizedBox(height: 10),
                _legendItem(_kGold, 'محايدون', neu, total),
                const SizedBox(height: 10),
                _legendItem(_kOrange, 'غير راضين', neg, total),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, int count, int total) {
    final pct = total > 0 ? '${((count / total) * 100).round()}%' : '0%';
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF1A2B3C))),
        ),
        Text('$count',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: color)),
        const SizedBox(width: 6),
        Text(pct,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Expertise Tags
  // ─────────────────────────────────────────────────────────────────────────
  Widget _expertiseTags() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (doc.expertise ?? []).map((e) {
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _kTealLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _kTeal.withValues(alpha: .3)),
              ),
              child: Text(
                e.title ?? '',
                style: const TextStyle(
                    fontSize: 12,
                    color: _kTeal,
                    fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Donut Painter
// ─────────────────────────────────────────────────────────────────────────────
class _DonutSection {
  final double value;
  final Color color;
  const _DonutSection({required this.value, required this.color});
}

class _DonutPainter extends CustomPainter {
  final List<_DonutSection> sections;
  final double progress;
  final String centerText;

  const _DonutPainter({
    required this.sections,
    required this.progress,
    required this.centerText,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final outerR = math.min(size.width, size.height) / 2;
    const strokeW = 18.0;
    final innerR = outerR - strokeW;

    // Background ring
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW;
    canvas.drawCircle(center, outerR - strokeW / 2, bgPaint);

    // Segments
    double startAngle = -math.pi / 2;
    for (final s in sections) {
      if (s.value <= 0) continue;
      final sweep = 2 * math.pi * s.value * progress;
      final paint = Paint()
        ..color = s.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerR - strokeW / 2),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep + 0.04;
    }

    // Center text
    final tp = TextPainter(
      text: TextSpan(
        text: centerText,
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A2B3C)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
        canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress;
}
