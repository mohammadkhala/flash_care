import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const kAcceptCall = 'accept_call';
const kRejectCall = 'reject_call';

const therapistAppChannelId   = 'nabdh_therapist_channel';
const therapistAppChannelName = 'إشعارات نبض';

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
      therapistAppChannelId,
      therapistAppChannelName,
      description: 'إشعارات تطبيق نبض للأخصائي',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    ));

    await android.createNotificationChannel(const AndroidNotificationChannel(
      callChannelId,
      callChannelName,
      description: 'إشعارات المكالمات الواردة',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    ));
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
        ),
      );

  static const NotificationDetails callDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      callChannelId,
      callChannelName,
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.call,
      visibility: NotificationVisibility.public,
      ongoing: true,
      autoCancel: false,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      actions: [
        AndroidNotificationAction(
          kRejectCall,
          'رفض',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          kAcceptCall,
          'قبول',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    ),
  );
}
