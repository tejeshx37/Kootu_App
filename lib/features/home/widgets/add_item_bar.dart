import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/categories.dart';
import '../../../core/models/list_item.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/notebook_background.dart';

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

  String _displayName(User? user) {
    final name = user?.displayName;
    if (name != null && name.isNotEmpty) return name;
    final phone = user?.phoneNumber;
    if (phone != null && phone.length >= 4) {
      return 'User ${phone.substring(phone.length - 4)}';
    }
    return 'You';
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
      addedByName: _displayName(user),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // The active writing line: a ruled underline (highlighted while focused)
    // with the + in the gutter, so adding an item feels like writing the next
    // line on the page.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.only(right: 12, top: 4, bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _expanded
                ? AppColors.primary
                : NotebookBackground.ruleColor(isDark),
            width: _expanded ? 1.6 : 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Gutter: + button sits left of the margin rule, like the checkboxes.
          SizedBox(
            width: NotebookBackground.defaultMarginX,
            child: Center(
              child: InkWell(
                onTap: () => setState(() => _expanded = true),
                borderRadius: BorderRadius.circular(AppRadii.pill),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: AppGradients.brand,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.brand(isDark),
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 17),
                ),
              ),
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
