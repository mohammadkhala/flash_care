import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

class SetPasswordPage extends StatefulWidget {
  final bool needsProfile;
  final bool isApproved;
  const SetPasswordPage({required this.needsProfile, required this.isApproved, super.key});

  @override
  State<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();
  bool _isLoading           = false;
  bool _obscure1            = true;
  bool _obscure2            = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final pass    = _passwordController.text;
    final confirm = _confirmController.text;

    if (pass.length < 6) { _showError('كلمة المرور يجب أن تكون 6 أحرف على الأقل'); return; }
    if (pass != confirm)  { _showError('كلمتا المرور غير متطابقتان'); return; }

    setState(() => _isLoading = true);
    try {
      await ApiClient.instance.post('/auth/set-password', data: {
        'password':              pass,
        'password_confirmation': confirm,
      });

      if (!mounted) return;

      if (widget.needsProfile) {
        context.go('/auth/setup');
      } else if (!widget.isApproved) {
        _showPendingDialog();
      } else {
        context.go('/home');
      }
    } catch (e) {
      _showError('حدث خطأ. حاول مجدداً.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.error,
    ));
  }

  void _showPendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('قيد المراجعة', textAlign: TextAlign.center),
        content: const Text(
          'تم استلام طلبك بنجاح!\nسيتم مراجعة ملفك الشخصي في أقرب وقت.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(onPressed: () => context.go('/auth'), child: const Text('حسناً')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Icon
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.lock_outline, color: AppColors.primary, size: 32),
              ),

              const SizedBox(height: 24),
              Text('تعيين كلمة المرور', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'ستستخدم كلمة المرور لتسجيل الدخول في المستقبل',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 36),

              // Password
              Text('كلمة المرور', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscure1,
                decoration: InputDecoration(
                  hintText: '6 أحرف على الأقل',
                  suffixIcon: IconButton(
                    icon: Icon(_obscure1 ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Confirm
              Text('تأكيد كلمة المرور', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmController,
                obscureText: _obscure2,
                decoration: InputDecoration(
                  hintText: 'أعد إدخال كلمة المرور',
                  suffixIcon: IconButton(
                    icon: Icon(_obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('حفظ والمتابعة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
