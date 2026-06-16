import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';

const _emojiChoices = [
  '🏠', '🏡', '🛒', '🍱', '🎉', '🎂', '🏖️',
  '🎓', '💼', '🏋️', '🐕', '☕',
];

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});
  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  final _nameCtrl = TextEditingController();
  String _emoji = _emojiChoices.first;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please give your room a name.');
      return;
    }
    final uid = ref.read(authStateProvider).asData?.value?.uid;
    if (uid == null) return;

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final room = await ref
          .read(firestoreServiceProvider)
          .createRoom(uid: uid, name: name, emoji: _emoji);
      if (!mounted) return;
      ref.read(selectedRoomIdProvider.notifier).state = room.id;
      context.go('/home');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Expanded(
                child: Text('Room created. Invite code: ${room.inviteCode}'),
              ),
              TextButton(
                onPressed: () => Clipboard.setData(
                    ClipboardData(text: room.inviteCode ?? '')),
                child: const Text('COPY',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Could not create room: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Create room')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Name your room',
                style:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'e.g. Family Room, Work Lunch',
              ),
              onSubmitted: (_) => _create(),
            ),
            const SizedBox(height: 24),
            const Text('Pick an emoji',
                style:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final e in _emojiChoices)
                  GestureDetector(
                    onTap: () => setState(() => _emoji = e),
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _emoji == e
                            ? AppColors.primarySoft
                            : scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        border: Border.all(
                          color: _emoji == e
                              ? AppColors.primary
                              : scheme.outline,
                          width: _emoji == e ? 2 : 1,
                        ),
                      ),
                      child:
                          Text(e, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!,
                  style: const TextStyle(
                      color: AppColors.error, fontSize: 12)),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _create,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Create room'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
