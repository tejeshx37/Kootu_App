import 'package:flutter/material.dart';

import '../../../core/constants/categories.dart';
import '../../../core/theme/app_colors.dart';

/// Bottom sheet that lets the user pick an item category. Returns the chosen
/// [ItemCategory] (or null if dismissed). Scrollable + height-capped so the
/// full category list never overflows on small screens.
Future<ItemCategory?> showCategoryPicker(
  BuildContext context, {
  required String currentId,
}) {
  return showModalBottomSheet<ItemCategory>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      final maxHeight = MediaQuery.of(ctx).size.height * 0.7;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Text('Choose a category',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 8),
                  children: [
                    for (final c in Categories.all)
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: c.bg,
                          child: Text(c.emoji),
                        ),
                        title: Text(c.label,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: c.id == currentId
                            ? const Icon(Icons.check_circle,
                                color: AppColors.primary)
                            : null,
                        onTap: () => Navigator.of(ctx).pop(c),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
