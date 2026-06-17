import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/room.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/theme/app_colors.dart';

class RoomSwitcher extends ConsumerWidget {
  const RoomSwitcher({
    super.key,
    required this.onCreateRoom,
    required this.onJoinRoom,
  });

  final VoidCallback onCreateRoom;
  final VoidCallback onJoinRoom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedRoomProvider);
    final rooms = ref.watch(roomsProvider).asData?.value ?? const <Room>[];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      onTap: () => _showSheet(context, ref, rooms),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: AppGradients.brand,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          boxShadow: AppShadows.brand(isDark),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selected?.emoji ?? '🏠',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              selected?.name ?? 'Pick a room',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  void _showSheet(BuildContext context, WidgetRef ref, List<Room> rooms) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Text('Your rooms',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                for (final r in rooms)
                  ListTile(
                    leading:
                        Text(r.emoji, style: const TextStyle(fontSize: 22)),
                    title: Text(r.name,
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        '${r.memberIds.length} members · ${r.neededCount} needed'),
                    onTap: () {
                      ref.read(selectedRoomIdProvider.notifier).state = r.id;
                      Navigator.pop(sheetCtx);
                    },
                  ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.add_rounded,
                      color: AppColors.primary),
                  title: const Text('Create room'),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    onCreateRoom();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.group_add_rounded,
                      color: AppColors.primary),
                  title: const Text('Join room'),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    onJoinRoom();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
