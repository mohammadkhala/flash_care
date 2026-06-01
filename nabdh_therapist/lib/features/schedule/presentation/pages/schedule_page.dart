import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

/// Therapist weekly schedule management page.
/// Allows setting per-day working hours and session type (in_person / online).
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool _loading = true;
  bool _saving  = false;

  static const _dayNames = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];

  // Per-day data: enabled, type(in_person/online/both), start, end, slotDuration
  final List<_DaySlot> _days = List.generate(
    7,
    (i) => _DaySlot(
      dayOfWeek: i,
      enabled: i >= 0 && i <= 4, // Sun-Thu enabled by default
      inPersonEnabled: true,
      onlineEnabled: false,
      start: const TimeOfDay(hour: 9, minute: 0),
      end: const TimeOfDay(hour: 13, minute: 0),
      slotDuration: 60,
    ),
  );

  // Unavailability
  List<Map<String, dynamic>> _unavailabilities = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiClient.instance.get('/therapist/schedules');
      final schedules = (r.data['schedules'] as List? ?? []).cast<Map<String, dynamic>>();
      _unavailabilities = (r.data['unavailabilities'] as List? ?? []).cast<Map<String, dynamic>>();

      // Reset all days first
      for (final d in _days) {
        d.enabled = false;
        d.inPersonEnabled = false;
        d.onlineEnabled = false;
      }

      // Apply saved schedules
      for (final s in schedules) {
        final dow = (s['day_of_week'] as num).toInt();
        if (dow < 0 || dow > 6) continue;
        final d = _days[dow];
        d.enabled = true;
        if (s['type'] == 'in_person') d.inPersonEnabled = true;
        if (s['type'] == 'online')    d.onlineEnabled   = true;

        // Use first slot's times
        if (!d.timesSet) {
          final parts = (s['start_time'] as String? ?? '09:00').split(':');
          final endParts = (s['end_time'] as String? ?? '13:00').split(':');
          d.start = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          d.end   = TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1]));
          d.slotDuration = (s['slot_duration'] as num?)?.toInt() ?? 60;
          d.timesSet = true;
        }
      }
    } catch (e) {
      _showSnack('تعذّر تحميل الجدول: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final slots = <Map<String, dynamic>>[];

      for (final d in _days) {
        if (!d.enabled) continue;
        if (d.inPersonEnabled) {
          slots.add({
            'day_of_week':   d.dayOfWeek,
            'type':          'in_person',
            'start_time':    _fmt(d.start),
            'end_time':      _fmt(d.end),
            'slot_duration': d.slotDuration,
            'is_active':     true,
          });
        }
        if (d.onlineEnabled) {
          slots.add({
            'day_of_week':   d.dayOfWeek,
            'type':          'online',
            'start_time':    _fmt(d.start),
            'end_time':      _fmt(d.end),
            'slot_duration': d.slotDuration,
            'is_active':     true,
          });
        }
      }

      await ApiClient.instance.put('/therapist/schedules', data: {'slots': slots});
      _showSnack('تم حفظ جدول الدوام بنجاح ✅');
    } catch (e) {
      _showSnack('تعذّر الحفظ: $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addUnavailability() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ar'),
      helpText: 'اختر يوم الإجازة',
    );
    if (picked == null || !mounted) return;

    final reasonCtrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('سبب الإجازة (اختياري)'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(hintText: 'مثال: إجازة سنوية'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, ''), child: const Text('تخطي')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, reasonCtrl.text),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    if (reason == null || !mounted) return;

    try {
      await ApiClient.instance.post('/therapist/unavailability', data: {
        'date': '${picked.year}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}',
        'reason': reason.isNotEmpty ? reason : null,
      });
      _showSnack('تمت إضافة يوم الإجازة');
      _load();
    } catch (_) {
      _showSnack('تعذّر إضافة الإجازة', isError: true);
    }
  }

  Future<void> _removeUnavailability(int id) async {
    try {
      await ApiClient.instance.delete('/therapist/unavailability/$id');
      _showSnack('تم حذف الإجازة');
      _load();
    } catch (_) {
      _showSnack('تعذّر الحذف', isError: true);
    }
  }

  Future<void> _pickTime(int dayIdx, bool isStart) async {
    final d = _days[dayIdx];
    final initial = isStart ? d.start : d.end;
    final t = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: isStart ? 'وقت البداية' : 'وقت النهاية',
    );
    if (t == null) return;
    setState(() {
      if (isStart) d.start = t;
      else         d.end   = t;
    });
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : AppColors.primary,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إدارة جدول الدوام',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surface,
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Center(child: SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))),
            )
          else
            TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded),
              label: const Text('حفظ'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // ── Weekly schedule ──────────────────────────────
                  _sectionHeader(Icons.calendar_today_rounded, 'ساعات العمل الأسبوعية'),
                  const SizedBox(height: 12),

                  ...List.generate(_days.length, (i) => _DayCard(
                    day: _days[i],
                    name: _dayNames[i],
                    onToggle: (v) => setState(() => _days[i].enabled = v),
                    onInPersonToggle: (v) => setState(() => _days[i].inPersonEnabled = v),
                    onOnlineToggle: (v) => setState(() => _days[i].onlineEnabled = v),
                    onStartTap: () => _pickTime(i, true),
                    onEndTap: () => _pickTime(i, false),
                    onDurationChange: (d) => setState(() => _days[i].slotDuration = d),
                  )),

                  const SizedBox(height: 24),

                  // ── Unavailability ───────────────────────────────
                  Row(children: [
                    Expanded(child: _sectionHeader(Icons.event_busy_rounded, 'أيام الإجازة')),
                    TextButton.icon(
                      onPressed: _addUnavailability,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('إضافة'),
                    ),
                  ]),
                  const SizedBox(height: 8),

                  if (_unavailabilities.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Text('لا توجد إجازات مجدولة',
                            style: TextStyle(color: AppColors.textHint)),
                      ),
                    )
                  else
                    ..._unavailabilities.map((u) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.event_busy_rounded, color: AppColors.error),
                        title: Text(u['date'] as String? ?? ''),
                        subtitle: (u['reason'] as String?)?.isNotEmpty == true
                            ? Text(u['reason'] as String) : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                          onPressed: () => _removeUnavailability((u['id'] as num).toInt()),
                        ),
                      ),
                    )),

                  const SizedBox(height: 40),
                ]),
              ),
            ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) => Row(children: [
    Icon(icon, color: AppColors.primary, size: 20),
    const SizedBox(width: 8),
    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
  ]);
}

