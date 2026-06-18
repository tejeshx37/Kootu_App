import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../auth_error_text.dart';

enum _Method { phone, email }

enum _Stage { entry, otp, verifying, done }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _otpFocus = FocusNode();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  _Method _method = _Method.phone;
  _Stage _stage = _Stage.entry;
  bool _emailRegister = false;
  bool _busy = false;

  String? _verificationId;
  int _resend = 29;
  Timer? _resendTimer;
  String? _error;

  @override
  void initState() {
    super.initState();
    _otpFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _otpFocus.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  /// Creates the Firestore user doc the first time we see this account, with
  /// zero rooms. The display name is captured afterwards on the set-name
  /// screen.
  ///
  /// Sign-in itself already succeeded by the time this runs, so a Firestore
  /// failure here (e.g. the device has no network) must not be reported as
  /// an auth error — the router retries the user-doc read once connectivity
  /// returns, since `currentUserProvider` is a live stream.
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

  // ---- Phone ----
  Future<void> _sendCode() async {
    if (_phoneCtrl.text.trim().length != 10) {
      setState(() => _error = 'Enter a 10-digit phone number');
      return;
    }
    final svc = ref.read(authServiceProvider);
    if (svc == null) {
      setState(() => _error = 'Firebase not configured — run flutterfire configure.');
      return;
    }
    setState(() {
      _error = null;
      _busy = true;
    });
    await svc.verifyPhone(
      phoneE164: '+91${_phoneCtrl.text.trim()}',
      codeSent: (id, _) {
        setState(() {
          _verificationId = id;
          _stage = _Stage.otp;
          _resend = 29;
          _busy = false;
        });
        _startResendTimer();
        _otpCtrl.clear();
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _otpFocus.requestFocus());
      },
      onError: (e) => setState(() {
        _error = authErrorText(e);
        _busy = false;
      }),
    );
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resend <= 0) {
        t.cancel();
      } else {
        setState(() => _resend--);
      }
    });
  }

  Future<void> _verifyOtp() async {
    final code = _otpCtrl.text.trim();
    if (code.length != 6 || _verificationId == null) return;
    final svc = ref.read(authServiceProvider);
    if (svc == null) {
      setState(() => _error = 'Firebase not configured.');
      return;
    }
    setState(() => _stage = _Stage.verifying);
    try {
      final cred = await svc.signInWithSmsCode(
        verificationId: _verificationId!,
        smsCode: code,
      );
      await _bootstrapIfNew(cred);
      setState(() => _stage = _Stage.done);
      // Router redirect handles navigation (to set-name or home).
    } catch (e) {
      setState(() {
        _stage = _Stage.otp;
        _error = authErrorText(e);
      });
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
      appBar: AppBar(
        leading: _stage == _Stage.otp
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _stage = _Stage.entry;
                  _error = null;
                }),
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: switch (_stage) {
          _Stage.entry => _entryStage(),
          _Stage.otp => _otpStage(),
          _Stage.verifying => _verifyingStage(),
          _Stage.done => _verifyingStage(done: true),
        },
      ),
    );
  }

  Widget _entryStage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text('Welcome to Kootu',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Sign in or create your account to start sharing lists.',
              style: TextStyle(color: AppColors.lightTextSecondary)),
          const SizedBox(height: 24),
          SegmentedButton<_Method>(
            segments: const [
              ButtonSegment(
                  value: _Method.phone,
                  icon: Icon(Icons.smartphone_rounded),
                  label: Text('Phone')),
              ButtonSegment(
                  value: _Method.email,
                  icon: Icon(Icons.alternate_email_rounded),
                  label: Text('Email')),
            ],
            selected: {_method},
            onSelectionChanged: (s) => setState(() {
              _method = s.first;
              _error = null;
            }),
          ),
          const SizedBox(height: 24),
          if (_method == _Method.phone) _phoneForm() else _emailForm(),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style: const TextStyle(color: AppColors.error, fontSize: 12)),
          ],
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('or', style: TextStyle(color: AppColors.lightTextSecondary)),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _busy ? null : _googleSignIn,
              icon: const Text('G',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, color: AppColors.primary)),
              label: const Text('Continue with Google'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _phoneForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.lightInputBg,
                borderRadius: BorderRadius.circular(AppRadii.xs),
              ),
              child: const Text('🇮🇳 +91',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: const InputDecoration(hintText: 'Phone number'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _busy ? null : _sendCode,
            child: _busy
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Send code'),
          ),
        ),
      ],
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
              child: Text(_emailRegister
                  ? 'Have an account? Sign in'
                  : 'New here? Create account'),
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
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_emailRegister ? 'Create account' : 'Sign in'),
          ),
        ),
      ],
    );
  }

  Widget _otpStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Enter the 6-digit code',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Sent to +91 ${_phoneCtrl.text}',
            style: const TextStyle(color: AppColors.lightTextSecondary)),
        const SizedBox(height: 32),
        Stack(
          children: [
            Opacity(
              opacity: 0,
              child: TextField(
                controller: _otpCtrl,
                focusNode: _otpFocus,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) {
                  setState(() {});
                  if (v.length == 6) _verifyOtp();
                },
              ),
            ),
            GestureDetector(
              onTap: _otpFocus.requestFocus,
              child: ValueListenableBuilder(
                valueListenable: _otpCtrl,
                builder: (_, val, __) {
                  final code = val.text;
                  final hasFocus = _otpFocus.hasFocus;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var i = 0; i < 6; i++)
                        _OtpBox(
                          digit: i < code.length ? code[i] : null,
                          isActive: hasFocus && i == code.length.clamp(0, 5),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!,
              style: const TextStyle(color: AppColors.error, fontSize: 12)),
        ],
        const SizedBox(height: 20),
        Center(
          child: _resend > 0
              ? Text('Resend in ${_resend}s',
                  style: const TextStyle(color: AppColors.lightTextSecondary))
              : TextButton(
                  onPressed: _sendCode,
                  child: const Text('Resend code'),
                ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _verifyOtp,
            child: const Text('Verify'),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _verifyingStage({bool done = false}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          done
              ? const Icon(Icons.check_circle,
                  color: AppColors.success, size: 64)
              : const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(done ? 'Verified!' : 'Verifying…'),
        ],
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({required this.digit, required this.isActive});
  final String? digit;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filled = digit != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 46,
      height: 58,
      decoration: BoxDecoration(
        color: filled
            ? AppColors.primary.withValues(alpha: 0.12)
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: isActive
              ? AppColors.primary
              : filled
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : scheme.outline,
          width: isActive ? 2 : 1.5,
        ),
      ),
      child: Center(
        child: filled
            ? Text(
                digit!,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              )
            : isActive
                ? Container(
                    width: 2,
                    height: 24,
                    color: AppColors.primary,
                  )
                : null,
      ),
    );
  }
}
