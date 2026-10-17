import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json_utils.dart';
import 'finance_utils.dart';

// ── Shared sheet scaffold ────────────────────────────────────────────────────

Future<T?> _sheet<T>(BuildContext context, Widget child) => showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => child,
    );

class _SheetBody extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool saving;
  final VoidCallback onSave;
  final VoidCallback? onDelete;

  const _SheetBody({
    required this.title,
    required this.children,
    required this.onSave,
    this.saving = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: Text(title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: saving ? null : onDelete,
                ),
            ]),
            const SizedBox(height: 12),
            ...children,
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saving ? null : onSave,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: saving
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('حفظ'),
            ),
          ]),
        ),
      );
}

InputDecoration _dec(String label, {String? hint, Widget? suffix}) => InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      isDense: true,
    );

Widget _gap() => const SizedBox(height: 12);

void _snack(BuildContext context, String msg, {bool error = false}) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.error : null,
    ));

Future<bool> _confirmDelete(BuildContext context, String what) async =>
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('حذف $what؟'),
        content: const Text('لا يمكن التراجع عن هذه العملية.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('رجوع')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    ) ??
    false;

class _DateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  const _DateField({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: value,
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (d != null) onChanged(d);
        },
        child: InputDecorator(
          decoration: _dec(label, suffix: const Icon(Icons.calendar_today_outlined, size: 18)),
          child: Text(showDate(apiDate(value))),
        ),
      );
}

Widget _choiceChips(Map<String, String> options, String value, ValueChanged<String> onChanged) =>
    Wrap(spacing: 8, runSpacing: 8, children: options.entries.map((e) => ChoiceChip(
          label: Text(e.value),
          selected: value == e.key,
          onSelected: (_) => onChanged(e.key),
        )).toList());

double? _num(String s) => double.tryParse(s.trim().replaceAll(',', '.'));

String _fmtNum(dynamic v) {
  final d = jsonDouble(v);
  return d == d.roundToDouble() ? d.toInt().toString() : d.toString();
}

// ── Client picker ────────────────────────────────────────────────────────────

/// Returns `{id, name, code}` of an existing or newly created account.
Future<Map?> pickClient(BuildContext context) => _sheet<Map>(context, const _ClientPicker());

class _ClientPicker extends StatefulWidget {
  const _ClientPicker();
  @override
  State<_ClientPicker> createState() => _ClientPickerState();
}

