import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_theme.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    // Reset badge after viewing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.forceRefresh();
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get('/notifications');
      setState(() {
        _notifications = res.data is List ? res.data : (res.data['data'] ?? []);
        _loading = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _markAll() async {
    try {
      await ApiClient.instance.post('/notifications/read-all');
      _load();
    } catch (_) {}
  }

  Future<void> _markOne(String id) async {
    try {
      await ApiClient.instance.post('/notifications/$id/read');
      _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: const Text('الإشعارات'),
      actions: [
        if (_notifications.any((n) => n['read_at'] == null))
          TextButton(
            onPressed: _markAll,
            child: const Text('قراءة الكل', style: TextStyle(color: AppColors.primary)),
          ),
      ],
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _notifications.isEmpty
            ? _empty()
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final n = _notifications[i] as Map;
                    final isRead = n['read_at'] != null;
                    return ListTile(
                      tileColor: isRead ? null : AppColors.primary.withOpacity(0.05),
                      leading: CircleAvatar(
                        backgroundColor: _typeColor(n['type'] as String?).withOpacity(0.12),
                        child: Icon(_typeIcon(n['type'] as String?),
                            color: _typeColor(n['type'] as String?), size: 22),
                      ),
                      title: Text(n['title'] as String? ?? '',
                          style: TextStyle(fontWeight: isRead ? FontWeight.w400 : FontWeight.w700, fontSize: 14)),
                      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if ((n['body'] as String? ?? '').isNotEmpty)
                          Text(n['body'] as String, style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(_timeAgo(n['created_at'] as String? ?? ''),
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ]),
                      trailing: isRead ? null : Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      ),
                      onTap: isRead ? null : () => _markOne(n['id'] as String),
                    );
                  },
                ),
              ),
  );

  IconData _typeIcon(String? type) {
    switch (type) {
      case 'appointment': return Icons.calendar_today;
      case 'message':     return Icons.chat;
      case 'system':      return Icons.info_outline;
      default:            return Icons.notifications_outlined;
    }
  }

  Color _typeColor(String? type) {
    switch (type) {
      case 'appointment': return AppColors.primary;
      case 'message':     return AppColors.accent;
      case 'system':      return AppColors.warning;
      default:            return AppColors.textSecondary;
    }
  }

  String _timeAgo(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }

  Widget _empty() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.notifications_none_outlined, size: 64, color: AppColors.border),
    const SizedBox(height: 16),
    const Text('لا توجد إشعارات', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
  ]));
}
