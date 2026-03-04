
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      case TargetPlatform.iOS:     return ios;
      case TargetPlatform.macOS:   return macos;
      case TargetPlatform.windows: return web; // fallback
      case TargetPlatform.linux:   return web; // fallback
      default: throw UnsupportedError('Unsupported platform');
    }
  }

  // ── Web ──────────────────────────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey:            'AIzaSyAqHZa6CS_Ewevevsy3x2M8jl62PF0P2FA',
    authDomain:        'aquasense-58345.firebaseapp.com',
    databaseURL:       'https://aquasense-58345-default-rtdb.europe-west1.firebasedatabase.app',
    projectId:         'aquasense-58345',
    storageBucket:     'aquasense-58345.firebasestorage.app',
    messagingSenderId: '453888586687',
    appId:             '1:453888586687:web:a161df037d9ded93f8670a',
  );

  // ── Android ──────────────────────────────────────────────────
  // TODO: Download google-services.json from Firebase Console
  // and place it in android/app/google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey:            'AIzaSyAqHZa6CS_Ewevevsy3x2M8jl62PF0P2FA',
    appId:             '1:453888586687:android:aquasense',
    messagingSenderId: '453888586687',
    projectId:         'aquasense-58345',
    databaseURL:       'https://aquasense-58345-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket:     'aquasense-58345.firebasestorage.app',
  );

  // ── iOS ──────────────────────────────────────────────────────
  // TODO: Download GoogleService-Info.plist from Firebase Console
  // and place it in ios/Runner/GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey:            'AIzaSyAqHZa6CS_Ewevevsy3x2M8jl62PF0P2FA',
    appId:             '1:453888586687:ios:aquasense',
    messagingSenderId: '453888586687',
    projectId:         'aquasense-58345',
    databaseURL:       'https://aquasense-58345-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket:     'aquasense-58345.firebasestorage.app',
    iosBundleId:       'com.aquasense.app',
  );

  // ── macOS ─────────────────────────────────────────────────────
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey:            'AIzaSyAqHZa6CS_Ewevevsy3x2M8jl62PF0P2FA',
    appId:             '1:453888586687:ios:aquasense',
    messagingSenderId: '453888586687',
    projectId:         'aquasense-58345',
    databaseURL:       'https://aquasense-58345-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket:     'aquasense-58345.firebasestorage.app',
    iosBundleId:       'com.aquasense.app',
  );
}