class _ClientPickerState extends State<_ClientPicker> {
  List<Map> _clients = [];
  List<Map> _patients = [];
  bool _loading = true;
  String _q = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await Future.wait([
        ApiClient.instance.get('/therapist/finance/clients'),
        ApiClient.instance.get('/therapist/finance/my-patients'),
      ]);
      setState(() {
        _clients = (r[0].data as List).cast<Map>();
        _patients = (r[1].data as List).cast<Map>().where((p) => p['client_id'] == null).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _fromPatient(Map p) async {
    setState(() => _busy = true);
    try {
      final res = await ApiClient.instance.post('/therapist/finance/clients', data: {'patient_id': p['id']});
      if (mounted) Navigator.pop(context, res.data as Map);
    } catch (e) {
      if (mounted) _snack(context, apiError(e), error: true);
      setState(() => _busy = false);
    }
  }

  Future<void> _newWalkIn() async {
    final created = await showClientForm(context);
    if (created != null && mounted) Navigator.pop(context, created);
  }

  bool _match(String s) => _q.isEmpty || s.toLowerCase().contains(_q.toLowerCase());

  @override
  Widget build(BuildContext context) {
    final clients = _clients.where((c) => _match('${c['name']} ${c['code']} ${c['phone'] ?? ''}')).toList();
    final patients = _patients.where((p) => _match('${p['full_name']}')).toList();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(children: [
        const SizedBox(height: 12),
        Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(children: [
            const Expanded(child: Text('اختر المريض',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
            TextButton.icon(
              onPressed: _busy ? null : _newWalkIn,
              icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
              label: const Text('مريض بدون تطبيق'),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: _dec('بحث بالاسم أو الرقم', suffix: const Icon(Icons.search)),
            onChanged: (v) => setState(() => _q = v.trim()),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(children: [
                  if (clients.isNotEmpty) _header('الحسابات المالية'),
                  ...clients.map((c) => ListTile(
                        leading: _avatar('${c['name']}'),
                        title: Text('${c['name']}'),
                        subtitle: Text('${c['code']}${c['is_walk_in'] == true ? ' · بدون تطبيق' : ''}'),
                        trailing: jsonDouble(c['due']) > 0
                            ? Text('متبقي ${money(c['due'])}',
                                style: const TextStyle(color: AppColors.error, fontSize: 12))
                            : null,
                        onTap: _busy ? null : () => Navigator.pop(context, c),
                      )),
                  if (patients.isNotEmpty) _header('مرضاي (بدون حساب مالي بعد)'),
                  ...patients.map((p) => ListTile(
                        leading: _avatar('${p['full_name']}'),
                        title: Text('${p['full_name']}'),
                        subtitle: const Text('سيتم إنشاء حساب مالي له'),
                        onTap: _busy ? null : () => _fromPatient(p),
                      )),
                  if (clients.isEmpty && patients.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('لا يوجد مرضى. أضف «مريض بدون تطبيق» من الأعلى.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary)),
                    ),
                ]),
        ),
      ]),
    );
  }

  Widget _header(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(t, style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
      );

  Widget _avatar(String name) => CircleAvatar(
        backgroundColor: AppColors.primary.withAlpha(25),
        child: Text(name.isNotEmpty ? name.substring(0, 1) : '؟',
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
      );
}

// ── Client (account) form ────────────────────────────────────────────────────

/// New walk-in account when [client] is null; otherwise edit it.
/// Returns the saved account, or `{'deleted': true}`.
Future<Map?> showClientForm(BuildContext context, {Map? client}) =>
    _sheet<Map>(context, _ClientForm(client: client));

class _ClientForm extends StatefulWidget {
  final Map? client;
  const _ClientForm({this.client});
  @override
  State<_ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends State<_ClientForm> {
  late final _name = TextEditingController(text: widget.client?['name'] as String? ?? '');
  late final _phone = TextEditingController(text: widget.client?['phone'] as String? ?? '');
  late final _notes = TextEditingController(text: widget.client?['notes'] as String? ?? '');
  bool _saving = false;

  bool get _isAppPatient => widget.client != null && widget.client!['is_walk_in'] != true;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_isAppPatient && _name.text.trim().isEmpty) {
      _snack(context, 'أدخل اسم المريض', error: true);
      return;
    }
    setState(() => _saving = true);
    final data = {
      if (!_isAppPatient) 'name': _name.text.trim(),
      'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    };
    try {
      final res = widget.client == null
          ? await ApiClient.instance.post('/therapist/finance/clients', data: data)
          : await ApiClient.instance.put('/therapist/finance/clients/${widget.client!['id']}', data: data);
      if (mounted) Navigator.pop(context, res.data as Map);
    } catch (e) {
      if (mounted) _snack(context, apiError(e), error: true);
      setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    if (!await _confirmDelete(context, 'الحساب')) return;
    setState(() => _saving = true);
    try {
      await ApiClient.instance.delete('/therapist/finance/clients/${widget.client!['id']}');
      if (mounted) Navigator.pop(context, {'deleted': true});
    } catch (e) {
      if (mounted) _snack(context, apiError(e), error: true);
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => _SheetBody(
        title: widget.client == null ? 'مريض بدون تطبيق' : 'بيانات الحساب',
        saving: _saving,
        onSave: _save,
        onDelete: widget.client != null ? _delete : null,
        children: [
          TextField(
            controller: _name,
            enabled: !_isAppPatient,
            decoration: _dec('الاسم',
                hint: _isAppPatient ? 'اسم المريض المسجّل في التطبيق' : null),
          ),
          _gap(),
          TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: _dec('رقم الهاتف (اختياري)')),
          _gap(),
          TextField(controller: _notes, maxLines: 2, decoration: _dec('ملاحظات (اختياري)')),
        ],
      );
}

// ── Invoice form ─────────────────────────────────────────────────────────────

/// Returns true when the invoice was saved or deleted.
Future<bool> showInvoiceForm(
  BuildContext context, {
  Map? client,
  Map? invoice,
  int? appointmentId,
  double? amount,
  String? description,
}) async =>
    await _sheet<bool>(context, _InvoiceForm(
      client: client,
      invoice: invoice,
      appointmentId: appointmentId,
      amount: amount,
      description: description,
    )) ??
    false;

class _InvoiceForm extends StatefulWidget {
  final Map? client;
  final Map? invoice;
  final int? appointmentId;
  final double? amount;
  final String? description;
  const _InvoiceForm({this.client, this.invoice, this.appointmentId, this.amount, this.description});
  @override
  State<_InvoiceForm> createState() => _InvoiceFormState();
}

class _InvoiceFormState extends State<_InvoiceForm> {
  late Map? _client = widget.client ??
      (widget.invoice == null
          ? null
          : {'id': widget.invoice!['client_id'], 'name': widget.invoice!['client_name'],
             'code': widget.invoice!['client_code']});
  late final _amount = TextEditingController(
      text: widget.invoice != null
          ? _fmtNum(widget.invoice!['amount'])
          : (widget.amount != null ? _fmtNum(widget.amount) : ''));
  late final _discount = TextEditingController(
      text: widget.invoice != null && jsonDouble(widget.invoice!['discount']) > 0
          ? _fmtNum(widget.invoice!['discount'])
          : '');
  late final _desc = TextEditingController(
      text: widget.invoice?['description'] as String? ?? widget.description ?? '');
  late final _notes = TextEditingController(text: widget.invoice?['notes'] as String? ?? '');
  late DateTime _date = DateTime.tryParse(widget.invoice?['issued_at'] as String? ?? '') ?? DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amount.addListener(_refresh);
    _discount.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _amount.dispose();
    _discount.dispose();
    _desc.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = _num(_amount.text);
    final discount = _discount.text.trim().isEmpty ? 0.0 : _num(_discount.text);
    if (_client == null) return _snack(context, 'اختر المريض', error: true);
    if (amount == null || amount < 0) return _snack(context, 'أدخل مبلغاً صحيحاً', error: true);
    if (discount == null || discount < 0 || discount > amount) {
      return _snack(context, 'الخصم يجب أن يكون بين 0 والمبلغ', error: true);
    }

    setState(() => _saving = true);
    final data = {
      'client_id': _client!['id'],
      'issued_at': apiDate(_date),
      'amount': amount,
      'discount': discount,
      'description': _desc.text.trim().isEmpty ? null : _desc.text.trim(),
      'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      if (widget.appointmentId != null) 'appointment_id': widget.appointmentId,
    };
    try {
      if (widget.invoice == null) {
        await ApiClient.instance.post('/therapist/finance/invoices', data: data);
      } else {
        await ApiClient.instance.put('/therapist/finance/invoices/${widget.invoice!['id']}', data: data);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _snack(context, apiError(e), error: true);
      setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    if (!await _confirmDelete(context, 'الفاتورة')) return;
    setState(() => _saving = true);
    try {
      await ApiClient.instance.delete('/therapist/finance/invoices/${widget.invoice!['id']}');
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _snack(context, apiError(e), error: true);
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = _num(_amount.text) ?? 0;
    final discount = _num(_discount.text) ?? 0;
    final total = (amount - discount).clamp(0, double.infinity);

    return _SheetBody(
      title: widget.invoice == null ? 'فاتورة جديدة' : 'فاتورة ${widget.invoice!['number_label']}',
      saving: _saving,
      onSave: _save,
      onDelete: widget.invoice != null ? _delete : null,
      children: [
        _ClientField(
          client: _client,
          locked: widget.client != null || widget.invoice != null,
          onPick: (c) => setState(() => _client = c),
        ),
        _gap(),
        _DateField(label: 'تاريخ الفاتورة', value: _date, onChanged: (d) => setState(() => _date = d)),
        _gap(),
        Row(children: [
          Expanded(child: TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _dec('المبلغ (₪)'),
          )),
          const SizedBox(width: 10),
          Expanded(child: TextField(
            controller: _discount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _dec('الخصم (₪)', hint: '0'),
          )),
        ]),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Text('الإجمالي: ${money(total)}',
              style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
        ),
        _gap(),
        TextField(controller: _desc, decoration: _dec('الوصف', hint: 'مثال: جلسة علاج طبيعي')),
        _gap(),
        TextField(controller: _notes, maxLines: 2, decoration: _dec('ملاحظات (اختياري)')),
      ],
    );
  }
}

class _ClientField extends StatelessWidget {
  final Map? client;
  final bool locked;
  final ValueChanged<Map> onPick;
  const _ClientField({required this.client, required this.locked, required this.onPick});

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: locked
            ? null
            : () async {
                final c = await pickClient(context);
                if (c != null) onPick(c);
              },
        child: InputDecorator(
          decoration: _dec('المريض',
              suffix: locked ? null : const Icon(Icons.arrow_drop_down)),
          child: Text(
            client == null ? 'اختر المريض' : '${client!['name']}  ·  ${client!['code'] ?? ''}',
            style: TextStyle(color: client == null ? AppColors.textSecondary : null),
          ),
        ),
      );
}

// ── Payment form ─────────────────────────────────────────────────────────────

Future<bool> showPaymentForm(BuildContext context, {Map? client, Map? payment, double? suggested}) async =>
    await _sheet<bool>(context, _PaymentForm(client: client, payment: payment, suggested: suggested)) ??
    false;

class _PaymentForm extends StatefulWidget {
  final Map? client;
  final Map? payment;
  final double? suggested;
  const _PaymentForm({this.client, this.payment, this.suggested});
  @override
  State<_PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<_PaymentForm> {
  late Map? _client = widget.client ??
      (widget.payment == null
          ? null
          : {'id': widget.payment!['client_id'], 'name': widget.payment!['client_name'],
             'code': widget.payment!['client_code']});
  late final _amount = TextEditingController(
      text: widget.payment != null
          ? _fmtNum(widget.payment!['amount'])
          : (widget.suggested != null && widget.suggested! > 0 ? _fmtNum(widget.suggested) : ''));
  late final _notes = TextEditingController(text: widget.payment?['notes'] as String? ?? '');
  late String _method = widget.payment?['method'] as String? ?? 'cash';
  late DateTime _date = DateTime.tryParse(widget.payment?['paid_at'] as String? ?? '') ?? DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = _num(_amount.text);
    if (_client == null) return _snack(context, 'اختر المريض', error: true);
    if (amount == null || amount <= 0) return _snack(context, 'أدخل مبلغاً صحيحاً', error: true);

    setState(() => _saving = true);
    final data = {
      'client_id': _client!['id'],
      'amount': amount,
      'method': _method,
      'paid_at': apiDate(_date),
      'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    };
    try {
      if (widget.payment == null) {
        await ApiClient.instance.post('/therapist/finance/payments', data: data);
      } else {
        await ApiClient.instance.put('/therapist/finance/payments/${widget.payment!['id']}', data: data);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _snack(context, apiError(e), error: true);
      setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    if (!await _confirmDelete(context, 'الدفعة')) return;
    setState(() => _saving = true);
    try {
      await ApiClient.instance.delete('/therapist/finance/payments/${widget.payment!['id']}');
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _snack(context, apiError(e), error: true);
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => _SheetBody(
        title: widget.payment == null ? 'تسجيل دفعة' : 'تعديل دفعة',
        saving: _saving,
        onSave: _save,
        onDelete: widget.payment != null ? _delete : null,
        children: [
          _ClientField(
            client: _client,
            locked: widget.client != null || widget.payment != null,
            onPick: (c) => setState(() => _client = c),
          ),
          _gap(),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _dec('المبلغ المدفوع (₪)'),
          ),
          _gap(),
          const Text('طريقة الدفع', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 8),
          _choiceChips(paymentMethods, _method, (v) => setState(() => _method = v)),
          _gap(),
          _DateField(label: 'تاريخ الدفع', value: _date, onChanged: (d) => setState(() => _date = d)),
          _gap(),
          TextField(controller: _notes, maxLines: 2, decoration: _dec('ملاحظات (اختياري)')),
        ],
      );
}

// ── Expense form ─────────────────────────────────────────────────────────────

Future<bool> showExpenseForm(BuildContext context, {Map? expense}) async =>
    await _sheet<bool>(context, _ExpenseForm(expense: expense)) ?? false;

class _ExpenseForm extends StatefulWidget {
  final Map? expense;
  const _ExpenseForm({this.expense});
  @override
  State<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<_ExpenseForm> {
  late String _category = widget.expense?['category'] as String? ?? 'rent';
  late final _amount = TextEditingController(
      text: widget.expense != null ? _fmtNum(widget.expense!['amount']) : '');
  late final _desc = TextEditingController(text: widget.expense?['description'] as String? ?? '');
  late DateTime _date = DateTime.tryParse(widget.expense?['spent_at'] as String? ?? '') ?? DateTime.now();
  late final String? _receiptUrl = widget.expense?['receipt_url'] as String?;
  XFile? _receipt;
  bool _removeReceipt = false;
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickReceipt() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 75, maxWidth: 1800);
    if (f != null) setState(() { _receipt = f; _removeReceipt = false; });
  }

  Future<void> _save() async {
    final amount = _num(_amount.text);
    if (amount == null || amount <= 0) return _snack(context, 'أدخل مبلغاً صحيحاً', error: true);

    setState(() => _saving = true);
    final form = FormData.fromMap({
      'category': _category,
      'amount': amount,
      'spent_at': apiDate(_date),
      'description': _desc.text.trim(),
      if (_receipt != null) 'receipt': await MultipartFile.fromFile(_receipt!.path, filename: _receipt!.name),
      if (_removeReceipt) 'remove_receipt': 1,
    });
    try {
      final path = widget.expense == null
          ? '/therapist/finance/expenses'
          : '/therapist/finance/expenses/${widget.expense!['id']}';
      await ApiClient.instance.post(path, data: form);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _snack(context, apiError(e), error: true);
      setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    if (!await _confirmDelete(context, 'المصروف')) return;
    setState(() => _saving = true);
    try {
      await ApiClient.instance.delete('/therapist/finance/expenses/${widget.expense!['id']}');
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _snack(context, apiError(e), error: true);
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasReceipt = _receipt != null || (_receiptUrl != null && !_removeReceipt);
    return _SheetBody(
      title: widget.expense == null ? 'مصروف جديد' : 'تعديل مصروف',
      saving: _saving,
      onSave: _save,
      onDelete: widget.expense != null ? _delete : null,
      children: [
        const Text('التصنيف', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 8),
        _choiceChips(expenseCategories, _category, (v) => setState(() => _category = v)),
        _gap(),
        TextField(
          controller: _amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _dec('المبلغ (₪)'),
        ),
        _gap(),
        _DateField(label: 'التاريخ', value: _date, onChanged: (d) => setState(() => _date = d)),
        _gap(),
        TextField(controller: _desc, decoration: _dec('الوصف (اختياري)', hint: 'مثال: إيجار شهر أكتوبر')),
        _gap(),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: _pickReceipt,
            icon: Icon(hasReceipt ? Icons.check_circle : Icons.receipt_long_outlined,
                color: hasReceipt ? AppColors.success : null),
            label: Text(_receipt != null
                ? 'تم اختيار صورة الإيصال'
                : hasReceipt ? 'تغيير صورة الإيصال' : 'إرفاق صورة الإيصال (اختياري)'),
          )),
          if (hasReceipt)
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.error),
              onPressed: () => setState(() {
                _receipt = null;
                if (_receiptUrl != null) _removeReceipt = true;
              }),
            ),
        ]),
      ],
    );
  }
}
