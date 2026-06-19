import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';

class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});
  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  final _codeCtrl = TextEditingController();
  bool _joining = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.length != 6) {
      setState(() => _error = 'Invite codes are 6 characters.');
      return;
    }
    final uid = ref.read(authStateProvider).asData?.value?.uid;
    if (uid == null) return;
    final me = ref.read(currentUserProvider).asData?.value;

    setState(() {
      _joining = true;
      _error = null;
    });
    try {
      final room = await ref
          .read(firestoreServiceProvider)
          .joinRoomByInviteCode(code, uid, name: me?.name ?? '');
      if (!mounted) return;
      if (room == null) {
        setState(() {
          _joining = false;
          _error = 'No room found with that code.';
        });
        return;
      }
      ref.read(explicitRoomIdProvider.notifier).state = room.id;
      context.go('/home');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joined ${room.emoji} ${room.name}')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _joining = false;
        _error = 'Could not join: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join room')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter the 6-character invite code',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text(
              'Ask the room creator to share it from their room settings.',
              style: TextStyle(
                  fontSize: 13, color: AppColors.lightTextSecondary),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 8,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'[A-Za-z0-9]')),
                LengthLimitingTextInputFormatter(6),
                _UpperCaseFormatter(),
              ],
              decoration: const InputDecoration(
                counterText: '',
                hintText: 'ABC123',
              ),
              onSubmitted: (_) => _join(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(
                      color: AppColors.error, fontSize: 12)),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _joining ? null : _join,
                child: _joining
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Join room'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
