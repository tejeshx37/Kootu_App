import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class MerchantProfileScreen extends StatelessWidget {
  const MerchantProfileScreen({super.key, required this.merchantId});
  final String merchantId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (ctx, _) => [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: scheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl:
                          'https://images.unsplash.com/photo-1542838132-92c53300491e',
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          Container(color: AppColors.primarySoft),
                    ),
                    Positioned(
                      left: 16,
                      bottom: -28,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: scheme.surface, width: 3),
                        ),
                        alignment: Alignment.center,
                        child: const Text('🏪',
                            style: TextStyle(fontSize: 36)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 36, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('FreshMart Velachery',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.star_rounded,
                            size: 16, color: AppColors.warning),
                        SizedBox(width: 2),
                        Text('4.6 · 240 reviews',
                            style: TextStyle(fontSize: 12)),
                        SizedBox(width: 10),
                        Text('· 180 m away',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.lightTextSecondary,
                            )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.directions_rounded),
                            label: const Text('Directions'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.call),
                            label: const Text('Call'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SliverPersistentHeader(
              pinned: true,
              delegate: _TabsDelegate(),
            ),
          ],
          body: const TabBarView(
            children: [
              _OffersTab(),
              _ReviewsTab(),
              _AboutTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabsDelegate extends SliverPersistentHeaderDelegate {
  const _TabsDelegate();
  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate old) => false;
  @override
  Widget build(BuildContext context, double shrink, bool overlaps) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: const TabBar(
        labelColor: AppColors.primary,
        indicatorColor: AppColors.primary,
        tabs: [
          Tab(text: 'Active Offers'),
          Tab(text: 'Reviews'),
          Tab(text: 'About'),
        ],
      ),
    );
  }
}

class _OffersTab extends StatelessWidget {
  const _OffersTab();
  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Card(title: '10% off Basmati Rice', subtitle: 'Save up to ₹120'),
          _Card(title: 'Flat ₹15 off Milk', subtitle: 'Save up to ₹30'),
          _Card(title: '20% off Garam Masala', subtitle: 'Save up to ₹60'),
        ],
      );
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab();
  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Card(title: 'Priya · ★★★★★', subtitle: 'Always fresh stock.'),
          _Card(title: 'Anand · ★★★★☆', subtitle: 'Good prices, friendly.'),
          _Card(title: 'Meena · ★★★★★', subtitle: 'My go-to kirana store.'),
        ],
      );
}

class _AboutTab extends StatelessWidget {
  const _AboutTab();
  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Family-run kirana store serving Velachery since 2014. '
            'Stocks daily essentials, fresh produce and household goods.',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
          SizedBox(height: 16),
          ListTile(
              leading: Icon(Icons.location_on_outlined),
              title: Text('12, 2nd Main Road, Velachery')),
          ListTile(
              leading: Icon(Icons.phone_outlined),
              title: Text('+91 98765 43210')),
          ListTile(
              leading: Icon(Icons.schedule_outlined),
              title: Text('7:00 AM – 10:00 PM')),
          ListTile(
              leading: Icon(Icons.delivery_dining_outlined),
              title: Text('Delivery within 2 km')),
        ],
      );
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.subtitle});
  final String title, subtitle;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(
                color: AppColors.lightTextSecondary,
                fontSize: 12,
              )),
        ],
      ),
    );
  }
}
