import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_settings_service.dart';

/// زر واتساب عائم (لم يعد مستخدماً — تم نقله للهيدر)
class WhatsAppFab extends StatelessWidget {
  const WhatsAppFab({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// زر واتساب في الهيدر جنب الإشعارات
class WhatsAppHeaderButton extends StatelessWidget {
  const WhatsAppHeaderButton({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = AppSettingsService.instance;
    if (!svc.hasWhatsapp) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _openWhatsApp(svc.whatsappNumber, svc.whatsappMessage),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFF25D366),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.chat_rounded, color: Colors.white, size: 18),
      ),
    );
  }

  Future<void> _openWhatsApp(String number, String message) async {
    final cleaned = number.replaceAll(RegExp(r'[\s\-()]'), '');
    final encoded = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/$cleaned?text=$encoded');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch WhatsApp');
    }
  }
}