// ─── Day slot data model ─────────────────────────────────────────────────────
class _DaySlot {
  final int dayOfWeek;
  bool enabled;
  bool inPersonEnabled;
  bool onlineEnabled;
  TimeOfDay start;
  TimeOfDay end;
  int slotDuration;
  bool timesSet = false;

  _DaySlot({
    required this.dayOfWeek,
    required this.enabled,
    required this.inPersonEnabled,
    required this.onlineEnabled,
    required this.start,
    required this.end,
    required this.slotDuration,
  });
}

// ─── Day card widget ─────────────────────────────────────────────────────────
class _DayCard extends StatelessWidget {
  final _DaySlot day;
  final String name;
  final ValueChanged<bool> onToggle;
  final ValueChanged<bool> onInPersonToggle;
  final ValueChanged<bool> onOnlineToggle;
  final VoidCallback onStartTap;
  final VoidCallback onEndTap;
  final ValueChanged<int> onDurationChange;

  const _DayCard({
    required this.day,
    required this.name,
    required this.onToggle,
    required this.onInPersonToggle,
    required this.onOnlineToggle,
    required this.onStartTap,
    required this.onEndTap,
    required this.onDurationChange,
  });

  String _fmtTime(TimeOfDay t) =>
      '${t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod}:${t.minute.toString().padLeft(2, '0')} ${t.period == DayPeriod.am ? 'ص' : 'م'}';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: day.enabled ? AppColors.primary.withOpacity(0.3) : AppColors.border,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header row: day name + toggle
        InkWell(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          onTap: () => onToggle(!day.enabled),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: day.enabled
                      ? AppColors.primary.withOpacity(0.15)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Icon(Icons.calendar_today_rounded,
                    color: day.enabled ? AppColors.primary : AppColors.textHint,
                    size: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15,
                    color: day.enabled ? AppColors.textPrimary : AppColors.textHint,
                  ))),
              Switch(
                value: day.enabled,
                onChanged: onToggle,
                activeColor: AppColors.primary,
              ),
            ]),
          ),
        ),

        if (day.enabled) ...[
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Session type toggles
              const Text('نوع الجلسات:',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Row(children: [
                _TypeChip(
                  label: 'حضوري',
                  icon: Icons.location_on_rounded,
                  selected: day.inPersonEnabled,
                  color: AppColors.primary,
                  onTap: () => onInPersonToggle(!day.inPersonEnabled),
                ),
                const SizedBox(width: 8),
                _TypeChip(
                  label: 'أونلاين',
                  icon: Icons.videocam_rounded,
                  selected: day.onlineEnabled,
                  color: AppColors.accent,
                  onTap: () => onOnlineToggle(!day.onlineEnabled),
                ),
              ]),
              const SizedBox(height: 16),

              // Time range
              Row(children: [
                Expanded(child: _TimeButton(
                  label: 'من',
                  value: _fmtTime(day.start),
                  onTap: onStartTap,
                )),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('—', style: TextStyle(color: AppColors.textHint)),
                ),
                Expanded(child: _TimeButton(
                  label: 'حتى',
                  value: _fmtTime(day.end),
                  onTap: onEndTap,
                )),
              ]),
              const SizedBox(height: 12),

              // Slot duration
              Row(children: [
                const Text('مدة الجلسة:',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(width: 12),
                Expanded(child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [30, 45, 60, 90, 120].map((d) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text('$d دق'),
                      selected: day.slotDuration == d,
                      onSelected: (_) => onDurationChange(d),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: day.slotDuration == d ? Colors.white : AppColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                  )).toList()),
                )),
              ]),
            ]),
          ),
        ],
      ]),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label, required this.icon,
    required this.selected, required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? color.withOpacity(0.15) : AppColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: selected ? color : AppColors.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: selected ? color : AppColors.textHint),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? color : AppColors.textHint,
            )),
      ]),
    ),
  );
}

class _TimeButton extends StatelessWidget {
  final String label, value;
  final VoidCallback onTap;

  const _TimeButton({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
      ]),
    ),
  );
}
