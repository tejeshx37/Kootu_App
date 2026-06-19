import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../auth_error_text.dart';

/// Sign-in screen: Email/Password as primary, Google as a one-tap alternative.
///
/// Phone OTP was intentionally removed for v1. Sending SMS to Indian numbers
/// requires TRAI/DLT registration (entity, header, template — 1–7 day
/// approval), which we're deferring. The backend OTP path lives in
/// `functions/{send,verify}Otp` and can be re-enabled later by re-adding the
/// phone tab here.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _emailRegister = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// Creates the Firestore user doc the first time we see this account, with
  /// zero rooms. The display name is captured afterwards on the set-name
  /// screen. Wrapped so a transient Firestore failure here doesn't get
  /// surfaced as an auth error — `currentUserProvider` is a live stream and
  /// will pick up the doc once connectivity returns.
  Future<void> _bootstrapIfNew(UserCredential cred) async {
    final user = cred.user;
    if (cred.additionalUserInfo?.isNewUser != true || user == null) return;
    try {
      await ref.read(firestoreServiceProvider).bootstrapNewUser(
            uid: user.uid,
            phone: user.phoneNumber ?? '',
            name: user.displayName ?? '',
            email: user.email,
            photoUrl: user.photoURL,
          );
    } catch (e) {
      debugPrint('bootstrapNewUser failed (will retry via live stream): $e');
    }
  }

  // ---- Email ----
  Future<void> _submitEmail() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (!email.contains('@') || email.length < 5) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    final svc = ref.read(authServiceProvider);
    if (svc == null) {
      setState(() => _error = 'Firebase not configured.');
      return;
    }
    setState(() {
      _error = null;
      _busy = true;
    });
    try {
      final cred = _emailRegister
          ? await svc.registerWithEmail(email: email, password: password)
          : await svc.signInWithEmail(email: email, password: password);
      await _bootstrapIfNew(cred);
      // Router redirect handles navigation.
    } catch (e) {
      setState(() {
        _busy = false;
        _error = authErrorText(e);
      });
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (!email.contains('@')) {
      setState(() => _error = 'Enter your email above to reset the password.');
      return;
    }
    try {
      await ref.read(authServiceProvider)?.sendPasswordReset(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent.')),
        );
      }
    } catch (e) {
      setState(() => _error = authErrorText(e));
    }
  }

  // ---- Google ----
  Future<void> _googleSignIn() async {
    final svc = ref.read(authServiceProvider);
    if (svc == null) {
      setState(() => _error = 'Firebase not configured.');
      return;
    }
    setState(() {
      _error = null;
      _busy = true;
    });
    try {
      final cred = await svc.signInWithGoogle();
      if (cred == null) {
        setState(() => _busy = false); // cancelled
        return;
      }
      await _bootstrapIfNew(cred);
      // Router redirect handles navigation.
    } catch (e) {
      setState(() {
        _busy = false;
        _error = authErrorText(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Welcome to Kootu',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign in or create your account to start sharing lists.',
                style: TextStyle(color: AppColors.lightTextSecondary),
              ),
              const SizedBox(height: 28),
              _emailForm(),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'or',
                      style: TextStyle(color: AppColors.lightTextSecondary),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _googleSignIn,
                  icon: const Text(
                    'G',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emailForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'you@example.com',
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _passwordCtrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            hintText: 'At least 6 characters',
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => setState(() {
                _emailRegister = !_emailRegister;
                _error = null;
              }),
              child: Text(
                _emailRegister
                    ? 'Have an account? Sign in'
                    : 'New here? Create account',
              ),
            ),
            if (!_emailRegister)
              TextButton(
                onPressed: _forgotPassword,
                child: const Text('Forgot?'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _busy ? null : _submitEmail,
            child: _busy
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_emailRegister ? 'Create account' : 'Sign in'),
          ),
        ),
      ],
    );
  }
}
