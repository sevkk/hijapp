// Firebase Web config for hijapp_admin
// hijapp-e2645 projesine bağlı

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError('Admin panel yalnızca Web için.');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAWvyAYtvAPkwGXrvKOWHO1hKuv_xGwKPo',
    appId: '1:708141297895:web:hijapp_admin_web',
    messagingSenderId: '708141297895',
    projectId: 'hijapp-e2645',
    authDomain: 'hijapp-e2645.firebaseapp.com',
    storageBucket: 'hijapp-e2645.firebasestorage.app',
  );
}
