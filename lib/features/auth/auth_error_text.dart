import 'package:firebase_auth/firebase_auth.dart';

/// Maps Firebase auth error codes to friendly, user-facing messages so we never
/// surface raw SDK strings.
String authErrorText(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-phone-number':
        return 'That phone number doesn\'t look right. Check and try again.';
      case 'invalid-verification-code':
        return 'Incorrect code. Please re-enter the 6-digit OTP.';
      case 'session-expired':
      case 'code-expired':
        return 'That code expired. Tap resend to get a new one.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a little and try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'email-already-in-use':
        return 'An account already exists for this email. Try signing in.';
      case 'weak-password':
        return 'Password is too weak — use at least 6 characters.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'account-exists-with-different-credential':
        return 'This email is linked to a different sign-in method.';
      default:
        return error.message ?? 'Something went wrong. Please try again.';
    }
  }
  return 'Something went wrong. Please try again.';
}
