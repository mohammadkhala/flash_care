import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json_utils.dart';
import '../finance/finance_forms.dart';
import '../finance/finance_utils.dart';
import 'report_pdf.dart';

/// Starts a new report: pick the patient (unless given), then the template.
Future<void> startNewReport(BuildContext context, {Map? client, int? appointmentId}) async {
  final c = client ?? await pickClient(context);
  if (c == null || !context.mounted) return;

  List<Map> templates;
  try {
    final res = await ApiClient.instance.get('/therapist/report-templates');
    templates = (res.data as List).cast<Map>();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiError(e))));
    }
    return;
  }
  if (!context.mounted) return;
  if (templates.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد قوالب تقييم مفعّلة — تواصل مع الإدارة')));
    return;
  }

  final t = await showModalBottomSheet<Map>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.75),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 14),
        Text('نوع التقييم — ${c['name']}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Flexible(child: ListView(shrinkWrap: true, children: templates.map((t) {
          final sections = (t['sections'] as List).cast<Map>();
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE3ECF8),
              child: Icon(Icons.assignment_outlined, color: Color(0xFF1565C0)),
            ),
            title: Text('${t['name_ar']}'),
            subtitle: Text('${t['name_en']} · ${sections.length} أقسام',
                style: const TextStyle(fontSize: 12)),
            onTap: () => Navigator.pop(ctx, t),
          );
        }).toList())),
        const SizedBox(height: 12),
      ]),
    ),
  );
  if (t == null || !context.mounted) return;

  await context.push('/reports/edit', extra: {'client': c, 'template': t, 'appointmentId': appointmentId});
}

/// All reports of the therapist, or of one patient when [clientId] is given.
class ReportsPage extends StatefulWidget {
  final int? clientId;
  final String? clientName;
  const ReportsPage({this.clientId, this.clientName, super.key});
  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  List<Map> _reports = [];
  bool _loading = true;
  String _search = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient.instance.get('/therapist/reports', queryParameters: {
        if (widget.clientId != null) 'client_id': widget.clientId,
        if (_search.isNotEmpty) 'search': _search,
      });
      setState(() {
        _reports = (res.data as List).cast<Map>();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _new() async {
    Map? client;
    if (widget.clientId != null) {
      client = {'id': widget.clientId, 'name': widget.clientName ?? ''};
      try {
        final res = await ApiClient.instance.get('/therapist/finance/clients/${widget.clientId}');
        client = (res.data as Map)['client'] as Map;
      } catch (_) {}
    }
    if (!mounted) return;
    await startNewReport(context, client: client);
    _load();
  }

  Future<void> _delete(Map r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف التقرير؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('رجوع')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error), child: const Text('حذف')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiClient.instance.delete('/therapist/reports/${r['id']}');
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiError(e))));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(widget.clientName != null ? 'تقارير ${widget.clientName}' : 'تقارير التقييم'),
          actions: [
            IconButton(
              tooltip: 'عياداتي',
              icon: const Icon(Icons.local_hospital_outlined),
              onPressed: () => context.push('/clinics'),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _new,
          icon: const Icon(Icons.note_add_outlined),
          label: const Text('تقرير جديد'),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  children: [
                    if (widget.clientId == null) ...[
                      TextField(
                        onChanged: (v) {
                          _debounce?.cancel();
                          _debounce = Timer(const Duration(milliseconds: 400), () {
                            _search = v.trim();
                            _load();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'ابحث باسم المريض أو نوع التقييم...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: AppColors.surface,
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_reports.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 70),
                        child: Column(children: [
                          Icon(Icons.assignment_outlined, size: 56, color: AppColors.border),
                          SizedBox(height: 10),
                          Text('لا توجد تقارير بعد', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                          SizedBox(height: 4),
                          Text('اضغط «تقرير جديد» واختر المريض ونوع التقييم',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ]),
                      ),
                    ..._reports.map(_tile),
                  ],
                ),
              ),
      );

  Widget _tile(Map r) {
    final isFinal = r['status'] == 'final';
    final abnormal = jsonInt(r['abnormal']);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: () async {
          await context.push('/reports/edit', extra: {'reportId': r['id']});
          _load();
        },
        onLongPress: () => _delete(r),
        leading: CircleAvatar(
          backgroundColor: (isFinal ? AppColors.success : AppColors.warning).withAlpha(25),
          child: Icon(isFinal ? Icons.task_outlined : Icons.edit_note,
              color: isFinal ? AppColors.success : AppColors.warning),
        ),
        title: Text(widget.clientId == null ? '${r['client_name']}  ·  ${r['client_code']}' : '${r['title']}',
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text([
          if (widget.clientId == null) r['title'],
          showDate(r['assessed_at'] as String?),
          isFinal ? 'نهائي' : 'مسودة',
          if (abnormal > 0) '$abnormal خارج الطبيعي',
        ].join(' · '), style: const TextStyle(fontSize: 12)),
        trailing: IconButton(
          tooltip: 'PDF',
          icon: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFF1565C0)),
          onPressed: () => openReportPdf(context, r['id'] as int,
              fileName: '${r['client_code']} ${r['title']}'),
        ),
      ),
    );
  }
}
