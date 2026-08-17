import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/json_utils.dart';
import '../../../../core/l10n/s.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    NotificationService.instance.forceRefresh();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get('/notifications');
      if (!mounted) return;
      final list = ((res.data['data'] ?? res.data) as List?) ?? [];
      setState(() {
        _notifications = list.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAll() async {
    try {
      await ApiClient.instance.post('/notifications/read-all');
      if (!mounted) return;
      setState(() {
        for (final n in _notifications) n['read_at'] = DateTime.now().toIso8601String();
      });
      NotificationService.instance.forceRefresh();
    } catch (_) {}
  }

  Future<void> _markOne(int id, int index) async {
    if (_notifications[index]['read_at'] != null) return;
    try {
      await ApiClient.instance.post('/notifications/$id/read');
      if (!mounted) return;
      setState(() => _notifications[index]['read_at'] = DateTime.now().toIso8601String());
      NotificationService.instance.forceRefresh();
    } catch (_) {}
  }

  Future<void> _deleteOne(int id, int index) async {
    // Drop it locally first so the swipe feels instant; restore on failure.
    final removed = _notifications[index];
    setState(() => _notifications.removeAt(index));
    try {
      await ApiClient.instance.delete('/notifications/$id');
      NotificationService.instance.forceRefresh();
    } catch (_) {
      if (mounted) {
        setState(() => _notifications.insert(index, removed));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر حذف الإشعار')));
      }
    }
  }

  Future<void> _clearRead() async {
    final readCount = _notifications.where((n) => n['read_at'] != null).length;
    if (readCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد إشعارات مقروءة لحذفها')));
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الإشعارات المقروءة'),
        content: Text('سيتم حذف $readCount إشعاراً مقروءاً.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiClient.instance.delete('/notifications/read');
      await _load();
      NotificationService.instance.forceRefresh();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر حذف الإشعارات')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: Text(S.notifications),
      actions: [
        if (_notifications.any((n) => n['read_at'] == null))
          TextButton(
            onPressed: _markAll,
            child: Text(S.markAllRead,
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
        if (_notifications.any((n) => n['read_at'] != null))
          IconButton(
            onPressed: _clearRead,
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'حذف المقروءة',
          ),
      ],
    ),
    body: _loading
      ? const Center(child: CircularProgressIndicator())
      : RefreshIndicator(
          onRefresh: _load,
          child: _notifications.isEmpty
            ? ListView(children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.textHint),
                    const SizedBox(height: 12),
                    Text(S.noNotifications,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                  ])),
                ),
              ])
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _notifications.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 70),
                itemBuilder: (_, i) {
                  final n = _notifications[i];
                  final isRead = n['read_at'] != null;
                  final type = n['type'] as String? ?? '';
                  final createdAt = n['created_at'] as String?;
                  String? timeStr;
                  if (createdAt != null) {
                    try {
                      final dt = DateTime.parse(createdAt).toLocal();
                      final now = DateTime.now();
                      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
                        timeStr = DateFormat('HH:mm').format(dt);
                      } else {
                        timeStr = DateFormat('d MMM', 'ar').format(dt);
                      }
                    } catch (_) {}
                  }
                  return Dismissible(
                    key: ValueKey(n['id']),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _deleteOne(jsonInt(n['id']), i),
                    background: Container(
                      color: AppColors.error,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete_outline, color: Colors.white),
                    ),
                    child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    onTap: () {
                      _markOne(jsonInt(n['id']), i);
                      // Navigate to the relevant content
                      final dataField = n['data'];
                      final dataMap = dataField is Map
                          ? dataField.cast<String, dynamic>()
                          : <String, dynamic>{};
                      final payload = NotificationService.buildPayloadFromData(dataMap);
                      if (payload != null && !payload.startsWith('call:')) {
                        final route = NotificationService.payloadToRoute(payload);
                        if (route != '/notifications') {
                          context.push(route);
                        }
                      }
                    },
                    tileColor: isRead ? null : AppColors.primary.withOpacity(0.03),
                    leading: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: _typeColor(type).withOpacity(0.1),
                        shape: BoxShape.circle),
                      child: Icon(_typeIcon(type), color: _typeColor(type), size: 22),
                    ),
                    title: Text(n['title'] as String? ?? '',
                      style: TextStyle(
                        fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                        fontSize: 14, color: AppColors.textPrimary)),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const SizedBox(height: 2),
                      Text(n['body'] as String? ?? '',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                      if (timeStr != null) ...[
                        const SizedBox(height: 4),
                        Text(timeStr, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                      ],
                    ]),
                    trailing: isRead ? null : Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle)),
                    ),
                  );
                },
              ),
        ),
  );

  IconData _typeIcon(String type) {
    switch (type) {
      case 'appointment': return Icons.calendar_today_rounded;
      case 'message': return Icons.chat_rounded;
      case 'program': return Icons.fitness_center_rounded;
      case 'review': return Icons.star_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'appointment': return AppColors.primary;
      case 'message': return AppColors.accent;
      case 'program': return AppColors.success;
      case 'review': return AppColors.warning;
      default: return AppColors.purple;
    }
  }
}
