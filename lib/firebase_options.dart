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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDFUYO_q36J41nqcrT59D25HefCRiwCyl4',
    appId: '1:219809951072:web:cad4c415e0123f487a4205',
    messagingSenderId: '219809951072',
    projectId: 'appproject-d64e7',
    authDomain: 'appproject-d64e7.firebaseapp.com',
    storageBucket: 'appproject-d64e7.firebasestorage.app',
    measurementId: 'G-X28KMQXQR5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBWmaNN98oZDGvd_sHfTzv2gH1cd1n3RRA',
    appId: '1:219809951072:android:f1508f7804bdeb7e7a4205',
    messagingSenderId: '219809951072',
    projectId: 'appproject-d64e7',
    storageBucket: 'appproject-d64e7.firebasestorage.app',
  );
}
