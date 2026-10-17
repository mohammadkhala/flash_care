import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json_utils.dart';
import 'finance_forms.dart';
import 'finance_utils.dart';

/// One patient's account with this therapist: balance, invoices, payments.
class ClientAccountPage extends StatefulWidget {
  final int clientId;
  const ClientAccountPage({required this.clientId, super.key});
  @override
  State<ClientAccountPage> createState() => _ClientAccountPageState();
}

class _ClientAccountPageState extends State<ClientAccountPage> {
  Map? _client;
  List<Map> _invoices = [];
  List<Map> _payments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient.instance.get('/therapist/finance/clients/${widget.clientId}');
      final d = res.data as Map;
      setState(() {
        _client = d['client'] as Map;
        _invoices = (d['invoices'] as List).cast<Map>();
        _payments = (d['payments'] as List).cast<Map>();
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() { _loading = false; _error = apiError(e); });
    }
  }

  Future<void> _edit() async {
    final r = await showClientForm(context, client: _client);
    if (r == null) return;
    if (r['deleted'] == true) {
      if (mounted) context.pop();
    } else {
      _load();
    }
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final c = _client;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(c == null ? 'الحساب المالي' : '${c['name']}'),
        actions: [
          if (c != null) IconButton(icon: const Icon(Icons.edit_outlined), onPressed: _edit),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : c == null
              ? Center(child: Text(_error ?? 'لم يُعثر على الحساب'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                    children: [
                      _header(c),
                      const SizedBox(height: 14),
                      Row(children: [
                        Expanded(child: ElevatedButton.icon(
                          onPressed: () async {
                            if (await showPaymentForm(context, client: c, suggested: jsonDouble(c['due']))) _load();
                          },
                          icon: const Icon(Icons.payments_outlined),
                          label: const Text('تسجيل دفعة'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                        )),
                        const SizedBox(width: 10),
                        Expanded(child: OutlinedButton.icon(
                          onPressed: () async {
                            if (await showInvoiceForm(context, client: c)) _load();
                          },
                          icon: const Icon(Icons.receipt_long_outlined),
                          label: const Text('فاتورة جديدة'),
                        )),
                      ]),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/reports',
                            extra: {'clientId': c['id'], 'clientName': c['name']}),
                        icon: const Icon(Icons.assignment_outlined),
                        label: const Text('تقارير التقييم (ملف المريض)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1565C0),
                          minimumSize: const Size(double.infinity, 46),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _section('الفواتير', _invoices.length),
                      if (_invoices.isEmpty) _none('لا توجد فواتير'),
                      ..._invoices.map(_invoiceTile),
                      const SizedBox(height: 16),
                      _section('الدفعات', _payments.length),
                      if (_payments.isEmpty) _none('لا توجد دفعات'),
                      ..._payments.map(_paymentTile),
                    ],
                  ),
                ),
    );
  }

  Widget _header(Map c) {
    final credit = jsonDouble(c['credit']);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${c['name']}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text('${c['code']}${c['is_walk_in'] == true ? '  ·  بدون تطبيق' : ''}',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ])),
          if ((c['phone'] as String?)?.isNotEmpty ?? false)
            IconButton(
              onPressed: () => _call(c['phone'] as String),
              icon: const Icon(Icons.phone_outlined, color: Colors.white),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: StatusChip(c['status'] as String?),
          ),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          _figure('الفواتير', money(c['invoiced'])),
          _figure('المدفوع', money(c['paid'])),
          _figure(credit > 0 ? 'رصيد له' : 'المتبقي', money(credit > 0 ? credit : c['due'])),
        ]),
        if ((c['notes'] as String?)?.isNotEmpty ?? false) ...[
          const SizedBox(height: 12),
          Text('${c['notes']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ]),
    );
  }

  Widget _figure(String label, String value) => Expanded(child: Column(children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 4),
        FittedBox(child: Text(value,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800))),
      ]));

  Widget _section(String title, int count) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text('$title ($count)', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
      );

  Widget _none(String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(t, style: const TextStyle(color: AppColors.textSecondary)),
      );

  BoxDecoration get _card => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      );

  Widget _invoiceTile(Map i) {
    final discount = jsonDouble(i['discount']);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: _card,
      child: ListTile(
        onTap: () async {
          if (await showInvoiceForm(context, invoice: i)) _load();
        },
        title: Text('${i['number_label']}  ·  ${showDate(i['issued_at'] as String?)}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text([
          if ((i['description'] as String?)?.isNotEmpty ?? false) i['description'],
          if (discount > 0) 'خصم ${money(discount)}',
          if (i['status'] == 'partial') 'مدفوع ${money(i['paid'])} · متبقي ${money(i['due'])}',
        ].join(' · '), style: const TextStyle(fontSize: 12)),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(money(i['total']), style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          StatusChip(i['status'] as String?),
        ]),
      ),
    );
  }

  Widget _paymentTile(Map p) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: _card,
        child: ListTile(
          onTap: () async {
            if (await showPaymentForm(context, payment: p)) _load();
          },
          leading: CircleAvatar(
            backgroundColor: AppColors.success.withAlpha(25),
            child: const Icon(Icons.payments_outlined, color: AppColors.success, size: 20),
          ),
          title: Text(money(p['amount']),
              style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.success)),
          subtitle: Text([
            paymentMethods[p['method']] ?? '',
            showDate(p['paid_at'] as String?),
            if ((p['notes'] as String?)?.isNotEmpty ?? false) p['notes'],
          ].join(' · '), style: const TextStyle(fontSize: 12)),
        ),
      );
}
