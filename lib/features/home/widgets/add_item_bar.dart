import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/categories.dart';
import '../../../core/models/list_item.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';

class AddItemBar extends ConsumerStatefulWidget {
  const AddItemBar({super.key, required this.roomId});
  final String roomId;

  @override
  ConsumerState<AddItemBar> createState() => _AddItemBarState();
}

class _AddItemBarState extends ConsumerState<AddItemBar> {
  final _ctrl = TextEditingController();
  bool _expanded = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    final cat = Categories.categorizeByKeyword(name);
    final user = FirebaseAuth.instance.currentUser;
    final item = ListItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      categoryId: cat.id,
      addedBy: user?.uid ?? 'me',
      addedByName: user?.displayName ?? 'You',
      addedAt: DateTime.now(),
      bought: false,
    );
    if (user != null) {
      await ref
          .read(firestoreServiceProvider)
          .addItem(widget.roomId, item);
    }
    _ctrl.clear();
    setState(() => _expanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          style: BorderStyle.solid,
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = true),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _ctrl,
              onTap: () => setState(() => _expanded = true),
              onSubmitted: (_) => _submit(),
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: 'Add item or service…',
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_expanded)
            TextButton(
              onPressed: _submit,
              child: const Text('Add'),
            ),
        ],
      ),
    );
  }
}
