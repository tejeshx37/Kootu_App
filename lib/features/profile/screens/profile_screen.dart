import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).asData?.value;
    final scheme = Theme.of(context).colorScheme;

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
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primarySoft,
                  child: Text('👩', style: TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.displayName ?? 'Priya Subramaniam',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      const Text('Velachery, Chennai',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.lightTextSecondary,
                          )),
                      const SizedBox(height: 2),
                      const Text('Member since Jan 2024',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.lightTextSecondary,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                _Stat(label: 'Rooms', value: '3'),
                SizedBox(width: 10),
                _Stat(label: 'Items Bought', value: '142'),
                SizedBox(width: 10),
                _Stat(label: 'Money Saved', value: '₹1,820'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Recent purchases
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text('Recent Purchases',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700)),
          ),
          for (final p in _samplePurchases)
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primarySoft,
                child: Text('🛒'),
              ),
              title: Text(p.item),
              subtitle: Text('${p.room} · ${p.date}'),
              trailing: Text('₹${p.price}',
                  style:
                      const TextStyle(fontWeight: FontWeight.w700)),
            ),
          // Merchant CTA
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.md),
              onTap: () => context.push('/merchant/dash'),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.storefront_rounded, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Switch to Merchant Mode',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          // Account section
          const _SectionHeader('ACCOUNT'),
          _row(context, Icons.home_work_outlined, 'My Rooms',
              onTap: () => context.push('/profile/rooms')),
          _row(context, Icons.history_rounded, 'Purchase History'),
          _row(context, Icons.savings_outlined, 'Savings Report'),
          _row(context, Icons.contact_phone_outlined, 'Contact Nicknames',
              onTap: () => context.push('/profile/nicknames')),
          const _SectionHeader('PREFERENCES'),
          _row(context, Icons.notifications_none_rounded, 'Notifications',
              subtitle: 'Offers, room activity'),
          ListTile(
            leading: const Icon(Icons.translate_rounded),
            title: const Text('Language'),
            subtitle: const Text('English'),
            trailing: Switch(value: false, onChanged: (_) {}),
          ),
          _row(context, Icons.privacy_tip_outlined, 'Privacy & Data'),
          const _SectionHeader('SUPPORT'),
          _row(context, Icons.help_outline_rounded, 'Help & Support'),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: OutlinedButton(
              onPressed: () =>
                  ref.read(authServiceProvider).signOut(),
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

class _Purchase {
  final String item, room, date;
  final int price;
  const _Purchase(this.item, this.room, this.date, this.price);
}

const _samplePurchases = [
  _Purchase('Basmati Rice', 'Family Room', 'Yesterday', 480),
  _Purchase('Milk (2L)', 'Family Room', '2 days ago', 64),
  _Purchase('Curd', 'Work Lunch', '3 days ago', 35),
];
