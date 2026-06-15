import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService(this._auth);
  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Begins phone-OTP verification. The verificationId is returned via the
  /// codeSent callback so the OTP screen can submit the code.
  Future<void> verifyPhone({
    required String phoneE164,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(FirebaseAuthException error) onError,
    void Function(PhoneAuthCredential credential)? onAutoVerify,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneE164,
      timeout: timeout,
      verificationCompleted: onAutoVerify ?? (_) {},
      verificationFailed: onError,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<UserCredential> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) {
    final cred = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(cred);
  }

  Future<void> signOut() => _auth.signOut();
}
