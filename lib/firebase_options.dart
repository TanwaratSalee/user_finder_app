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
    apiKey: 'AIzaSyC1JrOxUy0ntQV8m0OMEQkYK0WL8Xpay_M',
    appId: '1:814660141387:web:de93bf7e657fe6bff328ce',
    messagingSenderId: '814660141387',
    projectId: 'new-tung',
    authDomain: 'new-tung.firebaseapp.com',
    storageBucket: 'new-tung.appspot.com',
    measurementId: 'G-J3P7FM884X',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDgMwVRFztTKFKM-efzUm-Ea-VzMY7IS3k',
    appId: '1:814660141387:android:6046356ea679a6cff328ce',
    messagingSenderId: '814660141387',
    projectId: 'new-tung',
    storageBucket: 'new-tung.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC0Yvap91ie9s8CSCJlfvZQo3zhsmTfda8',
    appId: '1:814660141387:ios:199d124c450205b8f328ce',
    messagingSenderId: '814660141387',
    projectId: 'new-tung',
    storageBucket: 'new-tung.appspot.com',
    iosBundleId: 'com.example.flutterFinalproject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC0Yvap91ie9s8CSCJlfvZQo3zhsmTfda8',
    appId: '1:814660141387:ios:0191b51140945ea2f328ce',
    messagingSenderId: '814660141387',
    projectId: 'new-tung',
    storageBucket: 'new-tung.appspot.com',
    iosBundleId: 'com.example.flutterFinalproject.RunnerTests',
  );
}
