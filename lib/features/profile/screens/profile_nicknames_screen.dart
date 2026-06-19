import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';

class ProfileNicknamesScreen extends ConsumerStatefulWidget {
  const ProfileNicknamesScreen({super.key});
  @override
  ConsumerState<ProfileNicknamesScreen> createState() =>
      _ProfileNicknamesScreenState();
}

class _ProfileNicknamesScreenState
    extends ConsumerState<ProfileNicknamesScreen> {
  String? _editing; // contact uid currently being edited
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save(String contactUid) async {
    final value = _ctrl.text.trim();
    final uid = ref.read(authStateProvider).asData?.value?.uid;
    setState(() => _editing = null);
    if (uid == null) return;
    try {
      await ref.read(firestoreServiceProvider).setNickname(
            uid: uid,
            contactUid: contactUid,
            nickname: value,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save nickname: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(contactsProvider);
    final nicknames =
        ref.watch(currentUserProvider).asData?.value?.nicknames ?? const {};

    return Scaffold(
      appBar: AppBar(title: const Text('Contact Nicknames')),
      body: contacts.isEmpty
          ? _empty()
          : ListView(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: const Text(
                    'Nicknames are private to you and shown in your shopping '
                    'rooms.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                for (final c in contacts)
                  ListTile(
                    leading: CircleAvatar(child: Text(c.avatar)),
                    title: _editing == c.uid
                        ? TextField(
                            controller: _ctrl,
                            autofocus: true,
                            onSubmitted: (_) => _save(c.uid),
                            decoration: const InputDecoration(
                              hintText: 'Nickname',
                            ),
                          )
                        : Text(nicknames[c.uid] == null
                            ? c.name
                            : '${nicknames[c.uid]} (${c.name})'),
                    subtitle: Text(
                      c.roomNames.isEmpty
                          ? 'Shared room'
                          : c.roomNames.toSet().join(' · '),
                    ),
                    trailing: _editing == c.uid
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () =>
                                    setState(() => _editing = null),
                              ),
                              IconButton(
                                icon: const Icon(Icons.check,
                                    color: AppColors.primary),
                                onPressed: () => _save(c.uid),
                              ),
                            ],
                          )
                        : IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () {
                              setState(() {
                                _editing = c.uid;
                                _ctrl.text = nicknames[c.uid] ?? '';
                              });
                            },
                          ),
                  ),
              ],
            ),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.group_outlined,
                size: 56, color: AppColors.lightTextSecondary),
            SizedBox(height: 16),
            Text(
              'No contacts yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text(
              'People you share a room with appear here, so you can give them '
              'private nicknames.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: AppColors.lightTextSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
