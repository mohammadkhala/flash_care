import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const kAcceptCall = 'accept_call';
const kRejectCall = 'reject_call';

const patientAppChannelId   = 'nabdh_patient_channel';
const patientAppChannelName = 'إشعارات نبض';

/// Shared channel + notification details for FCM background isolate and foreground.
class LocalNotificationHelper {
  LocalNotificationHelper._();

  static const callChannelId   = 'call_channel';
  static const callChannelName = 'مكالمات واردة';

  static Future<void> ensureAndroidChannels(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    final android = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    await android.createNotificationChannel(const AndroidNotificationChannel(
      patientAppChannelId,
      patientAppChannelName,
      description: 'إشعارات تطبيق نبض للمريض',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    ));

    await android.createNotificationChannel(const AndroidNotificationChannel(
      callChannelId,
      callChannelName,
      description: 'إشعار للمكالمات — اضغط للرد',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    ));
  }

  static NotificationDetails generalDetails() => const NotificationDetails(
        android: AndroidNotificationDetails(
          patientAppChannelId,
          patientAppChannelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
          autoCancel: true,
        ),
      );

  /// Same as a normal notification — tap opens the incoming-call screen.
  /// No full-screen intent and no looping ringtone.
  static NotificationDetails get callDetails => generalDetails();
}
