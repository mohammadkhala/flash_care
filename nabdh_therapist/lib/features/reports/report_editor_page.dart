import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json_utils.dart';
import '../finance/finance_utils.dart';
import 'report_pdf.dart';

/// Create or edit an assessment report. The structure (sections, items, normal
/// ranges) comes from the admin-defined template; the doctor only enters values.
///
/// New report: pass [client] + [template]. Existing report: pass [reportId].
class ReportEditorPage extends StatefulWidget {
  final int? reportId;
  final Map? client;
  final Map? template;
  final int? appointmentId;
  const ReportEditorPage({this.reportId, this.client, this.template, this.appointmentId, super.key});

  @override
  State<ReportEditorPage> createState() => _ReportEditorPageState();
}

class _ReportEditorPageState extends State<ReportEditorPage> {
  static const _blue = Color(0xFF1565C0);

  int? _id;
  String _title = '';
  String _clientName = '';
  String _clientCode = '';
  String _status = 'draft';
  List<Map> _sections = [];
  List<Map> _clinics = [];
  int? _clinicId;
  DateTime _date = DateTime.now();
  final _notes = TextEditingController();

  // Report header
  String? _numberLabel;
  String _reportType = 'initial';
  String? _referralSource;
  final _referralName = TextEditingController();
  final _diagnosis = TextEditingController();
  final _sessionsPerWeek = TextEditingController();
  final _planWeeks = TextEditingController();
  List<String> _letterheadMissing = [];
  bool _warnedLetterhead = false;

  static const _reportTypes = {
    'initial': 'تقييم أولي',
    'reassessment': 'إعادة تقييم',
    'progress': 'تقرير تقدّم',
    'discharge': 'تقرير خروج',
  };
  static const _referrals = {
    'self': 'مراجعة ذاتية',
    'physician': 'محوَّل من طبيب',
    'other': 'أخرى',
  };

  /// Text inputs keyed `itemId:right|left|value|text` and `note:sectionId`.
  final Map<String, TextEditingController> _ctrl = {};
  /// Grade / positive-negative choices keyed `itemId:right|left`.
  final Map<String, Object?> _pick = {};

