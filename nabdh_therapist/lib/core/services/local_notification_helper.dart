import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const therapistAppChannelId   = 'nabdh_therapist_channel';
const therapistAppChannelName = 'إشعارات نبض';

/// Shared channel + notification details for FCM background isolate and foreground.
/// Incoming calls ring through flutter_callkit_incoming, not these channels.
class LocalNotificationHelper {
  LocalNotificationHelper._();

  /// Old tap-to-answer call channel; removed so it no longer shows in settings.
  static const _legacyCallChannelId = 'call_channel';

  static Future<void> ensureAndroidChannels(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    final android = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    await android.createNotificationChannel(const AndroidNotificationChannel(
      therapistAppChannelId,
      therapistAppChannelName,
      description: 'إشعارات تطبيق نبض للأخصائي',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    ));

    try {
      await android.deleteNotificationChannel(_legacyCallChannelId);
    } catch (_) {}
  }

  static NotificationDetails generalDetails() => const NotificationDetails(
        android: AndroidNotificationDetails(
          therapistAppChannelId,
          therapistAppChannelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
          autoCancel: true,
        ),
      );
}
