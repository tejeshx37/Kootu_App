import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase init. Configure via FlutterFire CLI to add the
  // platform-specific options (firebase_options.dart). For now we use the
  // default app so the project compiles before platform setup is run.
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Allows running before FlutterFire CLI has been wired up.
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
