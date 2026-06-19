import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService(this._auth, this._functions);
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ---- Phone OTP (custom backend over MSG91) ----
  // Phone auth no longer uses Firebase's Play-Integrity-gated client flow.
  // Instead a Cloud Function generates + SMSes the code (via MSG91); a second
  // function verifies it and returns a Firebase custom token we sign in with.
  // This works on any build (incl. unpublished debug) with no reCAPTCHA.

  /// Asks the backend to text a 6-digit code to [phoneE164] (E.164, e.g.
  /// +919042512878). Throws [FirebaseFunctionsException] with a friendly
  /// message on failure (rate limit, send error, bad number).
  Future<void> sendPhoneOtp(String phoneE164) async {
    await _functions.httpsCallable('sendOtp').call({'phone': phoneE164});
  }

  /// Verifies [code] for [phoneE164]; on success exchanges the returned custom
  /// token for a real Firebase session.
  Future<UserCredential> signInWithPhoneOtp({
    required String phoneE164,
    required String code,
  }) async {
    final res = await _functions
        .httpsCallable('verifyOtp')
        .call({'phone': phoneE164, 'code': code});
    final token = (res.data as Map)['token'] as String;
    return _auth.signInWithCustomToken(token);
  }

  // Email / password
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) =>
      _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  // Google
  /// Interactive Google Sign-In. Returns null if the user cancels the picker.
  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null; // user cancelled
    final googleAuth = await googleUser.authentication;
    final cred = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(cred);
  }

  // Profile
  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
    await _auth.currentUser?.reload();
  }

  Future<void> updatePhotoUrl(String url) async {
    await _auth.currentUser?.updatePhotoURL(url);
    await _auth.currentUser?.reload();
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}
