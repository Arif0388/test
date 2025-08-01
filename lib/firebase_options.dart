// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDZUOypazrejGANjwAjOiSFeN6OHTAVfJc',
    appId: '1:245320781931:web:2a39faa7a805ce28c4e12e',
    messagingSenderId: '245320781931',
    projectId: 'learningx-fcm',
    authDomain: 'learningx-fcm.firebaseapp.com',
    storageBucket: 'learningx-fcm.appspot.com',
    measurementId: 'G-KR1F9JTFXN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCJFE402ENZV2Tnfosd7IthG5axKI_ITmA',
    appId: '1:245320781931:android:3ae9e1c5feed31f9c4e12e',
    messagingSenderId: '245320781931',
    projectId: 'learningx-fcm',
    storageBucket: 'learningx-fcm.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCcDPfVh-HSo_ByRBw9u8fQWHLQvUOxA_w',
    appId: '1:245320781931:ios:6dc7bd11675d5df9c4e12e',
    messagingSenderId: '245320781931',
    projectId: 'learningx-fcm',
    storageBucket: 'learningx-fcm.appspot.com',
    iosBundleId: 'in.learningx.flutterApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCcDPfVh-HSo_ByRBw9u8fQWHLQvUOxA_w',
    appId: '1:245320781931:ios:81a65fe747e7ac4cc4e12e',
    messagingSenderId: '245320781931',
    projectId: 'learningx-fcm',
    storageBucket: 'learningx-fcm.appspot.com',
    iosBundleId: 'com.example.learningxFlutterApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDZUOypazrejGANjwAjOiSFeN6OHTAVfJc',
    appId: '1:245320781931:web:0b42a9aed43a093ac4e12e',
    messagingSenderId: '245320781931',
    projectId: 'learningx-fcm',
    authDomain: 'learningx-fcm.firebaseapp.com',
    storageBucket: 'learningx-fcm.appspot.com',
    measurementId: 'G-6JB2KBWN9Y',
  );
}