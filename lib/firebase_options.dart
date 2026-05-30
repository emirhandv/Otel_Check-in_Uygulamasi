
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCt_LtLEYZE6ML5W2k32Jmf2R2XY3DVZxg',
    appId: '1:621071097584:web:654e8176abd76e07516c35',
    messagingSenderId: '621071097584',
    projectId: 'yazilimmuhendisligi-50508',
    authDomain: 'yazilimmuhendisligi-50508.firebaseapp.com',
    storageBucket: 'yazilimmuhendisligi-50508.firebasestorage.app',
    measurementId: 'G-ZMVW9JZNKH',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCZ8RCqyXVvjvEIFq6k8SockkbfYlxkG1A',
    appId: '1:621071097584:ios:71374351859d0a28516c35',
    messagingSenderId: '621071097584',
    projectId: 'yazilimmuhendisligi-50508',
    storageBucket: 'yazilimmuhendisligi-50508.firebasestorage.app',
    iosBundleId: 'com.example.yazilimMuhendisligiProjesi',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCt_LtLEYZE6ML5W2k32Jmf2R2XY3DVZxg',
    appId: '1:621071097584:web:527933212995e453516c35',
    messagingSenderId: '621071097584',
    projectId: 'yazilimmuhendisligi-50508',
    authDomain: 'yazilimmuhendisligi-50508.firebaseapp.com',
    storageBucket: 'yazilimmuhendisligi-50508.firebasestorage.app',
    measurementId: 'G-H22KD33P99',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBWWbi6wCeXt1zOGob-Xv6wyMpwiR0kivs',
    appId: '1:621071097584:android:d734cba90da11a2a516c35',
    messagingSenderId: '621071097584',
    projectId: 'yazilimmuhendisligi-50508',
    storageBucket: 'yazilimmuhendisligi-50508.firebasestorage.app',
  );

}