import 'package:flutter/material.dart';

import '../../core/constants/categories.dart';
import '../../core/theme/app_colors.dart';

class CategoryTag extends StatelessWidget {
  const CategoryTag({super.key, required this.category, this.compact = false});

  final ItemCategory category;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final pad = compact
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
    return Container(
      padding: pad,
      decoration: BoxDecoration(
        color: category.bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.emoji, style: TextStyle(fontSize: compact ? 11 : 12)),
          const SizedBox(width: 4),
          Text(
            category.label,
            style: TextStyle(
              color: category.color,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }
}
