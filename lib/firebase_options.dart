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
    apiKey: 'AIzaSyB529pLDoP-ixd_um4Hj60HMkeyq7lAzEo',
    appId: '1:1050606177705:web:b3a8cd81d19a3cd08008b8',
    messagingSenderId: '1050606177705',
    projectId: 'dartapp-8bc73',
    authDomain: 'dartapp-8bc73.firebaseapp.com',
    databaseURL: 'https://dartapp-8bc73-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'dartapp-8bc73.appspot.com',
    measurementId: 'G-P50F18BKMK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD5TDxWezXLCZJUbWDKjXKaG_UpnXU5AWo',
    appId: '1:1050606177705:android:81043b67e6923f3e8008b8',
    messagingSenderId: '1050606177705',
    projectId: 'dartapp-8bc73',
    databaseURL: 'https://dartapp-8bc73-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'dartapp-8bc73.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDmyFeNwLx592sVO2EZmIJKCHbVzcq7nLk',
    appId: '1:1050606177705:ios:c90ee9a874f2bd6a8008b8',
    messagingSenderId: '1050606177705',
    projectId: 'dartapp-8bc73',
    databaseURL: 'https://dartapp-8bc73-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'dartapp-8bc73.appspot.com',
    iosBundleId: 'com.example.dartApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDmyFeNwLx592sVO2EZmIJKCHbVzcq7nLk',
    appId: '1:1050606177705:ios:f1241aa631d2b2be8008b8',
    messagingSenderId: '1050606177705',
    projectId: 'dartapp-8bc73',
    databaseURL: 'https://dartapp-8bc73-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'dartapp-8bc73.appspot.com',
    iosBundleId: 'com.example.dartApp.RunnerTests',
  );
}