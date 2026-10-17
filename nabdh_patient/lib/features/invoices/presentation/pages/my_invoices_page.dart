import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/json_utils.dart';

final _money = NumberFormat('#,##0.##', 'en');
String _fmt(dynamic v) => '${_money.format(jsonDouble(v))} ₪';

String _date(String? s) {
  final d = s == null ? null : DateTime.tryParse(s);
  return d == null ? '' : DateFormat('dd/MM/yyyy', 'en').format(d);
}

const _statusLabels = {'paid': 'مدفوعة', 'partial': 'مدفوعة جزئياً', 'unpaid': 'غير مدفوعة'};
const _methods = {'cash': 'نقداً', 'card': 'بطاقة', 'bank_transfer': 'تحويل بنكي', 'other': 'أخرى'};

Color _statusColor(String? s) => switch (s) {
  'paid'    => AppColors.success,
  'partial' => AppColors.warning,
  'unpaid'  => AppColors.error,
  _         => AppColors.textSecondary,
};

/// Invoices and payments recorded by the patient's therapists (read-only).
class MyInvoicesPage extends StatefulWidget {
  const MyInvoicesPage({super.key});
  @override
  State<MyInvoicesPage> createState() => _MyInvoicesPageState();
}

class _MyInvoicesPageState extends State<MyInvoicesPage> {
  Map _summary = {};
  List<Map> _accounts = [];
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient.instance.get('/patient/invoices');
      final d = res.data as Map;
      setState(() {
        _summary = d['summary'] as Map? ?? {};
        _accounts = (d['accounts'] as List? ?? []).cast<Map>();
        _loading = false;
        _failed = false;
      });
    } catch (_) {
      setState(() { _loading = false; _failed = true; });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('فواتيري')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  children: [
                    if (_failed)
                      _message(Icons.wifi_off_rounded, 'تعذّر تحميل الفواتير، اسحب للتحديث')
                    else if (_accounts.isEmpty)
                      _message(Icons.receipt_long_outlined, 'لا توجد فواتير بعد',
                          hint: 'عندما يسجّل أخصائيك فاتورة أو دفعة ستظهر هنا')
                    else ...[
                      _summaryCard(),
                      const SizedBox(height: 16),
                      ..._accounts.map(_accountCard),
                    ],
                  ],
                ),
              ),
      );

  Widget _summaryCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(children: [
          _figure('إجمالي الفواتير', _fmt(_summary['invoiced'])),
          _figure('المدفوع', _fmt(_summary['paid'])),
          _figure('المتبقي عليك', _fmt(_summary['due'])),
        ]),
      );

  Widget _figure(String label, String value) => Expanded(child: Column(children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 6),
        FittedBox(child: Text(value,
            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800))),
      ]));

  Widget _accountCard(Map a) {
    final invoices = (a['invoices'] as List? ?? []).cast<Map>();
    final payments = (a['payments'] as List? ?? []).cast<Map>();
    final due = jsonDouble(a['due']);
    final credit = jsonDouble(a['credit']);
    final name = '${a['therapist_name'] ?? 'الأخصائي'}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _accounts.length == 1,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withAlpha(25),
            child: Text(name.isNotEmpty ? name.substring(0, 1) : '؟',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          subtitle: Text(
            credit > 0
                ? 'رصيد لك ${_fmt(credit)}'
                : due > 0 ? 'المتبقي ${_fmt(due)}' : 'لا يوجد مبلغ مستحق',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: due > 0 ? AppColors.error : AppColors.success,
            ),
          ),
          children: [
            if (invoices.isNotEmpty) _label('الفواتير'),
            ...invoices.map(_invoiceRow),
            if (payments.isNotEmpty) ...[
              const SizedBox(height: 8),
              _label('الدفعات'),
              ...payments.map(_paymentRow),
            ],
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6, top: 4),
          child: Text(t, style: const TextStyle(
              fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
        ),
      );

  Widget _invoiceRow(Map i) {
    final status = i['status'] as String?;
    final color = _statusColor(status);
    final discount = jsonDouble(i['discount']);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${i['number_label']}  ·  ${_date(i['issued_at'] as String?)}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          if ((i['description'] as String?)?.isNotEmpty ?? false)
            Text('${i['description']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          if (discount > 0)
            Text('خصم ${_fmt(discount)}', style: const TextStyle(fontSize: 11, color: AppColors.success)),
          if (status == 'partial')
            Text('متبقي ${_fmt(i['due'])}', style: const TextStyle(fontSize: 11, color: AppColors.error)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(_fmt(i['total']), style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: color.withAlpha(28), borderRadius: BorderRadius.circular(20)),
            child: Text(_statusLabels[status] ?? '—',
                style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
          ),
        ]),
      ]),
    );
  }

  Widget _paymentRow(Map p) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text('${_methods[p['method']] ?? ''} · ${_date(p['paid_at'] as String?)}',
              style: const TextStyle(fontSize: 12))),
          Text(_fmt(p['amount']),
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.success)),
        ]),
      );

  Widget _message(IconData icon, String title, {String? hint}) => Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(children: [
          Icon(icon, size: 56, color: AppColors.border),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(hint, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ]),
      );
}
