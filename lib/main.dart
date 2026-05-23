import 'package:doctor_flutter/firebase_options.dart';
import 'package:doctor_flutter/screen/languages_screen/languages_screen_controller.dart';
import 'package:doctor_flutter/screen/my_app/my_app.dart';
import 'package:doctor_flutter/service/firebase_notification_manager.dart';
import 'package:doctor_flutter/service/session_manager.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/data/latest.dart';

String? messageId;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  debugPrint(
      '🐦‍🔥🐦‍🔥🐦‍🔥🐦‍🔥 _firebaseMessagingBackgroundHandler ${message.toMap()}');
  FirebaseNotificationManager.shared.showNotification(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    if (!kIsWeb) {
      FirebaseNotificationManager.shared;
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
    }
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }
  await GetStorage.init('doctor');
  initializeTimeZones();
  // Force Arabic language
  LanguagesScreenController.selectedLanguage = appLanguageCode;
  SessionManager.instance.setString(key: SessionKeys.lang, value: appLanguageCode);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) {
    runApp(
      const RestartWidget(child: MyApp()),
    );
  });
}

class RestartWidget extends StatefulWidget {
  const RestartWidget({super.key, required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: key, child: widget.child);
  }
}
