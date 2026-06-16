import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/mock_data.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';

enum _Stage { phone, otp, verifying, done }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _phoneCtrl = TextEditingController();
  final _otp = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());

  _Stage _stage = _Stage.phone;
  String? _verificationId;
  int _resend = 29;
  Timer? _resendTimer;
  String? _error;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    for (final c in _otp) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final phone = '+91${_phoneCtrl.text.trim()}';
    if (_phoneCtrl.text.trim().length != 10) {
      setState(() => _error = 'Enter a 10-digit phone number');
      return;
    }
    setState(() => _error = null);
    final svc = ref.read(authServiceProvider);
    if (svc == null) {
      setState(() => _error = 'Firebase not configured — run flutterfire configure.');
      return;
    }
    await svc.verifyPhone(
          phoneE164: phone,
          codeSent: (id, _) {
            setState(() {
              _verificationId = id;
              _stage = _Stage.otp;
              _resend = 29;
            });
            _startResendTimer();
            _nodes.first.requestFocus();
          },
          onError: (e) => setState(() => _error = e.message),
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

  Future<void> _verify() async {
    final code = _otp.map((c) => c.text).join();
    if (code.length != 6 || _verificationId == null) return;
    setState(() => _stage = _Stage.verifying);
    final svc = ref.read(authServiceProvider);
    if (svc == null) {
      setState(() { _stage = _Stage.otp; _error = 'Firebase not configured.'; });
      return;
    }
    try {
      final cred = await svc.signInWithSmsCode(
            verificationId: _verificationId!,
            smsCode: code,
          );
      if (cred.additionalUserInfo?.isNewUser == true && cred.user != null) {
        await ref.read(firestoreServiceProvider).bootstrapNewUser(
              uid: cred.user!.uid,
              phone: cred.user!.phoneNumber ?? '+91${_phoneCtrl.text.trim()}',
              seedItems: MockData.itemsByRoom['1'] ?? const [],
            );
      }
      // Router redirect will handle navigation away.
      setState(() => _stage = _Stage.done);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _stage = _Stage.otp;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _stage == _Stage.phone
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _stage = _Stage.phone),
              ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: switch (_stage) {
          _Stage.phone => _phoneStage(),
          _Stage.otp => _otpStage(),
          _Stage.verifying => _verifyingStage(),
          _Stage.done => _verifyingStage(done: true),
        },
      ),
    );
  }

  Widget _phoneStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text('Welcome to Kootu',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text("We'll send a 6-digit code to verify your number.",
            style: TextStyle(color: AppColors.lightTextSecondary)),
        const SizedBox(height: 28),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 14),
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
                decoration:
                    const InputDecoration(hintText: 'Phone number'),
              ),
            ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!,
              style: const TextStyle(color: AppColors.error, fontSize: 12)),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _sendCode,
            child: const Text('Send code'),
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
            style:
                const TextStyle(color: AppColors.lightTextSecondary)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < 6; i++)
              SizedBox(
                width: 44,
                height: 54,
                child: TextField(
                  controller: _otp[i],
                  focusNode: _nodes[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(counterText: ''),
                  onChanged: (v) {
                    if (v.isNotEmpty && i < 5) {
                      _nodes[i + 1].requestFocus();
                    } else if (v.isEmpty && i > 0) {
                      _nodes[i - 1].requestFocus();
                    }
                    if (i == 5 && v.isNotEmpty) _verify();
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
        const SizedBox(height: 16),
        Center(
          child: _resend > 0
              ? Text('Resend in ${_resend}s',
                  style:
                      const TextStyle(color: AppColors.lightTextSecondary))
              : TextButton(
                  onPressed: _sendCode,
                  child: const Text('Resend code'),
                ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _verify,
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
