import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json_utils.dart';
import 'finance_forms.dart';
import 'finance_utils.dart';

/// Period shown by the payments / invoices / expenses lists and totals.
class _Period {
  final String label;
  final DateTime from;
  final DateTime to;
  const _Period(this.label, this.from, this.to);

  Map<String, String> get query => {'from': apiDate(from), 'to': apiDate(to)};

  static _Period thisMonth() {
    final n = DateTime.now();
    return _Period('هذا الشهر', DateTime(n.year, n.month), DateTime(n.year, n.month + 1, 0));
  }

  static _Period lastMonth() {
    final n = DateTime.now();
    return _Period('الشهر الماضي', DateTime(n.year, n.month - 1), DateTime(n.year, n.month, 0));
  }

  static _Period last3Months() {
    final n = DateTime.now();
    return _Period('آخر 3 أشهر', DateTime(n.year, n.month - 2), DateTime(n.year, n.month + 1, 0));
  }

  static _Period thisYear() {
    final n = DateTime.now();
    return _Period('هذه السنة', DateTime(n.year), DateTime(n.year, 12, 31));
  }
}

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});
  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this)
    ..addListener(() { if (!_tabs.indexIsChanging) setState(() {}); });

  _Period _period = _Period.thisMonth();
  Map _summary = {};

  List<Map> _clients = [];
  List<Map> _payments = [];
  List<Map> _invoices = [];
  List<Map> _expenses = [];
  bool _loading = true;

  String _clientSearch = '';
  String? _clientStatus;
  bool _showPaymentLog = false;
  String _invoiceSearch = '';
  String? _invoiceStatus;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    await Future.wait([_loadSummary(), _loadClients(), _loadPayments(), _loadInvoices(), _loadExpenses()]);
    if (mounted) setState(() => _loading = false);
  }

  Future<List<Map>> _getList(String path, Map<String, dynamic> q) async {
    final res = await ApiClient.instance.get(path, queryParameters: q);
    return (res.data as List).cast<Map>();
  }

  Future<void> _loadSummary() async {
    try {
      final res = await ApiClient.instance.get('/therapist/finance/summary', queryParameters: _period.query);
      if (mounted) setState(() => _summary = res.data as Map);
    } catch (_) {}
  }

  Future<void> _loadClients() async {
    try {
      final list = await _getList('/therapist/finance/clients', {
        if (_clientSearch.isNotEmpty) 'search': _clientSearch,
        if (_clientStatus != null) 'status': _clientStatus,
      });
      if (mounted) setState(() => _clients = list);
    } catch (_) {}
  }

  Future<void> _loadPayments() async {
    try {
      final list = await _getList('/therapist/finance/payments', {
        ..._period.query,
        if (_clientSearch.isNotEmpty) 'search': _clientSearch,
      });
      if (mounted) setState(() => _payments = list);
    } catch (_) {}
  }

  Future<void> _loadInvoices() async {
    try {
      final list = await _getList('/therapist/finance/invoices', {
        ..._period.query,
        if (_invoiceSearch.isNotEmpty) 'search': _invoiceSearch,
        if (_invoiceStatus != null) 'status': _invoiceStatus,
      });
      if (mounted) setState(() => _invoices = list);
    } catch (_) {}
  }

  Future<void> _loadExpenses() async {
    try {
      final list = await _getList('/therapist/finance/expenses', _period.query);
      if (mounted) setState(() => _expenses = list);
    } catch (_) {}
  }

  void _searchLater(VoidCallback apply) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), apply);
  }

  Future<void> _pickPeriod() async {
    final options = [_Period.thisMonth(), _Period.lastMonth(), _Period.last3Months(), _Period.thisYear()];
    final choice = await showModalBottomSheet<Object>(
      context: context,
      builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        ...options.map((p) => ListTile(
              title: Text(p.label),
              trailing: p.label == _period.label ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () => Navigator.pop(ctx, p),
            )),
        ListTile(
          leading: const Icon(Icons.date_range_outlined),
          title: const Text('فترة مخصصة'),
          onTap: () => Navigator.pop(ctx, 'custom'),
        ),
      ])),
    );
    if (choice is _Period) {
      setState(() => _period = choice);
    } else if (choice == 'custom' && mounted) {
      final r = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        initialDateRange: DateTimeRange(start: _period.from, end: _period.to),
      );
      if (r == null) return;
      setState(() => _period = _Period('${showDate(apiDate(r.start))} – ${showDate(apiDate(r.end))}', r.start, r.end));
    } else {
      return;
    }
    _loadAll();
  }

  Future<void> _onFab() async {
    final form = switch (_tabs.index) {
      0 => showPaymentForm(context),
      1 => showInvoiceForm(context),
      _ => showExpenseForm(context),
    };
    if (await form) _loadAll();
  }

  Future<void> _openClient(Map c) async {
    await context.push('/finance/client/${c['id']}');
    _loadAll();
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('المالية'),
          actions: [
            TextButton.icon(
              onPressed: _pickPeriod,
              icon: const Icon(Icons.date_range_outlined, size: 18),
              label: Text(_period.label, style: const TextStyle(fontSize: 12)),
            ),
          ],
          bottom: TabBar(
            controller: _tabs,
            labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
            tabs: const [Tab(text: 'المدفوعات'), Tab(text: 'الفواتير'), Tab(text: 'المصاريف')],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _onFab,
          icon: const Icon(Icons.add),
          label: Text(const ['تسجيل دفعة', 'فاتورة جديدة', 'مصروف جديد'][_tabs.index]),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(controller: _tabs, children: [
                _paymentsTab(),
                _invoicesTab(),
                _expensesTab(),
              ]),
      );

  Widget _list(List<Widget> children) => RefreshIndicator(
        onRefresh: _loadAll,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: children,
        ),
      );

  // ── Payments tab (accounts per patient) ────────────────────

  Widget _paymentsTab() => _list([
        _searchField('ابحث باسم المريض أو رقمه...', (v) => _searchLater(() {
              _clientSearch = v.trim();
              _loadClients();
              _loadPayments();
            })),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _statCard('المستحق', money(_summary['total_due']),
              Icons.account_balance_wallet_outlined, AppColors.error)),
          const SizedBox(width: 10),
          Expanded(child: _statCard('المدفوع (${_period.label})', money(_summary['paid']),
              Icons.check_circle_outline, AppColors.success)),
        ]),
        const SizedBox(height: 10),
        _statCard('عدد المرضى', '${_summary['clients_count'] ?? 0}',
            Icons.people_alt_outlined, AppColors.primary, wide: true),
        const SizedBox(height: 16),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('حسب المريض'), icon: Icon(Icons.people_outline)),
            ButtonSegment(value: true, label: Text('سجل الدفعات'), icon: Icon(Icons.receipt_outlined)),
          ],
          selected: {_showPaymentLog},
          onSelectionChanged: (s) => setState(() => _showPaymentLog = s.first),
        ),
        const SizedBox(height: 12),
        if (!_showPaymentLog) ...[
          _statusFilter(_clientStatus, (s) { setState(() => _clientStatus = s); _loadClients(); }),
          const SizedBox(height: 10),
          _clientsTable(),
        ] else
          ..._paymentLog(),
      ]);

  Widget _clientsTable() {
    if (_clients.isEmpty) {
      return _empty('لا توجد حسابات بعد', 'سجّل دفعة أو فاتورة وسيظهر المريض هنا');
    }
    const head = TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w700);
    return Container(
      decoration: _cardDecoration(),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 8),
          child: Row(children: const [
            Expanded(flex: 4, child: Text('المريض', style: head)),
            Expanded(flex: 3, child: Text('المبلغ', style: head, textAlign: TextAlign.center)),
            Expanded(flex: 3, child: Text('المدفوع', style: head, textAlign: TextAlign.center)),
            Expanded(flex: 3, child: Text('المتبقي', style: head, textAlign: TextAlign.center)),
            Expanded(flex: 4, child: Text('الحالة', style: head, textAlign: TextAlign.center)),
            SizedBox(width: 18),
          ]),
        ),
        const Divider(height: 1),
        ..._clients.map((c) => InkWell(
              onTap: () => _openClient(c),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.borderLight))),
                child: Row(children: [
                  Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${c['name']}', maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Text('${c['code']}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ])),
                  _cell(c['invoiced'], 3),
                  _cell(c['paid'], 3),
                  _cell(c['due'], 3, color: jsonDouble(c['due']) > 0 ? AppColors.error : null),
                  Expanded(flex: 4, child: Center(child: StatusChip(c['status'] as String?))),
                  const Icon(Icons.chevron_left, size: 18, color: AppColors.textSecondary),
                ]),
              ),
            )),
      ]),
    );
  }

  Widget _cell(dynamic v, int flex, {Color? color}) => Expanded(
        flex: flex,
        child: Text(money(v), textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
      );

  List<Widget> _paymentLog() {
    if (_payments.isEmpty) return [_empty('لا توجد دفعات في ${_period.label}', null)];
    return _payments.map((p) => _tile(
          icon: Icons.payments_outlined,
          color: AppColors.success,
          title: '${p['client_name']}',
          subtitle: '${paymentMethods[p['method']] ?? ''} · ${showDate(p['paid_at'] as String?)}',
          trailing: Text(money(p['amount']),
              style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.success)),
          onTap: () async {
            if (await showPaymentForm(context, payment: p)) _loadAll();
          },
        )).toList();
  }

  // ── Invoices tab ───────────────────────────────────────────

  Widget _invoicesTab() {
    final total = _invoices.fold<double>(0, (s, i) => s + jsonDouble(i['total']));
    final due = _invoices.fold<double>(0, (s, i) => s + jsonDouble(i['due']));
    return _list([
      _searchField('ابحث بالاسم أو رقم الفاتورة...', (v) => _searchLater(() {
            _invoiceSearch = v.trim();
            _loadInvoices();
          })),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _statCard('إجمالي الفواتير', money(total), Icons.receipt_long_outlined, AppColors.primary)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('غير المحصّل منها', money(due), Icons.hourglass_bottom, AppColors.warning)),
      ]),
      const SizedBox(height: 14),
      _statusFilter(_invoiceStatus, (s) { setState(() => _invoiceStatus = s); _loadInvoices(); }),
      const SizedBox(height: 10),
      if (_invoices.isEmpty) _empty('لا توجد فواتير في ${_period.label}', 'اضغط «فاتورة جديدة» لإضافة فاتورة'),
      ..._invoices.map((i) => _tile(
            icon: Icons.receipt_long_outlined,
            color: statusColor(i['status'] as String?),
            title: '${i['client_name']}  ·  ${i['number_label']}',
            subtitle: [
              showDate(i['issued_at'] as String?),
              if ((i['description'] as String?)?.isNotEmpty ?? false) i['description'],
              if (jsonDouble(i['due']) > 0 && i['status'] == 'partial') 'متبقي ${money(i['due'])}',
            ].join(' · '),
            trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(money(i['total']), style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              StatusChip(i['status'] as String?),
            ]),
            onTap: () async {
              if (await showInvoiceForm(context, invoice: i)) _loadAll();
            },
          )),
    ]);
  }

  // ── Expenses tab ───────────────────────────────────────────

  Widget _expensesTab() {
    final byCat = (_summary['expenses_by_category'] as Map?) ?? {};
    final net = jsonDouble(_summary['net']);
    return _list([
      Row(children: [
        Expanded(child: _statCard('المصاريف', money(_summary['expenses']), Icons.trending_down, AppColors.error)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('صافي الدخل', money(net), Icons.savings_outlined,
            net >= 0 ? AppColors.success : AppColors.error)),
      ]),
      const SizedBox(height: 6),
      Text('صافي الدخل = المدفوع (${money(_summary['paid'])}) − المصاريف، خلال ${_period.label}',
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      if (byCat.isNotEmpty) ...[
        const SizedBox(height: 14),
        Wrap(spacing: 8, runSpacing: 8, children: byCat.entries.map((e) => Chip(
              avatar: Icon(expenseIcons[e.key] ?? Icons.receipt_long_outlined, size: 16),
              label: Text('${expenseCategories[e.key] ?? e.key}: ${money(e.value)}',
                  style: const TextStyle(fontSize: 12)),
            )).toList()),
      ],
      const SizedBox(height: 14),
      if (_expenses.isEmpty) _empty('لا توجد مصاريف في ${_period.label}', 'اضغط «مصروف جديد» لإضافة مصروف'),
      ..._expenses.map((e) => _tile(
            icon: expenseIcons[e['category']] ?? Icons.receipt_long_outlined,
            color: AppColors.accent,
            title: expenseCategories[e['category']] ?? '${e['category']}',
            subtitle: [
              showDate(e['spent_at'] as String?),
              if ((e['description'] as String?)?.isNotEmpty ?? false) e['description'],
              if (e['receipt_url'] != null) '📎 إيصال',
            ].join(' · '),
            trailing: Text(money(e['amount']),
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.error)),
            onTap: () async {
              if (await showExpenseForm(context, expense: e)) _loadAll();
            },
          )),
    ]);
  }

  // ── Pieces ─────────────────────────────────────────────────

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      );

  Widget _searchField(String hint, ValueChanged<String> onChanged) => TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: AppColors.surface,
          isDense: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
        ),
      );

  Widget _statusFilter(String? value, ValueChanged<String?> onChanged) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final s in const [null, 'unpaid', 'partial', 'paid'])
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(s == null ? 'الكل' : statusLabels[s]!),
                selected: value == s,
                onSelected: (_) => onChanged(s),
              ),
            ),
        ]),
      );

  Widget _statCard(String label, String value, IconData icon, Color color, {bool wide = false}) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withAlpha(18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(45)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withAlpha(30), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(value, style: TextStyle(fontSize: wide ? 20 : 18, fontWeight: FontWeight.w800, color: color)),
            ),
          ])),
        ]),
      );

  Widget _tile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: _cardDecoration(),
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(backgroundColor: color.withAlpha(25), child: Icon(icon, color: color, size: 20)),
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          subtitle: subtitle.isEmpty ? null : Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12)),
          trailing: trailing,
        ),
      );

  Widget _empty(String title, String? hint) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(children: [
          const Icon(Icons.inbox_outlined, size: 48, color: AppColors.border),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(hint, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ]),
      );
}
