import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Two-tab notifications screen. Real items will appear here once we wire FCM
/// + a `notifications/{uid}/items` collection; until then both tabs render
/// empty states so the screen ships with no fake data.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Offers & Alerts'),
              Tab(text: 'Room Activity'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _Empty(
              icon: Icons.local_offer_outlined,
              title: 'No offers yet',
              body:
                  "We'll alert you when a nearby merchant has a deal on something in your list.",
            ),
            _Empty(
              icon: Icons.notifications_none_rounded,
              title: 'No room activity yet',
              body:
                  'Updates from people in your shared rooms — items added, bought, or marked claimed — will appear here.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.lightTextSecondary),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
