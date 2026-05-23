import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBtR5Lg303aZzJFv3h9L3zYHw8SGPYB_a4',
    appId: '1:254914817750:web:c61c65807a0411f3bda377',
    messagingSenderId: '254914817750',
    projectId: 'doctorio-4de05',
    authDomain: 'doctorio-4de05.firebaseapp.com',
    storageBucket: 'doctorio-4de05.firebasestorage.app',
    measurementId: 'G-5T2MPWB5HP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBtR5Lg303aZzJFv3h9L3zYHw8SGPYB_a4',
    appId: '1:254914817750:web:c61c65807a0411f3bda377',
    messagingSenderId: '254914817750',
    projectId: 'doctorio-4de05',
    storageBucket: 'doctorio-4de05.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBtR5Lg303aZzJFv3h9L3zYHw8SGPYB_a4',
    appId: '1:254914817750:web:c61c65807a0411f3bda377',
    messagingSenderId: '254914817750',
    projectId: 'doctorio-4de05',
    storageBucket: 'doctorio-4de05.firebasestorage.app',
    iosBundleId: 'com.doctorio.doctor',
  );
}