  bool _loading = true;
  bool _saving = false;
  bool _dirty = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _id = widget.reportId;
    _load();
  }

  @override
  void dispose() {
    for (final c in [..._ctrl.values, _notes, _referralName, _diagnosis, _sessionsPerWeek, _planWeeks]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final clinicsRes = await ApiClient.instance.get('/therapist/clinics');
      _clinics = (clinicsRes.data as List).cast<Map>();

      if (_id != null) {
        final res = await ApiClient.instance.get('/therapist/reports/$_id');
        final r = res.data as Map;
        _title = '${r['title']}';
        _clientName = '${r['client_name'] ?? ''}';
        _clientCode = '${r['client_code'] ?? ''}';
        _status = '${r['status']}';
        _clinicId = r['clinic_id'] as int?;
        _date = DateTime.tryParse('${r['assessed_at']}') ?? DateTime.now();
        _notes.text = r['notes'] as String? ?? '';
        _sections = (r['sections'] as List).cast<Map>();
        _applyHeader(r);
      } else {
        final t = widget.template!;
        _title = '${t['name_en']}';
        _clientName = '${widget.client?['name'] ?? ''}';
        _clientCode = '${widget.client?['code'] ?? ''}';
        _sections = (t['sections'] as List).cast<Map>();
        if (_clinics.length == 1) _clinicId = _clinics.first['id'] as int?;
      }
      _initInputs();
      setState(() => _loading = false);
    } catch (e) {
      setState(() { _loading = false; _error = apiError(e); });
    }
  }

  void _applyHeader(Map r) {
    _numberLabel = r['number_label'] as String?;
    _reportType = r['report_type'] as String? ?? 'initial';
    _referralSource = r['referral_source'] as String?;
    _referralName.text = r['referral_name'] as String? ?? '';
    _diagnosis.text = r['medical_diagnosis'] as String? ?? '';
    _sessionsPerWeek.text = r['sessions_per_week'] == null ? '' : '${r['sessions_per_week']}';
    _planWeeks.text = r['plan_weeks'] == null ? '' : '${r['plan_weeks']}';
    _letterheadMissing = ((r['letterhead_missing'] as List?) ?? []).cast<String>();
  }

  String _num(dynamic v) {
    if (v == null) return '';
    final d = jsonDouble(v);
    return d == d.roundToDouble() ? d.toInt().toString() : d.toString();
  }

  TextEditingController _c(String key, [String text = '']) =>
      _ctrl.putIfAbsent(key, () => TextEditingController(text: text)..addListener(_markDirty));

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  void _initInputs() {
    for (final s in _sections) {
      final type = s['type'];
      _c('note:${s['id']}', s['notes'] as String? ?? '');
      for (final i in (s['items'] as List).cast<Map>()) {
        final id = i['id'];
        switch (type) {
          case 'bilateral_number':
            _c('$id:right', _num(i['right']));
            _c('$id:left', _num(i['left']));
          case 'single_number':
            _c('$id:value', _num(i['value']));
          case 'text':
            _c('$id:text', i['text'] as String? ?? '');
          case 'bilateral_grade':
            _pick['$id:right'] = i['right'] == null ? null : jsonInt(i['right']);
            _pick['$id:left'] = i['left'] == null ? null : jsonInt(i['left']);
          case 'pos_neg':
            _pick['$id:right'] = i['right'];
            _pick['$id:left'] = i['left'];
        }
      }
    }
    _dirty = false;
  }

  double? _parse(String s) => double.tryParse(s.trim().replaceAll(',', '.'));

  bool _isAbnormal(Map item, double? v) {
    if (v == null) return false;
    final min = item['normal_min'] == null ? null : jsonDouble(item['normal_min']);
    final max = item['normal_max'] == null ? null : jsonDouble(item['normal_max']);
    return (min != null && v < min) || (max != null && v > max);
  }

  Map<String, dynamic> _payloadValues() {
    final values = <String, dynamic>{};
    for (final s in _sections) {
      final type = s['type'];
      for (final i in (s['items'] as List).cast<Map>()) {
        final id = i['id'];
        values['$id'] = switch (type) {
          'bilateral_number' => {
              'right': _parse(_ctrl['$id:right']!.text),
              'left': _parse(_ctrl['$id:left']!.text),
            },
          'single_number' => {'value': _parse(_ctrl['$id:value']!.text)},
          'text' => {'text': _ctrl['$id:text']!.text.trim()},
          _ => {'right': _pick['$id:right'], 'left': _pick['$id:left']},
        };
      }
    }
    return values;
  }

  Future<bool> _save({String? status}) async {
    setState(() => _saving = true);
    final body = {
      'clinic_id': _clinicId,
      'assessed_at': apiDate(_date),
      'values': _payloadValues(),
      'section_notes': {for (final s in _sections) '${s['id']}': _ctrl['note:${s['id']}']!.text.trim()},
      'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      'status': status ?? _status,
      'report_type': _reportType,
      'referral_source': _referralSource,
      'referral_name': _referralSource == null || _referralName.text.trim().isEmpty ? null : _referralName.text.trim(),
      'medical_diagnosis': _diagnosis.text.trim().isEmpty ? null : _diagnosis.text.trim(),
      'sessions_per_week': int.tryParse(_sessionsPerWeek.text.trim()),
      'plan_weeks': int.tryParse(_planWeeks.text.trim()),
    };
    try {
      final res = _id == null
          ? await ApiClient.instance.post('/therapist/reports', data: {
              ...body,
              'client_id': widget.client!['id'],
              'template_id': widget.template!['id'],
              if (widget.appointmentId != null) 'appointment_id': widget.appointmentId,
            })
          : await ApiClient.instance.put('/therapist/reports/$_id', data: body);
      final r = res.data as Map;
      setState(() {
        _id = r['id'] as int;
        _status = '${r['status']}';
        _numberLabel = r['number_label'] as String?;
        _letterheadMissing = ((r['letterhead_missing'] as List?) ?? []).cast<String>();
        _saving = false;
        _dirty = false;
      });
      return true;
    } catch (e) {
      setState(() => _saving = false);
      final data = (e is DioException) ? e.response?.data : null;
      final errors = data is Map ? data['errors'] : null;
      if (mounted && errors is Map && errors.containsKey('license_number')) {
        await _askToCompleteProfile('${(errors['license_number'] as List).first}');
        return false;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(apiError(e)),
          backgroundColor: AppColors.error,
        ));
      }
      return false;
    }
  }

  Future<void> _saveDraft() async {
    if (await _save() && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ ✓')));
    }
  }

  Future<void> _generate() async {
    if (_clinicId == null && _clinics.isNotEmpty) {
      final go = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('بدون عيادة؟'),
          content: const Text('لم تختر العيادة، فلن تظهر ترويسة العيادة وشعارها في التقرير.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('اختيار العيادة')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('متابعة')),
          ],
        ),
      );
      if (go != true) return;
    }
    if (await _save(status: 'final') && mounted) {
      if (_letterheadMissing.isNotEmpty && !_warnedLetterhead) {
        _warnedLetterhead = true;
        final go = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('بيانات الترويسة غير مكتملة'),
            content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('التقرير جاهز، لكن هذه البيانات لن تظهر في الترويسة:'),
              const SizedBox(height: 8),
              ..._letterheadMissing.map((m) => Text('• $m', style: const TextStyle(fontSize: 13))),
            ]),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إكمال البيانات')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('عرض التقرير')),
            ],
          ),
        );
        if (!mounted) return;
        if (go != true) {
          final toClinics = _letterheadMissing.every((m) => m.contains('عياداتي'));
          await context.push(toClinics ? '/clinics' : '/profile/edit');
          return;
        }
      }
      await openReportPdf(context, _id!, fileName: '$_clientCode ${_numberLabel ?? ''} $_title');
    }
  }

  Future<void> _askToCompleteProfile(String message) async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('رقم إجازة المزاولة مطلوب'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('لاحقاً')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('فتح الملف الشخصي')),
        ],
      ),
    );
    if (go == true && mounted) await context.push('/profile/edit');
  }

  Future<bool> _confirmLeave() async {
    if (!_dirty) return true;
    final r = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تغييرات غير محفوظة'),
        content: const Text('هل تريد حفظ القيم قبل الخروج؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, 'discard'),
              style: TextButton.styleFrom(foregroundColor: AppColors.error), child: const Text('خروج بدون حفظ')),
          TextButton(onPressed: () => Navigator.pop(ctx, 'save'), child: const Text('حفظ مسودة')),
        ],
      ),
    );
    if (r == 'save') return _save();
    return r == 'discard';
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          if (await _confirmLeave() && context.mounted) context.pop(true);
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(_id == null ? 'تقرير تقييم جديد' : 'تقرير التقييم'),
            actions: [
              if (_id != null)
                IconButton(
                  tooltip: 'عرض PDF',
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  onPressed: _saving
                      ? null
                      : () async {
                          if (_dirty && !await _save()) return;
                          if (context.mounted) openReportPdf(context, _id!, fileName: '$_clientCode $_title');
                        },
                ),
            ],
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                      children: [
                        _headerCard(),
                        const SizedBox(height: 12),
                        ..._sections.asMap().entries.map((e) => _sectionCard(e.key + 1, e.value)),
                        _notesCard(),
                      ],
                    ),
          bottomNavigationBar: _loading || _error != null
              ? null
              : SafeArea(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(children: [
                      Expanded(child: OutlinedButton(
                        onPressed: _saving ? null : _saveDraft,
                        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 50)),
                        child: const Text('حفظ مسودة'),
                      )),
                      const SizedBox(width: 10),
                      Expanded(flex: 2, child: ElevatedButton.icon(
                        onPressed: _saving ? null : _generate,
                        icon: _saving
                            ? const SizedBox(width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.description_outlined),
                        label: const Text('إنشاء التقرير'),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(0, 50), backgroundColor: _blue),
                      )),
                    ]),
                  ),
                ),
        ),
      );

  Widget _headerCard() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withAlpha(25),
              child: const Icon(Icons.person, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_clientName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              Text(_clientCode, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ])),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (d != null) setState(() { _date = d; _dirty = true; });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(showDate(apiDate(_date)), style: const TextStyle(fontSize: 12)),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: Text(_title, style: const TextStyle(fontWeight: FontWeight.w700, color: _blue))),
            if (_numberLabel != null)
              Text(_numberLabel!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 12),
          const Text('نوع التقرير', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: _reportTypes.entries.map((e) => ChoiceChip(
                label: Text(e.value, style: const TextStyle(fontSize: 12)),
                selected: _reportType == e.key,
                visualDensity: VisualDensity.compact,
                onSelected: (_) => setState(() { _reportType = e.key; _dirty = true; }),
              )).toList()),
          const SizedBox(height: 12),
          const Text('جهة الإحالة', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: _referrals.entries.map((e) => ChoiceChip(
                label: Text(e.value, style: const TextStyle(fontSize: 12)),
                selected: _referralSource == e.key,
                visualDensity: VisualDensity.compact,
                onSelected: (_) => setState(() {
                  _referralSource = _referralSource == e.key ? null : e.key;
                  _dirty = true;
                }),
              )).toList()),
          if (_referralSource == 'physician' || _referralSource == 'other') ...[
            const SizedBox(height: 8),
            _headerField(_referralName, _referralSource == 'physician'
                ? 'اسم الطبيب المحيل وتخصصه' : 'جهة الإحالة',
                hint: _referralSource == 'physician' ? 'Dr. Samer Odeh (Orthopedics)' : null),
          ],
          const SizedBox(height: 12),
          _headerField(_diagnosis, 'التشخيص الطبي (اختياري)', hint: 'Right shoulder impingement syndrome'),
          const SizedBox(height: 12),
          const Text('خطة العلاج', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: _headerField(_sessionsPerWeek, 'جلسات أسبوعياً', number: true)),
            const SizedBox(width: 10),
            Expanded(child: _headerField(_planWeeks, 'لمدة (أسابيع)', number: true)),
          ]),
          const SizedBox(height: 12),
          const Text('المؤسسة / العيادة', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          if (_clinics.isEmpty)
            OutlinedButton.icon(
              onPressed: () async {
                await context.push('/clinics');
                final res = await ApiClient.instance.get('/therapist/clinics');
                setState(() => _clinics = (res.data as List).cast<Map>());
              },
              icon: const Icon(Icons.add_business_outlined),
              label: const Text('أضف عيادتك (لترويسة التقرير)'),
            )
          else
            DropdownButtonFormField<int?>(
              initialValue: _clinicId,
              isExpanded: true,
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('بدون عيادة')),
                ..._clinics.map((c) => DropdownMenuItem<int?>(value: c['id'] as int, child: Text('${c['name']}'))),
              ],
              onChanged: (v) => setState(() { _clinicId = v; _dirty = true; }),
            ),
          if (_status == 'final')
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Row(children: [
                Icon(Icons.verified_outlined, size: 16, color: AppColors.success),
                SizedBox(width: 6),
                Text('تقرير نهائي — يمكنك التعديل وإعادة الإنشاء',
                    style: TextStyle(fontSize: 12, color: AppColors.success)),
              ]),
            ),
        ]),
      );

  Widget _headerField(TextEditingController c, String label, {String? hint, bool number = false}) => TextField(
        controller: c,
        keyboardType: number ? TextInputType.number : null,
        inputFormatters: number ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)] : null,
        onChanged: (_) => _markDirty(),
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintTextDirection: TextDirection.ltr,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  Widget _sectionCard(int n, Map s) {
    final type = s['type'] as String;
    final items = (s['items'] as List).cast<Map>();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          color: _blue,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$n. ${s['name_en']}', textDirection: TextDirection.ltr,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
            Text('${s['name_ar']}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ]),
        ),
        if (type == 'text')
          ...items.map((i) => Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: TextField(
                  controller: _ctrl['${i['id']}:text'],
                  minLines: 1,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: '${i['name_en']}${(i['name_ar'] ?? '').toString().isNotEmpty ? ' — ${i['name_ar']}' : ''}',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ))
        else ...[
          _tableHeader(type, s),
          ...items.map((i) => _row(type, s, i)),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: TextField(
            controller: _ctrl['note:${s['id']}'],
            minLines: 1,
            maxLines: 3,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'ملاحظات على هذا القسم (اختياري)',
              isDense: true,
              prefixIcon: const Icon(Icons.notes, size: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _tableHeader(String type, Map s) {
    const st = TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
    final single = type == 'single_number';
    String normal = 'Normal';
    if (type == 'bilateral_grade') normal = 'Normal (${_num(s['scale_min'] ?? 0)}–${_num(s['scale_max'] ?? 5)})';
    return Container(
      color: const Color(0xFFE3ECF8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(children: [
          Expanded(child: Text(type == 'pos_neg' ? 'Test' : 'Item', style: st)),
          if (single)
            const SizedBox(width: 78, child: Text('Value', style: st, textAlign: TextAlign.center))
          else ...[
            const SizedBox(width: 72, child: Text('Right', style: st, textAlign: TextAlign.center)),
            const SizedBox(width: 6),
            const SizedBox(width: 72, child: Text('Left', style: st, textAlign: TextAlign.center)),
          ],
          if (type != 'pos_neg' && type != 'text')
            SizedBox(width: 64, child: Text(normal, style: st, textAlign: TextAlign.center)),
        ]),
      ),
    );
  }

  String _range(String type, Map s, Map i) {
    if (i['normal_min'] == null && i['normal_max'] == null) return '—';
    final unit = s['unit'] == '°' ? '°' : '';
    if (type == 'bilateral_grade') return '${_num(i['normal_max'])}${s['unit'] ?? ''}';
    return '${_num(i['normal_min'])}–${_num(i['normal_max'])}$unit';
  }

  Widget _row(String type, Map s, Map i) {
    final id = i['id'];
    final nameAr = (i['name_ar'] ?? '').toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderLight))),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${i['name_en']}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            if (nameAr.isNotEmpty)
              Text(nameAr, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
          ])),
          ...switch (type) {
            'bilateral_number' => [
                _numField('$id:right', i, 72),
                const SizedBox(width: 6),
                _numField('$id:left', i, 72),
              ],
            'single_number' => [_numField('$id:value', i, 78)],
            'bilateral_grade' => [
                _gradeField('$id:right', s, i),
                const SizedBox(width: 6),
                _gradeField('$id:left', s, i),
              ],
            _ => [_posNeg('$id:right'), const SizedBox(width: 6), _posNeg('$id:left')],
          },
          if (type != 'pos_neg')
            SizedBox(width: 64, child: Text(_range(type, s, i), textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
        ]),
      ),
    );
  }

  Widget _numField(String key, Map item, double width) {
    final c = _ctrl[key]!;
    final bad = _isAbnormal(item, _parse(c.text));
    return SizedBox(
      width: width,
      child: TextField(
        controller: c,
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[-0-9.,]'))],
        onChanged: (_) => setState(() {}),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: bad ? AppColors.error : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: '—',
          contentPadding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          filled: bad,
          fillColor: AppColors.error.withAlpha(18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: bad ? AppColors.error : AppColors.border),
          ),
        ),
      ),
    );
  }

  Widget _gradeField(String key, Map s, Map item) {
    final min = jsonInt(s['scale_min'], 0);
    final max = jsonInt(s['scale_max'], 5);
    final v = _pick[key] as int?;
    final bad = _isAbnormal(item, v?.toDouble());
    return Container(
      width: 72,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: bad ? AppColors.error.withAlpha(18) : null,
        border: Border.all(color: bad ? AppColors.error : AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: v,
          isExpanded: true,
          hint: const Center(child: Text('—')),
          alignment: Alignment.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: bad ? AppColors.error : AppColors.textPrimary,
          ),
          items: [
            const DropdownMenuItem<int?>(value: null, alignment: Alignment.center, child: Text('—')),
            for (var g = min; g <= max; g++)
              DropdownMenuItem<int?>(value: g, alignment: Alignment.center, child: Text('$g')),
          ],
          onChanged: (g) => setState(() { _pick[key] = g; _dirty = true; }),
        ),
      ),
    );
  }

  Widget _posNeg(String key) {
    final v = _pick[key] as String?;
    Widget btn(String value, String label, Color color) => Expanded(
          child: GestureDetector(
            onTap: () => setState(() { _pick[key] = v == value ? null : value; _dirty = true; }),
            child: Container(
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: v == value ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(label, style: TextStyle(
                fontWeight: FontWeight.w800,
                color: v == value ? Colors.white : AppColors.textSecondary,
              )),
            ),
          ),
        );
    return Container(
      width: 72,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(children: [
        btn('pos', '+', AppColors.error),
        btn('neg', '−', AppColors.success),
      ]),
    );
  }

  Widget _notesCard() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: _notes,
          minLines: 2,
          maxLines: 6,
          onChanged: (_) => _markDirty(),
          decoration: InputDecoration(
            labelText: 'ملاحظات إضافية للتقرير (اختياري)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      );
}
