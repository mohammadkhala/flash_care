import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/json_utils.dart';
import '../../../../core/l10n/s.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});
  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  List _convs = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get('/messages/conversations');
      setState(() {
        _convs = res.data is List ? res.data : (res.data['data'] ?? []);
        _loading = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return '${diff.inMinutes}د';
    if (diff.inHours < 24) return '${diff.inHours}س';
    if (diff.inDays < 7) return '${diff.inDays}ي';
    return '${(diff.inDays / 7).floor()}أ';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _openNewConversation,
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
      label: Text(S.newConversation, style: const TextStyle(color: Colors.white)),
    ),
    body: NestedScrollView(
      headerSliverBuilder: (_, __) => [
        SliverAppBar(
          pinned: true,
          expandedHeight: 100,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(S.messages,
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ),
        ),
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _convs.isEmpty
              ? _empty()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 80, top: 8),
                    itemCount: _convs.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 80, endIndent: 16, color: AppColors.borderLight),
                    itemBuilder: (_, i) {
                      final c = _convs[i] as Map;
                      final patient  = c['patient'] as Map? ?? {};
                      final last     = c['last_message'] as Map? ?? {};
                      final name     = patient['full_name'] as String? ?? 'مريض';
                      final unread   = jsonInt(c['therapist_unread']);
                      final content  = last['content'] as String? ?? '';
                      final time     = last['created_at'] as String? ?? c['last_message_at'] as String?;
                      final partnerId = jsonInt(c['patient_id']);

                      return InkWell(
                        onTap: () => context.push(
                          '/messages/${c['id']}',
                          extra: {'name': name, 'partnerId': partnerId},
                        ).then((_) => _load()),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(children: [
                            Stack(children: [
                              Container(
                                width: 54, height: 54,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.primary.withOpacity(0.8), AppColors.primaryLight],
                                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(17),
                                ),
                                child: Center(child: Text(name.isNotEmpty ? name[0] : '؟',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22))),
                              ),
                              if (unread > 0)
                                Positioned(top: 0, right: 0,
                                  child: Container(
                                    width: 18, height: 18,
                                    decoration: BoxDecoration(
                                      color: AppColors.accent,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.surface, width: 2),
                                    ),
                                    child: Center(child: Text('$unread',
                                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))),
                                  )),
                            ]),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(name,
                                  style: TextStyle(fontWeight: unread > 0 ? FontWeight.w800 : FontWeight.w600, fontSize: 15)),
                              const SizedBox(height: 3),
                              Text(content.isEmpty ? 'لا توجد رسائل' : content,
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: unread > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.w400,
                                  )),
                            ])),
                            const SizedBox(width: 8),
                            Text(_timeAgo(time),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: unread > 0 ? AppColors.accent : AppColors.textHint,
                                  fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w400,
                                )),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
    ),
  );

  Future<void> _openNewConversation() async {
    // Load patients list
    try {
      final res = await ApiClient.instance.get('/therapist/patients');
      final patients = res.data is List ? res.data : (res.data['data'] ?? []);
      if (!mounted) return;

      if (patients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يوجد مرضى لبدء محادثة معهم')),
        );
        return;
      }

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => _PatientPickerSheet(
          patients: patients,
          onSelect: (patient) => _startConversation(patient),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر تحميل قائمة المرضى')),
        );
      }
    }
  }

  Future<void> _startConversation(Map patient) async {
    final patientId = jsonInt(patient['id']);
    final name = patient['full_name'] as String? ?? 'مريض';
    if (patientId == null) return;

    // Send a placeholder message to create conversation, or just open chat with partnerId
    // Check if conversation already exists
    final existing = _convs.cast<Map>().where((c) =>
      jsonInt(c['patient_id']) == patientId
    ).firstOrNull;

    if (existing != null) {
      if (!mounted) return;
      context.push('/messages/${existing['id']}', extra: {'name': name, 'partnerId': patientId});
    } else {
      // Navigate to chat — the conversation will be created on first message
      if (!mounted) return;
      context.push('/messages/new', extra: {'name': name, 'partnerId': patientId});
    }
  }

  Widget _empty() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(width: 90, height: 90,
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.06), shape: BoxShape.circle),
      child: const Icon(Icons.chat_bubble_outline_rounded, size: 44, color: AppColors.primary)),
    const SizedBox(height: 16),
    Text(S.noConversations, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
    const SizedBox(height: 6),
    Text(S.conversationsHint, style: const TextStyle(color: AppColors.textHint, fontSize: 13)),
    const SizedBox(height: 24),
  ]));
}

class _PatientPickerSheet extends StatelessWidget {
  final List patients;
  final void Function(Map) onSelect;
  const _PatientPickerSheet({required this.patients, required this.onSelect});

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: 0.6,
    minChildSize: 0.4,
    maxChildSize: 0.9,
    expand: false,
    builder: (_, ctrl) => Column(children: [
      Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 40, height: 4,
        decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(S.selectPatient, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ),
      ),
      Expanded(
        child: ListView.separated(
          controller: ctrl,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: patients.length,
          separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borderLight),
          itemBuilder: (_, i) {
            final p = patients[i] as Map;
            final name = p['full_name'] as String? ?? 'مريض';
            return ListTile(
              leading: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accent.withOpacity(0.8), AppColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: Text(
                  name.isNotEmpty ? name[0] : '؟',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                )),
              ),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.arrow_back_ios_rounded, size: 16, color: AppColors.textHint),
              onTap: () {
                Navigator.pop(context);
                onSelect(p);
              },
            );
          },
        ),
      ),
    ]),
  );
}
