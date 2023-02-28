// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyB1LHiqutNNnmIz0G4uEX4RKYR9xTxRpcY',
    appId: '1:661948264508:web:b8320231b46300fd13d339',
    messagingSenderId: '661948264508',
    projectId: 'tfg-project-a9320',
    authDomain: 'tfg-project-a9320.firebaseapp.com',
    storageBucket: 'tfg-project-a9320.appspot.com',
    measurementId: 'G-KKQYR52RWY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBWmoY-NSnZQd1VKefbDKh4O_EcOkET63c',
    appId: '1:661948264508:android:47f2d210ab908a8213d339',
    messagingSenderId: '661948264508',
    projectId: 'tfg-project-a9320',
    storageBucket: 'tfg-project-a9320.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAxMg3FQf_6joXmw7xV8merxvpic3V0ibI',
    appId: '1:661948264508:ios:904fd7761e008f0f13d339',
    messagingSenderId: '661948264508',
    projectId: 'tfg-project-a9320',
    storageBucket: 'tfg-project-a9320.appspot.com',
    iosClientId: '661948264508-jf4jqv4g08oa7a7asublinmngiss0qv8.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterApplication',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAxMg3FQf_6joXmw7xV8merxvpic3V0ibI',
    appId: '1:661948264508:ios:904fd7761e008f0f13d339',
    messagingSenderId: '661948264508',
    projectId: 'tfg-project-a9320',
    storageBucket: 'tfg-project-a9320.appspot.com',
    iosClientId: '661948264508-jf4jqv4g08oa7a7asublinmngiss0qv8.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterApplication',
  );
}