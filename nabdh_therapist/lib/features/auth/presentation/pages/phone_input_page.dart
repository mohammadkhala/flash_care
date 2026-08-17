import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/country_code_picker.dart';

class PhoneInputPage extends StatefulWidget {
  const PhoneInputPage({super.key});

  @override
  State<PhoneInputPage> createState() => _PhoneInputPageState();
}

class _PhoneInputPageState extends State<PhoneInputPage> {
  final _phoneController = TextEditingController();
  String _selectedCode = AppConstants.defaultCountryCode;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 9) {
      _showError('أدخل رقم هاتف صحيح');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiClient.instance.post('/auth/send-otp', data: {
        'phone': phone,
        'phone_country_code': _selectedCode,
        'type': 'therapist',
      });

      if (mounted) {
        context.push('/auth/otp', extra: '$_selectedCode $phone');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422 &&
          e.response?.data['already_registered'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('هذا الرقم مسجّل مسبقاً — سيتم توجيهك لتسجيل الدخول'),
            backgroundColor: Colors.orange,
          ));
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) context.go('/auth/login');
        }
      } else {
        _showError(e.response?.data['message'] ?? 'حدث خطأ، حاول مجدداً');
      }
    } catch (e) {
      _showError('حدث خطأ، حاول مجدداً');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, textDirection: TextDirection.rtl),
      backgroundColor: AppColors.error,
    ));
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
              const SizedBox(height: 40),
              // Logo
              Center(
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Text('نبض', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text('إنشاء حساب جديد', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('أدخل رقم هاتفك لاستلام رمز التحقق عبر واتساب', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 32),

              // Phone input
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    // Country code picker
                    GestureDetector(
                      onTap: _showCodePicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: const BoxDecoration(
                          border: Border(right: BorderSide(color: AppColors.border)),
                        ),
                        child: Row(
                          children: [
                            Text(_selectedCode, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, size: 20, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(fontSize: 16, fontFamily: 'Cairo'),
                        decoration: const InputDecoration(
                          hintText: '5XXXXXXXX',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          hintStyle: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendOtp,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('إرسال رمز التحقق'),
              ),

              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/auth/login'),
                  child: const Text('لديك حساب بالفعل؟ تسجيل الدخول'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCodePicker() async {
    final picked = await showCountryCodePicker(context, selected: _selectedCode);
    if (picked != null && mounted) setState(() => _selectedCode = picked);
  }
}
