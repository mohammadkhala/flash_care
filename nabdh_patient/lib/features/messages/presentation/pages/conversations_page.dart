import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/json_utils.dart';
import '../../../../core/l10n/s.dart';

String _resolveUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  return url.replaceAll('localhost', '192.168.1.10')
            .replaceAll('127.0.0.1', '192.168.1.10');
}

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  List<Map<String, dynamic>> _convos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get('/messages/conversations');
      if (!mounted) return;
      final list = ((res.data['data'] ?? res.data) as List?) ?? [];
      setState(() {
        _convos = list.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startNewConversation() async {
    // Load approved therapists to pick from
    try {
      final res = await ApiClient.instance.get('/therapists', queryParameters: {'per_page': 30});
      if (!mounted) return;
      final list = ((res.data['data'] ?? res.data) as List?)?.cast<Map<String, dynamic>>() ?? [];
      if (!mounted) return;
      if (list.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يوجد أخصائيون متاحون')));
        return;
      }
      final picked = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => _TherapistPickerSheet(therapists: list),
      );
      if (picked != null && mounted) {
        context.push('/messages/new', extra: {
          'partnerId': picked['id'],
          'name': picked['full_name'],
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر تحميل الأخصائيين')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: Text(S.messages)),
    floatingActionButton: FloatingActionButton(
      onPressed: _startNewConversation,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      child: const Icon(Icons.edit_rounded),
    ),
    body: _loading
      ? const Center(child: CircularProgressIndicator())
      : RefreshIndicator(
          onRefresh: _load,
          child: _convos.isEmpty
            ? ListView(children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.chat_bubble_outline_rounded,
                      size: 64, color: AppColors.textHint),
                    const SizedBox(height: 12),
                    Text(S.noConversations,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                  ])),
                ),
              ])
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _convos.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 80),
                itemBuilder: (_, i) => _ConvoTile(convo: _convos[i]),
              ),
        ),
  );
}

class _ConvoTile extends StatelessWidget {
  final Map<String, dynamic> convo;
  const _ConvoTile({required this.convo});

  @override
  Widget build(BuildContext context) {
    final therapist = (convo['therapist'] as Map<String, dynamic>?) ?? {};
    final lastMsg = (convo['last_message'] as Map<String, dynamic>?) ?? {};
    final avatar = _resolveUrl(therapist['avatar'] as String?);
    final unread = jsonInt(convo['patient_unread']);
    final lastContent = lastMsg['content'] as String? ?? '';
    final lastTime = lastMsg['created_at'] as String?;
    String? formattedTime;
    if (lastTime != null) {
      try {
        final dt = DateTime.parse(lastTime).toLocal();
        final now = DateTime.now();
        if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
          formattedTime = DateFormat('HH:mm').format(dt);
        } else {
          formattedTime = DateFormat('d/M').format(dt);
        }
      } catch (_) {}
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      onTap: () => context.push('/messages/${convo['id']}', extra: {
        'name': therapist['full_name'],
        'partnerId': convo['therapist_id'],
      }),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: AppColors.surfaceAlt,
        backgroundImage: avatar.isNotEmpty ? CachedNetworkImageProvider(avatar) : null,
        child: avatar.isEmpty ? const Icon(Icons.person, size: 26, color: AppColors.textHint) : null,
      ),
      title: Text(therapist['full_name'] as String? ?? 'أخصائي',
        style: TextStyle(
          fontWeight: unread > 0 ? FontWeight.w800 : FontWeight.w600,
          fontSize: 15, color: AppColors.textPrimary)),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(therapist['title'] as String? ?? '',
          style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
        if (lastContent.isNotEmpty) Text(lastContent,
          style: TextStyle(
            fontSize: 13,
            color: unread > 0 ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400),
          maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (formattedTime != null) Text(formattedTime,
            style: TextStyle(
              fontSize: 11,
              color: unread > 0 ? AppColors.primary : AppColors.textHint)),
          const SizedBox(height: 4),
          if (unread > 0) Container(
            width: 20, height: 20,
            decoration: const BoxDecoration(
              color: AppColors.primary, shape: BoxShape.circle),
            child: Center(child: Text('$unread',
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))),
          ),
        ],
      ),
    );
  }
}

// ── Therapist picker bottom sheet ────────────────────────────────────────────
class _TherapistPickerSheet extends StatelessWidget {
  final List<Map<String, dynamic>> therapists;
  const _TherapistPickerSheet({required this.therapists});

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: 0.6,
    minChildSize: 0.4,
    maxChildSize: 0.9,
    expand: false,
    builder: (_, ctrl) => Column(children: [
      const SizedBox(height: 12),
      Container(
        width: 40, height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 12),
      const Text('اختر أخصائياً',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Expanded(
        child: ListView.separated(
          controller: ctrl,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: therapists.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
          itemBuilder: (_, i) {
            final t = therapists[i];
            final avatar = _resolveUrl(t['avatar'] as String?);
            return ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.surfaceAlt,
                backgroundImage: avatar.isNotEmpty
                    ? CachedNetworkImageProvider(avatar) : null,
                child: avatar.isEmpty
                    ? const Icon(Icons.person, color: AppColors.textHint) : null,
              ),
              title: Text(t['full_name'] as String? ?? '—',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              subtitle: Text(t['title'] as String? ?? '',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              onTap: () => Navigator.pop(context, t),
            );
          },
        ),
      ),
    ]),
  );
}
