import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _offers = [
    ('Near FreshMart!', '3 items on your list are on offer', '2m ago', true),
    ('Aavin Booth deal', 'Flat ₹15 off Milk (2L)', '1h ago', false),
    ('Garam Masala 20% off', 'At Saravana Spices', '4h ago', false),
    ('BOGO chips', 'At KK Snacks Mart', 'Yesterday', false),
  ];

  static const _activity = [
    ('Mom marked Milk as Bought ✓', 'Family Room', '5m ago', true),
    ('Priya added Basmati Rice', 'Family Room', '1h ago', false),
    ('Rajan joined Weekend BBQ', 'Weekend BBQ', '3h ago', false),
    ('Meena claimed Curd', 'Work Lunch', 'Yesterday', false),
    ('Kavya updated budget', 'Family Room', '2 days ago', false),
  ];

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
        body: TabBarView(
          children: [
            _list(context, _offers),
            _list(context, _activity),
          ],
        ),
      ),
    );
  }

  Widget _list(BuildContext context,
      List<(String, String, String, bool)> data) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: data.length,
      itemBuilder: (ctx, i) {
        final (title, body, time, unread) = data[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border(
              left: BorderSide(
                color: unread ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
              top: BorderSide(
                  color: Theme.of(context).colorScheme.outline),
              right: BorderSide(
                  color: Theme.of(context).colorScheme.outline),
              bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline),
            ),
          ),
          child: ListTile(
            title: Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(body),
            trailing: Text(time,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.lightTextSecondary,
                )),
          ),
        );
      },
    );
  }
}
