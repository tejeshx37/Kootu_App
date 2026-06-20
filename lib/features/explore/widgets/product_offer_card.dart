import 'package:flutter/material.dart';

import '../../../core/constants/categories.dart';
import '../../../core/models/offer.dart';
import '../../../core/theme/app_colors.dart';

class ProductOfferCard extends StatelessWidget {
  const ProductOfferCard({
    super.key,
    required this.offer,
    this.overrideDistanceKm,
  });
  final Offer offer;

  /// When non-null, displays this instead of the offer's stored distance.
  /// Explore uses it to show GPS-computed distance to the merchant.
  final double? overrideDistanceKm;

  String _distance() {
    final d = overrideDistanceKm ?? offer.distanceKm;
    return d < 1 ? '${(d * 1000).round()} m' : '${d.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final cat = Categories.byId(offer.categoryId);
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: cat.bg,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            alignment: Alignment.center,
            child: Text(cat.emoji,
                style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(height: 8),
          Text(offer.merchantName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13)),
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  size: 12, color: AppColors.warning),
              Text(' ${offer.rating.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 11)),
              const SizedBox(width: 6),
              Text(_distance(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.lightTextSecondary,
                  )),
            ],
          ),
          const SizedBox(height: 6),
          Text(offer.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          Text('Save ₹${offer.savings}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}
