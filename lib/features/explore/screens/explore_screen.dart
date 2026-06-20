import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/constants/categories.dart';
import '../../../core/models/merchant.dart';
import '../../../core/models/offer.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../widgets/product_offer_card.dart';
import '../widgets/service_category_grid.dart';
import '../widgets/service_provider_tile.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});
  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String _selCat = 'all';

  /// Computes the GPS distance (km) from the user to the merchant behind an
  /// offer. Returns null when either position is unknown so the card can fall
  /// back to the offer's stored `distanceKm`.
  double? _distanceFor(Offer o, Position? pos, Map<String, Merchant> byId) {
    if (pos == null) return null;
    final m = byId[o.merchantId];
    if (m == null) return null;
    return Geolocator.distanceBetween(pos.latitude, pos.longitude, m.lat, m.lng) /
        1000.0;
  }

  @override
  Widget build(BuildContext context) {
    final offers = ref.watch(offersProvider).asData?.value ?? const [];
    final providers =
        ref.watch(serviceProvidersProvider).asData?.value ?? const [];
    final locality = ref.watch(currentUserProvider).asData?.value?.locality;
    final userPos = ref.watch(userLocationProvider).asData?.value;
    final merchants =
        ref.watch(merchantsProvider).asData?.value ?? const <Merchant>[];
    final byId = {for (final m in merchants) m.id: m};

    final categoryFiltered = _selCat == 'all'
        ? offers
        : offers.where((o) => o.categoryId == _selCat).toList();

    // Attach GPS-computed distance per offer; sort ascending. Offers with no
    // merchant record fall back to their stored `distanceKm` for sorting.
    final ranked = [
      for (final o in categoryFiltered)
        (offer: o, distanceKm: _distanceFor(o, userPos, byId)),
    ]..sort((a, b) {
        final da = a.distanceKm ?? a.offer.distanceKm;
        final db = b.distanceKm ?? b.offer.distanceKm;
        return da.compareTo(db);
      });
    final filtered = ranked;
    final featured = [
      for (final o in offers)
        (offer: o, distanceKm: _distanceFor(o, userPos, byId)),
    ]..sort((a, b) {
        final da = a.distanceKm ?? a.offer.distanceKm;
        final db = b.distanceKm ?? b.offer.distanceKm;
        return da.compareTo(db);
      });

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 20, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                        (locality != null && locality.isNotEmpty)
                            ? locality
                            : 'Your area',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              TabBar(
                labelColor: AppColors.primary,
                indicatorColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Theme.of(context).colorScheme.outline,
                labelStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Products'),
                  Tab(text: 'Services'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Products tab
                    Column(
                      children: [
                        const SizedBox(height: 14),
                        _FadingHScroll(
                          child: SizedBox(
                            height: 40,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12),
                              children: [
                                _chip('All', _selCat == 'all',
                                    () => setState(() => _selCat = 'all')),
                                for (final c in Categories.all)
                                  _chip(c.label, _selCat == c.id,
                                      () => setState(() => _selCat = c.id)),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: filtered.isEmpty
                              ? const Center(
                                  child: EmptyState(
                                    icon: Icons.local_offer_outlined,
                                    title: 'No offers nearby yet',
                                    message:
                                        'Deals from local shops will show up here. Check back soon!',
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 8, 16, 16),
                                  itemCount: filtered.length,
                                  itemBuilder: (ctx, i) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12),
                                    child: ProductOfferCard(
                                      offer: filtered[i].offer,
                                      overrideDistanceKm:
                                          filtered[i].distanceKm,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                    // Services tab
                    ListView(
                      padding: const EdgeInsets.only(top: 16, bottom: 24),
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search services…',
                              prefixIcon:
                                  const Icon(Icons.search_rounded),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.mic_rounded),
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const ServiceCategoryGrid(),
                        if (offers.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Text('Featured nearby',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)),
                          ),
                          SizedBox(
                            height: 210,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              itemCount: featured.length,
                              itemBuilder: (ctx, i) => ProductOfferCard(
                                offer: featured[i].offer,
                                overrideDistanceKm: featured[i].distanceKm,
                              ),
                            ),
                          ),
                        ],
                        if (providers.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Text('Top rated services',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                for (final p in providers)
                                  ServiceProviderTile(provider: p),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.primarySoft,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow:
                active ? AppShadows.brand(false) : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _FadingHScroll extends StatelessWidget {
  const _FadingHScroll({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        stops: [0.0, 0.92, 1.0],
        colors: [Colors.black, Colors.black, Colors.transparent],
      ).createShader(rect),
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}

