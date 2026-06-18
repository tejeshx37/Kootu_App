import 'package:flutter/material.dart';

import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_colors.dart';

/// A single "top rated service" row: provider avatar, name, tagline, rating
/// and starting price. Used in the Services tab of Explore.
class ServiceProviderTile extends StatelessWidget {
  const ServiceProviderTile({super.key, required this.provider});
  final ServiceProvider provider;

  String _distance() => provider.distanceKm < 1
      ? '${(provider.distanceKm * 1000).round()} m'
      : '${provider.distanceKm.toStringAsFixed(1)} km';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Color(provider.bgArgb),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            alignment: Alignment.center,
            child: Text(provider.emoji,
                style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text(provider.tagline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.lightTextSecondary,
                    )),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 14, color: AppColors.warning),
                    Text(' ${provider.rating.toStringAsFixed(1)}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                    Text(' (${provider.reviews})',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.lightTextSecondary,
                        )),
                    const SizedBox(width: 8),
                    const Icon(Icons.location_on_rounded,
                        size: 12, color: AppColors.lightTextSecondary),
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
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('from',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.lightTextSecondary,
                  )),
              Text('₹${provider.priceFrom}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
