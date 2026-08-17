import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../core/theme/app_theme.dart';

class OtpPage extends StatefulWidget {
  final String phone; // format: "+970 599123456"
  const OtpPage({required this.phone, super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  int _resendTimer = AppConstants.otpResendSeconds;
  Timer? _timer;

  late final String _countryCode;
  late final String _phoneNumber;

  @override
  void initState() {
    super.initState();
    final parts = widget.phone.split(' ');
    _countryCode = parts[0];
    _phoneNumber = parts[1];
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNodes[0].requestFocus());
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendTimer == 0) {
        t.cancel();
      } else {
        setState(() => _resendTimer--);
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otp.length < 6) return;
    setState(() => _isLoading = true);

    try {
      final res = await ApiClient.instance.post('/auth/verify-otp', data: {
        'phone': _phoneNumber,
        'phone_country_code': _countryCode,
        'otp': _otp,
      });

      final token = res.data['token'];
      await ApiClient.setToken(token);
      unawaited(FcmService.instance.refreshToken());

      if (!mounted) return;

      if (res.data['needs_password'] == true) {
        context.go('/auth/set-password', extra: {
          'needsProfile': res.data['needs_profile'] ?? true,
          'isApproved':   res.data['is_approved'] ?? true,
        });
      } else if (res.data['needs_profile'] == true) {
        context.go('/auth/setup');
      } else if (res.data['is_approved'] == false) {
        _showPendingApprovalDialog();
      } else {
        context.go('/home');
      }
    } catch (e) {
      _showError('رمز التحقق غير صحيح');
      for (final c in _controllers) c.clear();
      _focusNodes[0].requestFocus();
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

  void _showPendingApprovalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('قيد المراجعة', textAlign: TextAlign.center),
        content: const Text(
          'تم استلام طلبك بنجاح!\nسيتم مراجعة ملفك الشخصي والتحقق من بياناتك في أقرب وقت.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => context.go('/auth/phone'),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  Future<void> _resend() async {
    if (_resendTimer > 0) return;
    setState(() => _resendTimer = AppConstants.otpResendSeconds);
    _startTimer();

    await ApiClient.instance.post('/auth/send-otp', data: {
      'phone': _phoneNumber,
      'phone_country_code': _countryCode,
      'type': 'therapist',
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: () => context.go('/auth/register'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Text('التحقق من الهاتف', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(
              'أدخل الرمز المرسل إلى\n$_countryCode $_phoneNumber عبر واتساب',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // OTP fields
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: SizedBox(
                    width: 48, height: 56,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty && i < 5) {
                          _focusNodes[i + 1].requestFocus();
                        } else if (val.isEmpty && i > 0) {
                          _focusNodes[i - 1].requestFocus();
                        }
                        if (_otp.length == 6) _verify();
                      },
                    ),
                  ),
                )),
              ),
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading || _otp.length < 6 ? null : _verify,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('تحقق'),
            ),

            const SizedBox(height: 24),
            TextButton(
              onPressed: _resendTimer == 0 ? _resend : null,
              child: Text(
                _resendTimer > 0 ? 'إعادة الإرسال بعد $_resendTimer ث' : 'إعادة إرسال الرمز',
                style: TextStyle(
                  color: _resendTimer == 0 ? AppColors.primary : AppColors.textSecondary,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
