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
    apiKey: 'AIzaSyATmQwvTbYD4Y_llB9uojbJ8EviqgK5iR8',
    appId: '1:391014440478:web:03feb9b8a3607addca580f',
    messagingSenderId: '391014440478',
    projectId: 'festivalens-da46f',
    authDomain: 'festivalens-da46f.firebaseapp.com',
    storageBucket: 'festivalens-da46f.appspot.com',
    measurementId: 'G-85NK8LT7RQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC_sJBYx7psiloOXMptauub5dnAV72nelg',
    appId: '1:391014440478:android:304c9958179ba84fca580f',
    messagingSenderId: '391014440478',
    projectId: 'festivalens-da46f',
    storageBucket: 'festivalens-da46f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDRl4BQhHKJEIdi74MuqMVXINW_K_3mirc',
    appId: '1:391014440478:ios:27b6435f3c0c2b0fca580f',
    messagingSenderId: '391014440478',
    projectId: 'festivalens-da46f',
    storageBucket: 'festivalens-da46f.appspot.com',
    iosBundleId: 'com.example.festivalens',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDRl4BQhHKJEIdi74MuqMVXINW_K_3mirc',
    appId: '1:391014440478:ios:27b6435f3c0c2b0fca580f',
    messagingSenderId: '391014440478',
    projectId: 'festivalens-da46f',
    storageBucket: 'festivalens-da46f.appspot.com',
    iosBundleId: 'com.example.festivalens',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyATmQwvTbYD4Y_llB9uojbJ8EviqgK5iR8',
    appId: '1:391014440478:web:e0a2b8b4209489d4ca580f',
    messagingSenderId: '391014440478',
    projectId: 'festivalens-da46f',
    authDomain: 'festivalens-da46f.firebaseapp.com',
    storageBucket: 'festivalens-da46f.appspot.com',
    measurementId: 'G-FBSW8FK8X4',
  );

}