import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/service_models.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';

class ServiceCategoryGrid extends ConsumerWidget {
  const ServiceCategoryGrid({super.key, this.onTap});
  final void Function(ServiceCategory)? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(serviceCategoriesProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => const EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Couldn\'t load services',
        message: 'Please check your connection and try again.',
        compact: true,
      ),
      data: (categories) {
        if (categories.isEmpty) {
          return const EmptyState(
            icon: Icons.handyman_outlined,
            title: 'No services yet',
            message: 'Local services will appear here as they come online.',
            compact: true,
          );
        }
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            for (final c in categories)
              GestureDetector(
                onTap: () => onTap?.call(c),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Color(c.bgArgb),
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      ),
                      alignment: Alignment.center,
                      child: Text(c.emoji,
                          style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      c.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
