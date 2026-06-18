import 'package:flutter/material.dart';

import '../../../core/constants/categories.dart';
import '../../../core/models/list_item.dart';
import '../../../core/theme/app_colors.dart';
import 'category_picker_sheet.dart';

/// Result of editing an item in the sheet.
class ItemEdit {
  const ItemEdit({
    required this.name,
    required this.categoryId,
    required this.quantity,
    required this.note,
  });
  final String name;
  final String categoryId;
  final String quantity;
  final String note;
}

/// Opens an edit sheet for a list item. Returns the edited values, or null if
/// the user dismissed it.
Future<ItemEdit?> showItemEditSheet(
  BuildContext context, {
  required ListItem item,
}) {
  return showModalBottomSheet<ItemEdit>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(ctx).viewInsets.bottom,
      ),
      child: _ItemEditForm(item: item),
    ),
  );
}

class _ItemEditForm extends StatefulWidget {
  const _ItemEditForm({required this.item});
  final ListItem item;

  @override
  State<_ItemEditForm> createState() => _ItemEditFormState();
}

class _ItemEditFormState extends State<_ItemEditForm> {
  late final TextEditingController _nameCtrl =
      TextEditingController(text: widget.item.name);
  late final TextEditingController _qtyCtrl =
      TextEditingController(text: widget.item.quantity ?? '');
  late final TextEditingController _noteCtrl =
      TextEditingController(text: widget.item.note ?? '');
  late String _categoryId = widget.item.categoryId;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(ItemEdit(
      name: name,
      categoryId: _categoryId,
      quantity: _qtyCtrl.text.trim(),
      note: _noteCtrl.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cat = Categories.byId(_categoryId);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit item',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Item name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _qtyCtrl,
              decoration: const InputDecoration(
                labelText: 'Quantity (optional)',
                hintText: 'e.g. 2 kg, 1 packet',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'e.g. the red one',
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: cat.bg,
                child: Text(cat.emoji),
              ),
              title: const Text('Category'),
              subtitle: Text(cat.label),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () async {
                final picked = await showCategoryPicker(context,
                    currentId: _categoryId);
                if (picked != null) setState(() => _categoryId = picked.id);
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
