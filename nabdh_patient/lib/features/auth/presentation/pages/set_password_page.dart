import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

class SetPasswordPage extends StatefulWidget {
  final bool needsProfile;
  const SetPasswordPage({this.needsProfile = true, super.key});

  @override
  State<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading      = false;
  bool _obscure1     = true;
  bool _obscure2     = true;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final pass    = _passCtrl.text;
    final confirm = _confirmCtrl.text;
    if (pass.length < 6) { _err('كلمة المرور يجب أن تكون 6 أحرف على الأقل'); return; }
    if (pass != confirm)  { _err('كلمتا المرور غير متطابقتان'); return; }

    setState(() => _loading = true);
    try {
      await ApiClient.instance.post('/auth/set-password', data: {
        'password':              pass,
        'password_confirmation': confirm,
      });
      if (!mounted) return;
      if (widget.needsProfile) {
        context.go('/auth/setup');
      } else {
        context.go('/home');
      }
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?
          ?? 'حدث خطأ. حاول مجدداً.';
      _err(msg);
    } catch (e) {
      _err('حدث خطأ غير متوقع');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _err(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.error));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ── Icon ─────────────────────────────────────────────────
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: const Color(0x1F1B2E6E),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    color: AppColors.primary, size: 32),
              ),
              const SizedBox(height: 24),

              Text('إنشاء كلمة المرور',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'ستستخدمها لتسجيل الدخول في المرات القادمة',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              // ── Password ──────────────────────────────────────────────
              const _Label('كلمة المرور'),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure1,
                decoration: InputDecoration(
                  hintText: '6 أحرف على الأقل',
                  suffixIcon: IconButton(
                    icon: Icon(_obscure1
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Confirm ───────────────────────────────────────────────
              const _Label('تأكيد كلمة المرور'),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmCtrl,
                obscureText: _obscure2,
                onSubmitted: (_) => _save(),
                decoration: InputDecoration(
                  hintText: 'أعد إدخال كلمة المرور',
                  suffixIcon: IconButton(
                    icon: Icon(_obscure2
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('حفظ والمتابعة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            fontFamily: 'Cairo',
            color: AppColors.textPrimary),
      );
}
