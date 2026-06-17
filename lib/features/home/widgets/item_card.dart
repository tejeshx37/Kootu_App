import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/categories.dart';
import '../../../core/models/list_item.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/category_tag.dart';
import '../../../shared/widgets/notebook_background.dart';

class ItemCard extends ConsumerWidget {
  const ItemCard({super.key, required this.item, required this.roomId});

  final ListItem item;
  final String roomId;

  String _ago(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat.MMMd().format(t);
  }

  Future<void> _toggle(WidgetRef ref) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await ref.read(firestoreServiceProvider).toggleItemBought(
          roomId: roomId,
          item: item,
          boughtByUserId: user.uid,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cat = Categories.byId(item.categoryId);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Each item reads as a line written in the notebook: no card box, a ruled
    // underline matching the page, the checkbox in the left gutter, and the
    // text starting just to the right of the red margin rule.
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: item.bought ? 0.5 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.fromLTRB(0, 12, 16, 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: NotebookBackground.ruleColor(isDark),
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gutter: checkbox sits left of the margin rule.
            SizedBox(
              width: NotebookBackground.defaultMarginX,
              child: Center(
                child: GestureDetector(
                  onTap: () => _toggle(ref),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          item.bought ? AppColors.success : Colors.transparent,
                      border: Border.all(
                        color: item.bought
                            ? AppColors.success
                            : AppColors.lightTextSecondary,
                        width: 1.6,
                      ),
                      boxShadow: item.bought
                          ? [
                              BoxShadow(
                                color:
                                    AppColors.success.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: item.bought
                        ? const Icon(Icons.check, size: 13, color: Colors.white)
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      decoration: item.bought
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      CategoryTag(category: cat, compact: true),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${item.addedByName} · ${_ago(item.addedAt)}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
