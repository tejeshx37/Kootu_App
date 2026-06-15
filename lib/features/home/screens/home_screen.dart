import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/data_providers.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomId = ref.watch(selectedRoomIdProvider);
    final itemsAsync = ref.watch(itemsProvider(roomId));

    return Scaffold(
      body: SafeArea(
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
                          '${_greeting()}, Priya 👋',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        RoomSwitcher(
                          onCreateRoom: () =>
                              _todo(context, 'Create Room'),
                          onJoinRoom: () => _todo(context, 'Join Room'),
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
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primarySoft,
                      child: Text('👩'),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),

            // Add item bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: AddItemBar(roomId: roomId),
            ),

            // List
            Expanded(
              child: itemsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Failed to load: $e')),
                data: (items) {
                  final pending = items.where((i) => !i.bought).toList();
                  final bought = items.where((i) => i.bought).toList();
                  if (items.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'Nothing on this list yet.\nAdd your first item above.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      for (var i = 0; i < pending.length; i++)
                        ItemCard(item: pending[i], roomId: roomId)
                            .animate()
                            .fadeIn(
                                duration: 220.ms,
                                delay: (i * 40).ms)
                            .moveY(begin: 6, end: 0),
                      if (bought.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
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
                        for (final it in bought)
                          ItemCard(item: it, roomId: roomId),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _todo(BuildContext c, String what) {
    ScaffoldMessenger.of(c).showSnackBar(
      SnackBar(content: Text('$what — coming soon')),
    );
  }
}
