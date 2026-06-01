import 'dart:async';
import '../network/api_client.dart';

/// Fetches and caches public app settings from the backend.
/// Call [init()] once at app start; settings are refreshed every 10 minutes.
class AppSettingsService {
  AppSettingsService._();
  static final AppSettingsService instance = AppSettingsService._();

  Map<String, dynamic> _data = {};
  Timer? _refreshTimer;

  // ── Getters ────────────────────────────────────────────────────────────────

  String get whatsappNumber => _data['whatsapp_support'] as String? ?? '';
  String get whatsappMessage => _data['whatsapp_message'] as String? ?? 'مرحباً، أحتاج مساعدة';
  bool   get maintenanceMode => _data['maintenance_mode'] == true;
  String get maintenanceMessage => _data['maintenance_message'] as String? ?? '';
  bool   get announcementActive => _data['announcement_active'] == true;
  String get announcementText   => _data['announcement_text']   as String? ?? '';

  bool get hasWhatsapp => whatsappNumber.isNotEmpty;

  // ── Init ───────────────────────────────────────────────────────────────────

  Future<void> init() async {
    await _fetch();
    _refreshTimer = Timer.periodic(const Duration(minutes: 10), (_) => _fetch());
  }

  Future<void> _fetch() async {
    try {
      final res = await ApiClient.instance.get('/app-settings');
      if (res.data is Map) {
        _data = Map<String, dynamic>.from(res.data as Map);
      }
    } catch (_) {}
  }

  void dispose() {
    _refreshTimer?.cancel();
  }
}
