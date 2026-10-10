// File generated manually for Firebase project: thefreshyard-45b7e
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with Firebase.initializeApp.
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
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBkvDF3mQLewJpdWpbcMaw81_AbAfp5jqA',
    appId: '1:825455455996:web:23123cf79fd32ef34a3179',
    messagingSenderId: '825455455996',
    projectId: 'thefreshyard-45b7e',
    storageBucket: 'thefreshyard-45b7e.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBkvDF3mQLewJpdWpbcMaw81_AbAfp5jqA',
    appId: '1:825455455996:android:23123cf79fd32ef34a3179',
    messagingSenderId: '825455455996',
    projectId: 'thefreshyard-45b7e',
    storageBucket: 'thefreshyard-45b7e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBkvDF3mQLewJpdWpbcMaw81_AbAfp5jqA',
    appId: '1:825455455996:ios:23123cf79fd32ef34a3179',
    messagingSenderId: '825455455996',
    projectId: 'thefreshyard-45b7e',
    storageBucket: 'thefreshyard-45b7e.firebasestorage.app',
    iosBundleId: 'com.thefreshyard.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBkvDF3mQLewJpdWpbcMaw81_AbAfp5jqA',
    appId: '1:825455455996:ios:23123cf79fd32ef34a3179',
    messagingSenderId: '825455455996',
    projectId: 'thefreshyard-45b7e',
    storageBucket: 'thefreshyard-45b7e.firebasestorage.app',
    iosBundleId: 'com.thefreshyard.app',
  );
}
