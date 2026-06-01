import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/json_utils.dart';

String _resolveUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  return url.replaceAll('localhost', '192.168.1.3')
            .replaceAll('127.0.0.1', '192.168.1.3');
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _user;
  bool _loading = true;
  int? _mood; // 1-5
  int _appointmentsCount = 0;
  int _programsCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
    _loadMood();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final futures = await Future.wait([
        ApiClient.instance.get('/me'),
        ApiClient.instance.get('/patient/appointments', queryParameters: {'per_page': 1}),
        ApiClient.instance.get('/patient/home-programs'),
      ]);
      if (!mounted) return;
      setState(() {
        _user = (futures[0].data['user'] as Map<String, dynamic>?);
        final apptMeta = futures[1].data['meta'] as Map?;
        _appointmentsCount = jsonInt(apptMeta?['total']);
        final programs = (futures[2].data as List?) ?? [];
        _programsCount = programs.length;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMood() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _mood = prefs.getInt('mood_today'));
  }

  Future<void> _saveMood(int v) async {
    setState(() => _mood = v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('mood_today', v);
  }

  Future<void> _deleteAccount() async {
    // Step 1: confirm intent
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الحساب نهائياً'),
        content: const Text(
          'سيتم حذف جميع بياناتك ومواعيدك بشكل نهائي ولا يمكن التراجع.\n\nهل أنت متأكد؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('نعم، احذف حسابي')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    // Step 2: ask for password
    final passCtrl = TextEditingController();
    final passwordOk = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد كلمة المرور'),
        content: TextField(
          controller: passCtrl,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'كلمة المرور',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('تأكيد الحذف',
              style: TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (passwordOk != true || !mounted) return;

    // Step 3: call API
    try {
      await ApiClient.instance.delete('/account', data: {'password': passCtrl.text});
      await ApiClient.clearToken();
      if (!mounted) return;
      context.go('/auth');
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?
          ?? 'كلمة المرور غير صحيحة';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ، حاول مجدداً')));
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('خروج')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ApiClient.instance.post('/auth/logout');
    } catch (_) {}
    await ApiClient.clearToken();
    if (!mounted) return;
    context.go('/auth');
  }

  Map<String, dynamic> get _patient =>
    (_user?['patient'] as Map<String, dynamic>?) ?? {};

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final avatar = _resolveUrl(_patient['avatar'] as String?);
    final phone = (_user?['phone_country_code'] as String? ?? '') +
      ' ' + (_user?['phone'] as String? ?? '');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text('ملفي الشخصي'),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: AppGradients.primary),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(height: 56),
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white24,
                  backgroundImage: avatar.isNotEmpty ? CachedNetworkImageProvider(avatar) : null,
                  child: avatar.isEmpty ? const Icon(Icons.person, size: 44, color: Colors.white) : null,
                ),
                const SizedBox(height: 10),
                Text(_patient['full_name'] as String? ?? 'مستخدم',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(phone, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
              ]),
            ),
          ),
        ),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // Stats
            Row(children: [
              Expanded(child: _StatCard(
                icon: Icons.calendar_month_rounded,
                label: 'الجلسات',
                value: '$_appointmentsCount',
                color: AppColors.primary,
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                icon: Icons.fitness_center_rounded,
                label: 'البرامج',
                value: '$_programsCount',
                color: AppColors.accent,
              )),
            ]),
            const SizedBox(height: 20),
            // Mood
            _MoodTracker(mood: _mood, onSelect: _saveMood),
            const SizedBox(height: 20),
            // Quick links
            _LinkTile(
              icon: Icons.fitness_center_rounded,
              label: 'برامجي',
              color: AppColors.accent,
              onTap: () => context.push('/programs'),
            ),
            _LinkTile(
              icon: Icons.folder_copy_outlined,
              label: 'وثائقي الطبية',
              color: AppColors.purple,
              onTap: () => context.push('/documents'),
            ),
            _LinkTile(
              icon: Icons.notifications_outlined,
              label: 'الإشعارات',
              color: AppColors.accent,
              onTap: () => context.push('/notifications'),
            ),
            _LinkTile(
              icon: Icons.star_outline_rounded,
              label: 'قيّم التطبيق',
              color: AppColors.warning,
              onTap: () {},
            ),
            const SizedBox(height: 20),
            // Logout
            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('تسجيل الخروج'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 10),
            // Delete account
            TextButton(
              onPressed: _deleteAccount,
              child: const Text('حذف الحساب نهائياً',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                )),
            ),
            const SizedBox(height: 20),
          ]),
        )),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label,
    required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Row(children: [
      Icon(icon, color: color, size: 28),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ]),
    ]),
  );
}

class _MoodTracker extends StatelessWidget {
  final int? mood;
  final ValueChanged<int> onSelect;
  const _MoodTracker({required this.mood, required this.onSelect});

  static const _emojis = ['😢', '😟', '😐', '🙂', '😄'];
  static const _labels = ['سيء', 'حزين', 'عادي', 'جيد', 'ممتاز'];

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('كيف حالك اليوم؟',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      const SizedBox(height: 14),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(5, (i) {
        final val = i + 1;
        final selected = mood == val;
        return GestureDetector(
          onTap: () => onSelect(val),
          child: Column(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? AppColors.primary : Colors.transparent,
                  width: 2),
              ),
              child: Center(child: Text(_emojis[i], style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(height: 4),
            Text(_labels[i], style: TextStyle(
              fontSize: 10,
              color: selected ? AppColors.primary : AppColors.textHint,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
          ]),
        );
      })),
    ]),
  );
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _LinkTile({required this.icon, required this.label,
    required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: ListTile(
      onTap: onTap,
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      trailing: const Icon(Icons.arrow_back_ios_new_rounded,
        size: 14, color: AppColors.textHint),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
