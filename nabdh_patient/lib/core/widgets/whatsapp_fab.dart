import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_settings_service.dart';

class WhatsAppFab extends StatelessWidget {
  const WhatsAppFab({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = AppSettingsService.instance;
    if (!svc.hasWhatsapp) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FloatingActionButton.small(
        heroTag: 'whatsapp_fab',
        backgroundColor: const Color(0xFF25D366),
        tooltip: 'تواصل معنا عبر واتساب',
        onPressed: () => _openWhatsApp(svc.whatsappNumber, svc.whatsappMessage),
        child: const Icon(Icons.chat_rounded, color: Colors.white, size: 22),
      ),
    );
  }

  Future<void> _openWhatsApp(String number, String message) async {
    // Strip non-digits except leading +
    final cleaned = number.replaceAll(RegExp(r'[\s\-()]'), '');
    final encoded = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/$cleaned?text=$encoded');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch WhatsApp');
    }
  }
}
