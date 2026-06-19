import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';

// Null when Firebase wasn't initialized (e.g. no-app before initializeApp runs).
// All downstream providers treat null as signed-out.
final firebaseAuthProvider = Provider<FirebaseAuth?>((ref) {
  if (Firebase.apps.isEmpty) return null;
  return FirebaseAuth.instance;
});

final authServiceProvider = Provider<AuthService?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  if (auth == null) return null;
  return AuthService(auth);
});

final authStateProvider = StreamProvider<User?>((ref) {
  final svc = ref.watch(authServiceProvider);
  if (svc == null) return Stream.value(null);
  return svc.authStateChanges;
});
