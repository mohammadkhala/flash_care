import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../calls/presentation/pages/webrtc_call_page.dart';

String _resolveUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  return url.replaceAll('localhost', '192.168.1.10')
            .replaceAll('127.0.0.1', '192.168.1.10');
}

class AppointmentDetailPage extends StatefulWidget {
  final int id;
  const AppointmentDetailPage({required this.id, super.key});

  @override
  State<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  Map<String, dynamic>? _appointment;
  bool _loading = true;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get('/patient/appointments/${widget.id}');
      if (!mounted) return;
      setState(() {
        _appointment = res.data as Map<String, dynamic>?;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إلغاء الموعد'),
        content: const Text('هل تريد إلغاء هذا الموعد؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لا')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('نعم، إلغاء')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _cancelling = true);
    try {
      await ApiClient.instance.put('/patient/appointments/${widget.id}/cancel');
      if (!mounted) return;
      await _load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إلغاء الموعد')));
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String? ?? 'تعذّر الإلغاء';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  void _showRating() {
    double _rating = 5;
    final _commentCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24,
            MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('قيّم الجلسة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            RatingBar.builder(
              initialRating: _rating,
              itemCount: 5,
              itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: AppColors.warning),
              onRatingUpdate: (r) => setSt(() => _rating = r),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentCtrl,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'اكتب تعليقك (اختياري)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await ApiClient.instance.post(
                    '/patient/appointments/${widget.id}/review',
                    data: {
                      'rating': _rating.toInt(),
                      if (_commentCtrl.text.trim().isNotEmpty)
                        'comment': _commentCtrl.text.trim(),
                    },
                  );
                  if (!mounted) return;
                  await _load();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إرسال تقييمك')));
                } catch (_) {}
              },
              child: const Text('إرسال التقييم'),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final a = _appointment;
    if (a == null) return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text('لم يتم العثور على الموعد')));

    final therapist = (a['therapist'] as Map<String, dynamic>?) ?? {};
    final avatar = _resolveUrl(therapist['avatar'] as String?);
    final status = a['status'] as String? ?? '';
    final type = a['type'] as String? ?? '';
    final scheduledAt = a['scheduled_at'] as String? ?? '';
    DateTime? dt;
    try { dt = DateTime.parse(scheduledAt); } catch (_) {}
    final isUpcoming = status == 'confirmed' || status == 'pending';
    final isCompleted = status == 'completed';
    final hasReview = a['review'] != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('تفاصيل الموعد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Therapist card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppGradients.card,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white24,
                backgroundImage: avatar.isNotEmpty ? CachedNetworkImageProvider(avatar) : null,
                child: avatar.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 32) : null,
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(therapist['full_name'] as String? ?? '',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 2),
                Text(therapist['title'] as String? ?? '',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
              ])),
              _StatusBadgeWhite(status: status),
            ]),
          ),
          const SizedBox(height: 16),
          // Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(children: [
              _DetailRow(icon: Icons.calendar_today_outlined, label: 'التاريخ',
                value: dt != null ? DateFormat('EEEE، d MMMM yyyy', 'ar').format(dt) : ''),
              const Divider(height: 20),
              _DetailRow(icon: Icons.access_time_rounded, label: 'الوقت',
                value: dt != null ? DateFormat('HH:mm').format(dt) : ''),
              const Divider(height: 20),
              _DetailRow(
                icon: type == 'online' ? Icons.videocam_outlined : Icons.location_on_outlined,
                label: 'نوع الجلسة',
                value: type == 'online' ? 'أونلاين' : 'حضوري'),
              if (a['clinic'] != null) ...[
                const Divider(height: 20),
                _DetailRow(icon: Icons.local_hospital_outlined, label: 'العيادة',
                  value: (a['clinic'] as Map?)?['name'] as String? ?? ''),
              ],
              if (a['patient_notes'] != null && (a['patient_notes'] as String).isNotEmpty) ...[
                const Divider(height: 20),
                _DetailRow(icon: Icons.notes_rounded, label: 'ملاحظاتك',
                  value: a['patient_notes'] as String),
              ],
            ]),
          ),
          const SizedBox(height: 20),
          // Actions
          if (isUpcoming) ...[
            // ── Join online session button ─────────────────────────
            if (type == 'online') ...[
              _JoinSessionBanner(
                appointmentId: widget.id,
                scheduledAt: dt,
              ),
              const SizedBox(height: 10),
            ],
            OutlinedButton.icon(
              onPressed: () => context.push('/messages/new', extra: {
                'partnerId': therapist['id'],
                'name': therapist['full_name'],
              }),
              icon: const Icon(Icons.chat_outlined),
              label: const Text('مراسلة الأخصائي'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _cancelling ? null : _cancel,
              icon: _cancelling
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.cancel_outlined),
              label: const Text('إلغاء الموعد'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
          if (isCompleted && !hasReview) ...[
            ElevatedButton.icon(
              onPressed: _showRating,
              icon: const Icon(Icons.star_outline_rounded),
              label: const Text('قيّم الجلسة'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppColors.warning,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => context.push('/messages/new', extra: {
                'partnerId': therapist['id'],
                'name': therapist['full_name'],
              }),
              icon: const Icon(Icons.chat_outlined),
              label: const Text('مراسلة الأخصائي'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
          if (isCompleted && hasReview) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: const Row(children: [
                Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
                SizedBox(width: 10),
                Text('تم تقييم الجلسة، شكراً لك!',
                  style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}

// ── Join Session Banner ──────────────────────────────────────────────────────
class _JoinSessionBanner extends StatelessWidget {
  final int appointmentId;
  final DateTime? scheduledAt;
  const _JoinSessionBanner({required this.appointmentId, required this.scheduledAt});

  String get _timeStatus {
    if (scheduledAt == null) return '';
    final diff = scheduledAt!.difference(DateTime.now());
    if (diff.isNegative) return 'الجلسة جارية الآن';
    if (diff.inMinutes < 60) return 'تبدأ خلال ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24)   return 'تبدأ خلال ${diff.inHours} ساعة';
    return DateFormat('d MMM – HH:mm', 'ar').format(scheduledAt!);
  }

  bool get _isActive {
    if (scheduledAt == null) return false;
    final diff = scheduledAt!.difference(DateTime.now());
    // Allow joining 15 min before and up to 2 hours after
    return diff.inMinutes <= 15 && diff.inHours >= -2;
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => WebRtcCallPage(
        appointmentId:   appointmentId,
        peerName:        'أخصائي',
        isVideo:         true,
        isCaller:        false,
        incomingChannel: 'webrtc-session-$appointmentId',
      ),
    )),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isActive
            ? [const Color(0xFF1565C0), const Color(0xFF1976D2)]
            : [const Color(0xFF37474F), const Color(0xFF546E7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: (_isActive ? const Color(0xFF1976D2) : Colors.black).withOpacity(0.25),
            blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('انضم للجلسة الآن',
            style: TextStyle(
              color: Colors.white, fontSize: 16,
              fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
          const SizedBox(height: 3),
          Text(_timeStatus,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8), fontSize: 12,
              fontFamily: 'Cairo')),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('دخول',
            style: TextStyle(
              color: _isActive ? const Color(0xFF1565C0) : const Color(0xFF37474F),
              fontWeight: FontWeight.w800, fontSize: 14, fontFamily: 'Cairo')),
        ),
      ]),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 18, color: AppColors.primary),
    const SizedBox(width: 10),
    Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
    const SizedBox(width: 10),
    Expanded(child: Text(value,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      textAlign: TextAlign.end)),
  ]);
}

class _StatusBadgeWhite extends StatelessWidget {
  final String status;
  const _StatusBadgeWhite({required this.status});

  String get _label {
    switch (status) {
      case 'confirmed': return 'مؤكد';
      case 'pending': return 'قيد الانتظار';
      case 'completed': return 'مكتمل';
      case 'cancelled': return 'ملغى';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white24, borderRadius: BorderRadius.circular(20)),
    child: Text(_label,
      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
  );
}
