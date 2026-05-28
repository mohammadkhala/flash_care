import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

String _resolveUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  return url.replaceAll('localhost', '192.168.1.3')
            .replaceAll('127.0.0.1', '192.168.1.3');
}

class BookingPage extends StatefulWidget {
  final int therapistId;
  const BookingPage({required this.therapistId, super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int _step = 0;
  String? _type; // online / in_person
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String? _selectedTime;
  int? _selectedClinicId;
  List<Map<String, dynamic>> _slots = [];
  bool _loadingSlots = false;
  bool _booking = false;
  final _notesCtrl = TextEditingController();
  Map<String, dynamic>? _therapist;

  // Family booking
  bool _isForOther = false;
  final _otherNameCtrl = TextEditingController();
  final _otherAgeCtrl = TextEditingController();
  String? _otherRelation;
  static const _relations = ['ابن/ابنة', 'زوج/زوجة', 'والد/والدة', 'أخ/أخت', 'قريب آخر'];

  @override
  void initState() {
    super.initState();
    _loadTherapist();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _otherNameCtrl.dispose();
    _otherAgeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTherapist() async {
    try {
      final res = await ApiClient.instance.get('/therapists/${widget.therapistId}');
      if (!mounted) return;
      setState(() => _therapist = res.data['therapist'] as Map<String, dynamic>?);
    } catch (_) {}
  }

  Future<void> _loadSlots() async {
    if (_type == null) return;
    setState(() { _loadingSlots = true; _slots = []; _selectedTime = null; });
    try {
      final res = await ApiClient.instance.get(
        '/therapists/${widget.therapistId}/slots',
        queryParameters: {
          'date': DateFormat('yyyy-MM-dd').format(_selectedDay),
          'type': _type,
        },
      );
      if (!mounted) return;
      final list = (res.data['slots'] as List?) ?? [];
      setState(() => _slots = list.cast<Map<String, dynamic>>());
    } catch (_) {
      if (mounted) setState(() => _slots = []);
    } finally {
      if (mounted) setState(() => _loadingSlots = false);
    }
  }

  Future<void> _confirm() async {
    if (_type == null || _selectedTime == null) return;
    setState(() => _booking = true);
    try {
      await ApiClient.instance.post(
        '/patient/therapists/${widget.therapistId}/book',
        data: {
          'date': DateFormat('yyyy-MM-dd').format(_selectedDay),
          'time': _selectedTime,
          'type': _type,
          if (_selectedClinicId != null) 'clinic_id': _selectedClinicId,
          if (_notesCtrl.text.trim().isNotEmpty) 'patient_notes': _notesCtrl.text.trim(),
          if (_isForOther) ...{
            'is_for_other': true,
            'other_name': _otherNameCtrl.text.trim(),
            if (_otherAgeCtrl.text.trim().isNotEmpty)
              'other_age': int.tryParse(_otherAgeCtrl.text.trim()),
            if (_otherRelation != null) 'other_relation': _otherRelation,
          },
        },
      );
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('تم الحجز بنجاح'),
          content: const Text('تم تأكيد موعدك. سيتواصل معك الأخصائي قريباً.'),
          actions: [TextButton(
            onPressed: () { Navigator.pop(context); context.go('/appointments'); },
            child: const Text('حسناً'),
          )],
        ),
      );
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String? ?? 'تعذّر الحجز';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _therapist;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('حجز موعد'),
        leading: _step > 0
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => setState(() => _step--))
          : null,
      ),
      body: Column(children: [
        _buildStepper(),
        if (t != null) _buildTherapistHeader(t),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _buildStep(),
        )),
        _buildNextButton(),
      ]),
    );
  }

  Widget _buildStepper() {
    final steps = ['النوع', 'التاريخ', 'الوقت', 'التأكيد'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: List.generate(steps.length, (i) {
        final done = i < _step;
        final active = i == _step;
        return Expanded(child: Row(children: [
          Expanded(child: Column(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done || active ? AppColors.primary : AppColors.borderLight,
              ),
              child: Center(child: done
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : Text('${i + 1}', style: TextStyle(
                    color: active ? Colors.white : AppColors.textHint,
                    fontSize: 12, fontWeight: FontWeight.w700))),
            ),
            const SizedBox(height: 4),
            Text(steps[i], style: TextStyle(
              fontSize: 10,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              color: active ? AppColors.primary : AppColors.textHint)),
          ])),
          if (i < steps.length - 1) Expanded(
            child: Container(height: 2, color: i < _step ? AppColors.primary : AppColors.borderLight)),
        ]));
      })),
    );
  }

  Widget _buildTherapistHeader(Map<String, dynamic> t) {
    final avatar = _resolveUrl(t['avatar'] as String?);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: AppColors.surface,
      child: Row(children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: avatar.isNotEmpty ? CachedNetworkImageProvider(avatar) : null,
          backgroundColor: AppColors.surfaceAlt,
          child: avatar.isEmpty ? const Icon(Icons.person, size: 20) : null,
        ),
        const SizedBox(width: 10),
        Text(t['full_name'] as String? ?? '',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      ]),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _buildTypeStep();
      case 1: return _buildCalendarStep();
      case 2: return _buildTimeSlotsStep();
      case 3: return _buildConfirmStep();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildTypeStep() {
    final t = _therapist;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('اختر نوع الجلسة',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 24),
      if (t == null || t['accepts_online'] == true) _TypeCard(
        title: 'جلسة أونلاين',
        subtitle: 'عبر مكالمة فيديو',
        icon: Icons.videocam_outlined,
        price: t?['online_session_price'],
        value: 'online',
        selected: _type == 'online',
        onTap: () => setState(() => _type = 'online'),
      ),
      const SizedBox(height: 12),
      if (t == null || t['accepts_in_person'] == true) _TypeCard(
        title: 'جلسة حضورية',
        subtitle: 'في عيادة الأخصائي',
        icon: Icons.location_on_outlined,
        price: t?['in_person_session_price'],
        value: 'in_person',
        selected: _type == 'in_person',
        onTap: () => setState(() => _type = 'in_person'),
        color: AppColors.accent,
      ),
    ]);
  }

  Widget _buildCalendarStep() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('اختر التاريخ',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
    const SizedBox(height: 16),
    Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 90)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
        onDaySelected: (selected, focused) {
          setState(() { _selectedDay = selected; _focusedDay = focused; });
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.3), shape: BoxShape.circle),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary, shape: BoxShape.circle),
          outsideDaysVisible: false,
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false, titleCentered: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
      ),
    ),
  ]);

  Widget _buildTimeSlotsStep() {
    if (_loadingSlots) return const Center(child: Padding(
      padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('المواعيد المتاحة - ${DateFormat('d MMMM', 'ar').format(_selectedDay)}',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      const SizedBox(height: 16),
      if (_slots.isEmpty)
        Container(
          padding: const EdgeInsets.all(24),
          alignment: Alignment.center,
          child: const Text('لا توجد مواعيد متاحة في هذا اليوم',
            style: TextStyle(color: AppColors.textSecondary)),
        )
      else GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, childAspectRatio: 2.5, mainAxisSpacing: 8, crossAxisSpacing: 8),
        itemCount: _slots.length,
        itemBuilder: (_, i) {
          final slot = _slots[i];
          final time = slot['time'] as String;
          final selected = _selectedTime == time;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedTime = time;
              _selectedClinicId = slot['clinic_id'] as int?;
            }),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border)),
              child: Text(time, style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14,
                color: selected ? Colors.white : AppColors.textPrimary)),
            ),
          );
        },
      ),
    ]);
  }

  Widget _buildConfirmStep() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('تأكيد الحجز',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
    const SizedBox(height: 16),
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        _DetailRow(icon: Icons.category_outlined,
          label: 'نوع الجلسة', value: _type == 'online' ? 'أونلاين' : 'حضوري'),
        const Divider(height: 20),
        _DetailRow(icon: Icons.calendar_today_outlined,
          label: 'التاريخ', value: DateFormat('EEEE، d MMMM yyyy', 'ar').format(_selectedDay)),
        const Divider(height: 20),
        _DetailRow(icon: Icons.access_time_rounded,
          label: 'الوقت', value: _selectedTime ?? ''),
      ]),
    ),
    const SizedBox(height: 20),

    // ── Family member toggle ──────────────────────────────────────────
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.group_outlined, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          const Expanded(child: Text('الحجز لشخص آخر',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
          Switch.adaptive(
            value: _isForOther,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _isForOther = v),
          ),
        ]),
        if (_isForOther) ...[
          const Divider(height: 24),
          TextField(
            controller: _otherNameCtrl,
            decoration: const InputDecoration(
              labelText: 'اسم الشخص *',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _otherAgeCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'العمر',
              prefixIcon: Icon(Icons.cake_outlined),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _otherRelation,
            decoration: const InputDecoration(
              labelText: 'صلة القرابة',
              prefixIcon: Icon(Icons.family_restroom_outlined),
            ),
            items: _relations.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setState(() => _otherRelation = v),
          ),
        ],
      ]),
    ),
    const SizedBox(height: 20),

    // ── Notes ─────────────────────────────────────────────────────────
    const Text('ملاحظاتك للأخصائي (اختياري)',
      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
    const SizedBox(height: 8),
    TextField(
      controller: _notesCtrl,
      maxLines: 4,
      decoration: const InputDecoration(
        hintText: 'أضف أي ملاحظات أو معلومات تريد مشاركتها...',
      ),
    ),
  ]);

  Widget _buildNextButton() => Container(
    padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
    color: AppColors.surface,
    child: ElevatedButton(
      onPressed: _canProceed() ? (_step == 3 ? _confirm : _nextStep) : null,
      child: _booking
        ? const SizedBox(height: 22, width: 22,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
        : Text(_step == 3 ? 'تأكيد الحجز' : 'التالي'),
    ),
  );

  bool _canProceed() {
    switch (_step) {
      case 0: return _type != null;
      case 1: return true;
      case 2: return _selectedTime != null;
      case 3: return !_isForOther || _otherNameCtrl.text.trim().isNotEmpty;
      default: return false;
    }
  }

  void _nextStep() {
    if (_step == 1) _loadSlots();
    setState(() => _step++);
  }
}

class _TypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final dynamic price;
  final String value;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _TypeCard({
    required this.title, required this.subtitle, required this.icon,
    required this.price, required this.value, required this.selected,
    required this.onTap, this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected ? color.withOpacity(0.08) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? color : AppColors.border,
          width: selected ? 2 : 1),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          if (price != null) Text('$price ₪ / جلسة',
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
        ])),
        if (selected) Icon(Icons.check_circle_rounded, color: color),
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
    const Spacer(),
    Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
  ]);
}
