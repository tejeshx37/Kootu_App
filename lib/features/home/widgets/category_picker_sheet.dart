import 'package:flutter/material.dart';

import '../../../core/constants/categories.dart';
import '../../../core/theme/app_colors.dart';

/// Bottom sheet that lets the user pick an item category. Returns the chosen
/// [ItemCategory] (or null if dismissed).
Future<ItemCategory?> showCategoryPicker(
  BuildContext context, {
  required String currentId,
}) {
  return showModalBottomSheet<ItemCategory>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Text('Choose a category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          for (final c in Categories.all)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: c.bg,
                child: Text(c.emoji),
              ),
              title: Text(c.label,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: c.id == currentId
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.of(ctx).pop(c),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
