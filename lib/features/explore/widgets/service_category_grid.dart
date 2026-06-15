import 'package:flutter/material.dart';

import '../../../core/data/mock_data.dart';
import '../../../core/theme/app_colors.dart';

class ServiceCategoryGrid extends StatelessWidget {
  const ServiceCategoryGrid({super.key, this.onTap});
  final void Function(ServiceCategory)? onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        for (final c in MockData.serviceCategories)
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
  }
}
