import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers/theme_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Transparent status bar so our notebook background flows up under the
  // system clock instead of competing with it.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // App Check provides Play Integrity attestation that Firebase Auth (phone
    // OTP) and other backends verify. Debug builds use the debug provider,
    // which prints a token to register in the Firebase Console for emulators;
    // release builds use real Play Integrity. Kept inside the try/catch so a
    // not-yet-registered App Check never blocks app startup.
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    );
  } catch (e, st) {
    // Surface the failure during dev; the app still launches and shows the
    // signed-out experience.
    debugPrint('Firebase init / App Check failed: $e\n$st');
  }
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const KootuApp(),
    ),
  );
}
