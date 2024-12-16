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
    apiKey: 'AIzaSyA5GXmMDOlPLMu_K-PMxYV19QBvgr20SgY',
    appId: '1:453571415915:web:3f12182c0a614e6227462e',
    messagingSenderId: '453571415915',
    projectId: 'atomicoat-a6241',
    authDomain: 'atomicoat-a6241.firebaseapp.com',
    storageBucket: 'atomicoat-a6241.firebasestorage.app',
    measurementId: 'G-479ZBMWF6W',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBqULWQWwZuZ1SxsUjlAo0dsKTMq31yEYc',
    appId: '1:453571415915:android:ac719308a7529f8f27462e',
    messagingSenderId: '453571415915',
    projectId: 'atomicoat-a6241',
    storageBucket: 'atomicoat-a6241.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB9bxvUhTJ6e2OzQIm7DRPbvMlQo8BLo6s',
    appId: '1:453571415915:ios:eddd1b4f71583c3027462e',
    messagingSenderId: '453571415915',
    projectId: 'atomicoat-a6241',
    storageBucket: 'atomicoat-a6241.firebasestorage.app',
    iosBundleId: 'com.example.atomicoat5thVersion',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB9bxvUhTJ6e2OzQIm7DRPbvMlQo8BLo6s',
    appId: '1:453571415915:ios:eddd1b4f71583c3027462e',
    messagingSenderId: '453571415915',
    projectId: 'atomicoat-a6241',
    storageBucket: 'atomicoat-a6241.firebasestorage.app',
    iosBundleId: 'com.example.atomicoat5thVersion',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD_8ExCYfFOyms-zg0jIUkYeVv-uQFfewY',
    appId: '1:453571415915:web:c807b2250a6cf0be27462e',
    messagingSenderId: '453571415915',
    projectId: 'atomicoat-a6241',
    authDomain: 'atomicoat-a6241.firebaseapp.com',
    storageBucket: 'atomicoat-a6241.firebasestorage.app',
    measurementId: 'G-9LR5W8Q7BF',
  );
}
