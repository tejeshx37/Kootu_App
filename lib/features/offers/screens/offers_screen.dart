import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/categories.dart';
import '../../../core/models/list_item.dart';
import '../../../core/models/offer.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/offer_card.dart';

const _distanceOptions = [
  ('Any', double.infinity),
  ('<500m', 0.5),
  ('<1km', 1.0),
  ('<2km', 2.0),
];

class OffersScreen extends ConsumerStatefulWidget {
  const OffersScreen({super.key});
  @override
  ConsumerState<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends ConsumerState<OffersScreen> {
  String _selCat = 'all';
  double _maxDistance = double.infinity;

  /// Matched-items filter ported from OffersScreen.tsx — an offer "matches"
  /// when its category appears among the room's item categories, OR when one
  /// of the room's pending item names appears in the offer description.
  List<String> _matchedFor(Offer o, List<ListItem> items) {
    final lowerDesc = o.description.toLowerCase();
    final list = <String>{};
    for (final n in o.matchedItemNames) {
      list.add(n);
    }
    for (final it in items) {
      if (it.bought) continue;
      if (it.categoryId == o.categoryId ||
          lowerDesc.contains(it.name.toLowerCase())) {
        list.add(it.name);
      }
    }
    return list.toList();
  }

  @override
  Widget build(BuildContext context) {
    final roomId = ref.watch(selectedRoomIdProvider);
    final items = ref.watch(itemsProvider(roomId)).asData?.value ?? const [];
    final offersAsync = ref.watch(offersProvider);
    final matchedOnly = ref.watch(matchedOnlyProvider);
    final pendingCount = items.where((i) => !i.bought).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offers'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Text('Matched only',
                    style: TextStyle(fontSize: 12)),
                Switch(
                  value: matchedOnly,
                  onChanged: (v) =>
                      ref.read(matchedOnlyProvider.notifier).state = v,
                ),
              ],
            ),
          ),
        ],
      ),
      body: offersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (offers) {
          final enriched = [
            for (final o in offers)
              (offer: o, matched: _matchedFor(o, items)),
          ];

          var filtered = enriched.where((e) {
            if (_selCat != 'all' && e.offer.categoryId != _selCat) {
              return false;
            }
            if (e.offer.distanceKm > _maxDistance) return false;
            if (matchedOnly && e.matched.isEmpty) return false;
            return true;
          }).toList();

          filtered.sort((a, b) {
            final ma = a.matched.length;
            final mb = b.matched.length;
            if (ma != mb) return mb.compareTo(ma);
            return a.offer.distanceKm.compareTo(b.offer.distanceKm);
          });

          final matchedCount =
              filtered.where((e) => e.matched.isNotEmpty).length;

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Matching against $pendingCount items in your list',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _chip('All', _selCat == 'all',
                        () => setState(() => _selCat = 'all')),
                    for (final c in Categories.all)
                      _chip(c.label, _selCat == c.id,
                          () => setState(() => _selCat = c.id)),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    for (final (label, value) in _distanceOptions)
                      _chip(label, _maxDistance == value,
                          () => setState(() => _maxDistance = value)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No offers match these filters',
                          style: TextStyle(
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: filtered.length + 1,
                        itemBuilder: (ctx, i) {
                          if (i == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                '${filtered.length} offers found · $matchedCount matched your list',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.lightTextSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          final e = filtered[i - 1];
                          return OfferCard(
                              offer: e.offer, matched: e.matched);
                        },
                      ),
              ),
            ],
          );
        },
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
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.primarySoft,
            borderRadius: BorderRadius.circular(AppRadii.pill),
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
