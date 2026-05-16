// File generated manually from google-services.json
// Regenerate with: flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions: $defaultTargetPlatform desteklenmiyor.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAWvyAYtvAPkwGXrvKOWHO1hKuv_xGwKPo',
    appId: '1:708141297895:web:2544bcd98fe30c5956b242',
    messagingSenderId: '708141297895',
    projectId: 'hijapp-e2645',
    authDomain: 'hijapp-e2645.firebaseapp.com',
    storageBucket: 'hijapp-e2645.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAWvyAYtvAPkwGXrvKOWHO1hKuv_xGwKPo',
    appId: '1:708141297895:android:7248fabb6e61ef8256b242',
    messagingSenderId: '708141297895',
    projectId: 'hijapp-e2645',
    storageBucket: 'hijapp-e2645.firebasestorage.app',
  );

  // TODO: iOS config'i Firebase Console'dan GoogleService-Info.plist indirdikten sonra ekle
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAWvyAYtvAPkwGXrvKOWHO1hKuv_xGwKPo',
    appId: '1:708141297895:android:7248fabb6e61ef8256b242',
    messagingSenderId: '708141297895',
    projectId: 'hijapp-e2645',
    storageBucket: 'hijapp-e2645.firebasestorage.app',
    iosBundleId: 'com.example.hijapp',
  );
}
