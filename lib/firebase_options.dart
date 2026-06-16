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
        throw UnsupportedError('unconfigured platform');
    }
  }
}
