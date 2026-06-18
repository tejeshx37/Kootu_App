import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(currentUserProvider).asData?.value;
    final authUser = ref.watch(authStateProvider).asData?.value;
    final rooms = ref.watch(roomsProvider).asData?.value ?? const [];
    final scheme = Theme.of(context).colorScheme;

    final name = (appUser?.name.isNotEmpty ?? false)
        ? appUser!.name
        : (authUser?.displayName ?? 'Your profile');
    final location = [appUser?.locality, appUser?.city]
        .where((s) => s != null && s.isNotEmpty)
        .join(', ');
    final memberSince = appUser?.memberSince;
    final photoUrl = appUser?.photoUrl;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          // User card
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: scheme.outline),
            ),
            child: Row(
              children: [
                _Avatar(photoUrl: photoUrl, name: name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => context.push('/profile/edit'),
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.edit_outlined,
                                  size: 16, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(location.isEmpty ? 'Add your locality' : location,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.lightTextSecondary,
                          )),
                      const SizedBox(height: 2),
                      Text(
                          memberSince == null
                              ? ''
                              : 'Member since ${DateFormat.yMMM().format(memberSince)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.lightTextSecondary,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Stats — real room count.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _Stat(label: 'Rooms', value: '${rooms.length}'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Account section
          const _SectionHeader('ACCOUNT'),
          _row(context, Icons.home_work_outlined, 'My Rooms',
              onTap: () => context.push('/profile/rooms')),
          _row(context, Icons.contact_phone_outlined, 'Contact Nicknames',
              onTap: () => context.push('/profile/nicknames')),
          const _SectionHeader('PREFERENCES'),
          _row(context, Icons.notifications_none_rounded, 'Notifications',
              subtitle: 'Offers, room activity',
              onTap: () => context.push('/notifications')),
          _row(context, Icons.privacy_tip_outlined, 'Privacy & Data'),
          const _SectionHeader('SUPPORT'),
          _row(context, Icons.help_outline_rounded, 'Help & Support'),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: OutlinedButton(
              onPressed: () => ref.read(authServiceProvider)?.signOut(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Log Out'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _row(BuildContext c, IconData icon, String label,
      {String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl, required this.name});
  final String? photoUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '🙂';
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 30,
        backgroundColor: AppColors.primarySoft,
        backgroundImage: CachedNetworkImageProvider(photoUrl!),
      );
    }
    return CircleAvatar(
      radius: 30,
      backgroundColor: AppColors.primarySoft,
      child: Text(initial,
          style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.primary)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;
  @override
  Widget build(BuildContext c) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: AppColors.lightTextSecondary,
          ),
        ),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.primary,
                )),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.lightTextSecondary,
                )),
          ],
        ),
      ),
    );
  }
}
