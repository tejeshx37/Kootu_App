// Placeholder. Run `flutterfire configure --project=<your-project>` from the
// repo root to overwrite this file with real platform options. Until you do,
// Firebase.initializeApp() will throw at startup and the app falls back to
// signed-out mock data.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'firebase_options.dart has not been configured yet. '
      'Run `flutterfire configure` from the repo root to generate it.',
    );
    // ignore: dead_code
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB7PPPcVH84u4h9WZdPjnWbNWdDfrueZio',
    appId: '1:1031395777844:android:87e778fd7ef041a6ced961',
    messagingSenderId: '1031395777844',
    projectId: 'kootuapp',
    storageBucket: 'kootuapp.firebasestorage.app',
  );
}
