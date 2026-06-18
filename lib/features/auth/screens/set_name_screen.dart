import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';

/// Shown once for a brand-new account to capture the display name (and a rough
/// locality), which the rest of the app relies on. The router guards `/home`
/// until a name exists.
class SetNameScreen extends ConsumerStatefulWidget {
  const SetNameScreen({super.key});

  @override
  ConsumerState<SetNameScreen> createState() => _SetNameScreenState();
}

class _SetNameScreenState extends ConsumerState<SetNameScreen> {
  final _nameCtrl = TextEditingController();
  final _localityCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Pre-fill from a Google display name when available.
    final existing = FirebaseAuth.instance.currentUser?.displayName;
    if (existing != null && existing.isNotEmpty) _nameCtrl.text = existing;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _localityCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.length < 2) {
      setState(() => _error = 'Please enter your name (at least 2 letters).');
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider)?.updateDisplayName(name);
      await ref.read(firestoreServiceProvider).updateUserProfile(
            uid: user.uid,
            name: name,
            locality: _localityCtrl.text.trim(),
            city: _cityCtrl.text.trim(),
          );
      if (mounted) context.go('/home');
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const Text('What should we call you?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text(
                'Your name shows up next to items you add and to your room members.',
                style: TextStyle(color: AppColors.lightTextSecondary),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  hintText: 'e.g. Priya Subramaniam',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _localityCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Locality (optional)',
                  hintText: 'e.g. Velachery',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cityCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'City (optional)',
                  hintText: 'e.g. Chennai',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style:
                        const TextStyle(color: AppColors.error, fontSize: 12)),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
