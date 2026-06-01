import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/jitsi_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/json_utils.dart';

class AppointmentDetailPage extends StatefulWidget {
  final int id;
  const AppointmentDetailPage({required this.id, super.key});
  @override
  State<AppointmentDetailPage> createState() => _State();
}

class _State extends State<AppointmentDetailPage> {
  Map? _apt;
  bool _loading = true, _saving = false;
  final _s = TextEditingController();
  final _o = TextEditingController();
  final _a = TextEditingController();
  final _p = TextEditingController();
  int _pain = 0;

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _s.dispose(); _o.dispose(); _a.dispose(); _p.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get('/therapist/appointments/${widget.id}');
      final apt = res.data as Map;
      final note = apt['session_note'] as Map?;
      if (note != null) {
        _s.text = note['subjective'] ?? '';
        _o.text = note['objective']  ?? '';
        _a.text = note['assessment'] ?? '';
        _p.text = note['plan']       ?? '';
        _pain   = jsonInt(note['pain_scale']);
      }
      setState(() { _apt = apt; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _action(String action, {Map? data}) async {
    try {
      await ApiClient.instance.put('/therapist/appointments/${widget.id}/$action', data: data);
      _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(action == 'confirm' ? 'تم التأكيد' : 'تم الإكمال')));
    } catch (_) {}
  }

  Future<void> _cancel() async {
    final ctrl = TextEditingController();
    final reason = await showDialog<String>(context: context, builder: (_) => AlertDialog(
      title: const Text('سبب الإلغاء'),
      content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'اختياري'), maxLines: 2),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('رجوع')),
        ElevatedButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text('إلغاء الموعد')),
      ],
    ));
    if (reason == null) return;
    await ApiClient.instance.put('/therapist/appointments/${widget.id}/cancel', data: {'reason': reason});
    _load();
  }

  Future<void> _saveNotes() async {
    setState(() => _saving = true);
    try {
      await ApiClient.instance.post('/therapist/appointments/${widget.id}/notes', data: {
        'subjective': _s.text, 'objective': _o.text,
        'assessment': _a.text, 'plan': _p.text, 'pain_scale': _pain,
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ الملاحظات ✓')));
    } finally { if (mounted) setState(() => _saving = false); }
  }

  Future<void> _startSession() async {
    final patientName = (_apt?['patient'] as Map?)?['full_name'] as String? ?? 'المريض';
    await JitsiService.startCall(
      room: 'nabdh-session-${widget.id}',
      displayName: 'د. $patientName',
      videoMuted: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_apt == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('لم يُعثر على الموعد')));

    final patient   = _apt!['patient'] as Map?;
    final status    = _apt!['status'] as String? ?? '';
    final scheduled = DateTime.tryParse(_apt!['scheduled_at'] ?? '');
    final type      = _apt!['type'] as String? ?? 'online';
    final name      = patient?['full_name'] as String? ?? 'مريض';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('تفاصيل الموعد'),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          if (status == 'confirmed' && type == 'online')
            IconButton(icon: const Icon(Icons.videocam, color: AppColors.primary), onPressed: _startSession),
        ],
      ),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Patient card
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          CircleAvatar(radius: 30, backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(name.substring(0, 1),
                style: const TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w700))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            if (scheduled != null) ...[
              const SizedBox(height: 4),
              Text(DateFormat('EEEE dd/MM/yyyy  hh:mm a').format(scheduled),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
            const SizedBox(height: 8),
            Row(children: [
              _badge(status),
              const SizedBox(width: 8),
              _chip(type == 'online' ? '🎥 أونلاين' : '🏥 حضوري'),
            ]),
          ])),
        ]))),
        const SizedBox(height: 12),

        // Goals button
        OutlinedButton.icon(
          onPressed: () {
            final patientId = (patient?['id'] as num?)?.toInt() ?? 0;
            context.push('/goals', extra: {
              'patientId':   patientId,
              'patientName': name,
            });
          },
          icon: const Icon(Icons.track_changes_rounded),
          label: const Text('الأهداف العلاجية'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 16),

        // Actions
        if (status == 'pending') Row(children: [
          Expanded(child: ElevatedButton.icon(
            onPressed: () => _action('confirm'),
            icon: const Icon(Icons.check), label: const Text('تأكيد'),
          )),
          const SizedBox(width: 10),
          Expanded(child: OutlinedButton.icon(
            onPressed: _cancel, icon: const Icon(Icons.close), label: const Text('إلغاء'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error), minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          )),
        ]),
        if (status == 'confirmed') ...[
          // ── Start online session ──────────────────────────────────
          if (type == 'online') ...[
            GestureDetector(
              onTap: _startSession,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                    color: const Color(0xFF1976D2).withOpacity(0.3),
                    blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('ابدأ الجلسة الآن', style: TextStyle(
                      color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                    Text('انضم للغرفة الخاصة بالمريض', style: TextStyle(
                      color: Colors.white70, fontSize: 12)),
                  ])),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
                ]),
              ),
            ),
            const SizedBox(height: 8),
          ],
          ElevatedButton.icon(
            onPressed: () => _action('complete', data: {
              'subjective': _s.text, 'objective': _o.text,
              'assessment': _a.text, 'plan': _p.text, 'pain_scale': _pain,
            }),
            icon: const Icon(Icons.done_all), label: const Text('إنهاء الجلسة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _cancel, icon: const Icon(Icons.cancel_outlined), label: const Text('إلغاء الموعد'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error), minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          ),
        ],
        const SizedBox(height: 20),

        // Notes
        const Text('ملاحظات الجلسة (SOAP)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),

        // Pain scale
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('مستوى الألم', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Slider(value: _pain.toDouble(), min: 0, max: 10, divisions: 10,
                label: '$_pain', onChanged: (v) => setState(() => _pain = v.toInt()))),
            CircleAvatar(radius: 20,
              backgroundColor: _pain <= 3 ? AppColors.success : _pain <= 6 ? AppColors.warning : AppColors.error,
              child: Text('$_pain', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
          ]),
        ]))),
        const SizedBox(height: 12),
        _noteField('الشكوى (Subjective)', _s),
        const SizedBox(height: 12),
        _noteField('الفحص (Objective)', _o),
        const SizedBox(height: 12),
        _noteField('التقييم (Assessment)', _a),
        const SizedBox(height: 12),
        _noteField('الخطة (Plan)', _p),
        const SizedBox(height: 16),

        ElevatedButton.icon(
          onPressed: _saving ? null : _saveNotes,
          icon: _saving ? const SizedBox(width: 18, height: 18,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.save_outlined),
          label: const Text('حفظ الملاحظات'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryLight),
        ),
        const SizedBox(height: 40),
      ])),
    );
  }

  Widget _noteField(String label, TextEditingController c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      TextField(controller: c, maxLines: 3, decoration: InputDecoration(hintText: label)),
    ],
  );

  Widget _badge(String s) {
    final (l, c) = switch (s) {
      'pending'   => ('بانتظار', AppColors.warning),
      'confirmed' => ('مؤكد', AppColors.primary),
      'completed' => ('مكتمل', AppColors.success),
      _           => ('ملغي', AppColors.error),
    };
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(l, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600)));
  }

  Widget _chip(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20)),
    child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)));
}
