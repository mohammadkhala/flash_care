import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

class PendingApprovalPage extends StatefulWidget {
  const PendingApprovalPage({super.key});

  @override
  State<PendingApprovalPage> createState() => _PendingApprovalPageState();
}

class _PendingApprovalPageState extends State<PendingApprovalPage>
    with WidgetsBindingObserver {
  Timer? _poll;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Approval happens out-of-band in the admin panel, so this page has to look
    // for it rather than wait to be told: on open, on resume, and periodically.
    _checkApproval();
    _poll = Timer.periodic(const Duration(seconds: 20), (_) => _checkApproval());
  }

  @override
  void dispose() {
    _poll?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkApproval();
  }

  /// Ask the server whether the account has been approved; leave for /home if so.
  Future<void> _checkApproval({bool manual = false}) async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      final res  = await ApiClient.instance.get('/me');
      final user = (res.data['user'] as Map?) ?? {};
      final ther = (user['therapist'] as Map?) ?? {};
      if (ther['is_approved'] == true) {
        _poll?.cancel();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('🎉 تمت الموافقة على حسابك! مرحباً بك في نبض'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ));
        context.go('/home');
        return;
      }
      if (manual && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('طلبك ما زال قيد المراجعة. سنُشعرك عند الموافقة.'),
        ));
      }
    } catch (_) {
      if (manual && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تعذّر الاتصال بالسيرفر. تحقّق من الإنترنت.'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hourglass_top_rounded, size: 56, color: AppColors.primary),
              ),
              const SizedBox(height: 32),
              Text(
                'طلبك قيد المراجعة',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'تم استلام طلب تسجيلك بنجاح.\nسيقوم فريق نبض بمراجعة ملفك الشخصي والتواصل معك خلال 24-48 ساعة.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _step(Icons.check_circle_outline, 'تم التحقق من رقم الهاتف', true),
                    _divider(),
                    _step(Icons.person_outline, 'تم رفع الملف الشخصي', true),
                    _divider(),
                    _step(Icons.admin_panel_settings_outlined, 'مراجعة الإدارة', false),
                    _divider(),
                    _step(Icons.celebration_outlined, 'تفعيل الحساب', false),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _checking ? null : () => _checkApproval(manual: true),
                  icon: _checking
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.refresh_rounded),
                  label: Text(_checking ? 'جارٍ التحقق...' : 'تحقّق من حالة الطلب'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ApiClient.clearTokenSilent();
                    if (context.mounted) context.go('/auth');
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('تسجيل الخروج'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step(IconData icon, String label, bool done) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: done ? AppColors.primary : AppColors.textSecondary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: done ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: done ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          if (done) const Icon(Icons.check, color: AppColors.primary, size: 18),
          if (!done) Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, color: AppColors.border);
}
