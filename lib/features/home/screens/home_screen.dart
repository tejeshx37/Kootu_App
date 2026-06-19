import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/data_providers.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/notebook_background.dart';
import '../widgets/add_item_bar.dart';
import '../widgets/item_card.dart';
import '../widgets/room_switcher.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _firstName(String? full) {
    final trimmed = (full ?? '').trim();
    if (trimmed.isEmpty) return 'there';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomId = ref.watch(selectedRoomIdProvider);
    final itemsAsync = ref.watch(itemsProvider(roomId));
    final me = ref.watch(currentUserProvider).asData?.value;
    final firstName = _firstName(me?.name);

    return Scaffold(
      // Paper backdrop sits behind everything so the whole page reads as a
      // single notebook sheet you're writing your list onto.
      body: Stack(
        children: [
          const Positioned.fill(child: NotebookBackground()),
          SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_greeting()}, $firstName 👋',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        RoomSwitcher(
                          onCreateRoom: () => context.push('/rooms/create'),
                          onJoinRoom: () => context.push('/rooms/join'),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Toggle theme',
                    icon: Icon(
                      Theme.of(context).brightness == Brightness.dark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                    ),
                    onPressed: () =>
                        ref.read(themeModeProvider.notifier).toggle(),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none_rounded),
                        onPressed: () => context.push('/notifications'),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primarySoft,
                      backgroundImage: (me?.photoUrl ?? '').isNotEmpty
                          ? NetworkImage(me!.photoUrl!)
                          : null,
                      child: (me?.photoUrl ?? '').isNotEmpty
                          ? null
                          : Text(
                              firstName.isEmpty
                                  ? '👤'
                                  : firstName[0].toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),

            // Add item bar — the active line you write the next item on.
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
              child: AddItemBar(roomId: roomId),
            ),

            // List
            Expanded(
              child: itemsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => _ItemsError(error: e),
                data: (items) {
                  final pending = items.where((i) => !i.bought).toList();
                  final bought = items.where((i) => i.bought).toList();

                  // Build the written lines (each is exactly one ruled cell).
                  final rows = <Widget>[
                    for (var i = 0; i < pending.length; i++)
                      ItemCard(item: pending[i], roomId: roomId)
                          .animate()
                          .fadeIn(duration: 220.ms, delay: (i * 40).ms)
                          .moveY(begin: 6, end: 0),
                    if (bought.isNotEmpty) ...[
                      const RuledLine(
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(40, 0, 16, 6),
                            child: Text(
                              'BOUGHT',
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w700,
                                color: AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      for (final it in bought)
                        ItemCard(item: it, roomId: roomId),
                    ],
                  ];

                  // Pad the rest of the page with empty ruled lines so the
                  // whole sheet looks like ruled paper, perfectly aligned.
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final used = rows.length * NotebookMetrics.lineHeight;
                      final remaining = constraints.maxHeight - used;
                      final fillers = remaining > 0
                          ? (remaining / NotebookMetrics.lineHeight).ceil()
                          : 0;
                      return ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          ...rows,
                          for (var i = 0; i < fillers; i++) const RuledLine(),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
          ),
        ],
      ),
    );
  }
}

/// Friendly fallback when the items stream fails. The common cause in
/// development is App Check enforcement on Firestore without a registered
/// debug token — we hint at it without dumping the raw SDK string.
class _ItemsError extends StatelessWidget {
  const _ItemsError({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    final msg = error.toString();
    final isPermission = msg.contains('permission-denied');
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded,
              size: 48, color: AppColors.lightTextSecondary),
          const SizedBox(height: 12),
          Text(
            isPermission
                ? "We couldn't access this list right now."
                : "Couldn't load your list.",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Check your connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12, color: AppColors.lightTextSecondary),
          ),
        ],
      ),
    );
  }
}
