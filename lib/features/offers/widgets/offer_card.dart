import 'package:flutter/material.dart';

import '../../../core/constants/categories.dart';
import '../../../core/models/offer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/category_tag.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offer, required this.matched});

  final Offer offer;
  final List<String> matched;

  String _remaining() {
    final d = offer.validUntil.difference(DateTime.now());
    if (d.isNegative) return 'Expired';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return 'Ends in ${h}h ${m}m';
    return 'Ends in ${m}m';
  }

  String _distance() {
    if (offer.distanceKm < 1) {
      return '${(offer.distanceKm * 1000).round()} m';
    }
    return '${offer.distanceKm.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final cat = Categories.byId(offer.categoryId);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: scheme.outline),
        boxShadow: AppShadows.card(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: cat.bg,
                child: Text(cat.emoji),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(offer.merchantName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 14, color: AppColors.warning),
                        const SizedBox(width: 2),
                        Text(offer.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 11)),
                        const SizedBox(width: 8),
                        Text(_distance(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.lightTextSecondary,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              CategoryTag(category: cat, compact: true),
            ],
          ),
          const SizedBox(height: 10),
          Text(offer.description,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (matched.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppRadii.xs),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final n in matched)
                    Text('✓ $n',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        )),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  'Save ₹${offer.savings}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const Spacer(),
              Text(_remaining(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
          if (offer.nearby) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                gradient: AppGradients.brand,
                borderRadius: BorderRadius.circular(AppRadii.sm),
                boxShadow: AppShadows.brand(isDark),
              ),
              child: const Row(
                children: [
                  Icon(Icons.near_me_rounded,
                      size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    "You're nearby — visit now!",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
