import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/providers/auth_provider.dart';
import 'core/providers/data_providers.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/auth/screens/set_name_screen.dart';
import 'features/explore/screens/explore_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/offers/screens/offers_screen.dart';
import 'features/profile/screens/edit_profile_screen.dart';
import 'features/profile/screens/profile_nicknames_screen.dart';
import 'features/profile/screens/profile_rooms_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/rooms/screens/create_room_screen.dart';
import 'features/rooms/screens/join_room_screen.dart';
import 'shared/widgets/bottom_nav.dart';

class KootuApp extends ConsumerWidget {
  const KootuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Kootu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
      routerConfig: router,
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    redirect: (ctx, state) {
      final auth = ref.watch(authStateProvider);
      // Wait for the auth stream's first event before redirecting so we don't
      // bounce off /home into /onboarding on cold start.
      if (auth.isLoading) return null;
      final authed = auth.asData?.value != null;
      final loc = state.matchedLocation;
      final atGate = loc == '/auth' || loc == '/onboarding';

      if (!authed) {
        return atGate ? null : '/onboarding';
      }

      // Signed in: force the set-name step once, until a name exists on the
      // Firestore profile. Don't bounce while the user doc is still loading.
      final userAsync = ref.watch(currentUserProvider);
      final atSetName = loc == '/auth/set-name';
      if (userAsync.hasValue) {
        final appUser = userAsync.value;
        final needsName = appUser == null || appUser.name.trim().isEmpty;
        if (needsName) return atSetName ? null : '/auth/set-name';
      } else {
        // user doc not resolved yet; allow the current location.
        return null;
      }

      if (atGate || atSetName) return '/home';
      return null;
    },
    routes: [
      GoRoute(
          path: '/onboarding',
          builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
      GoRoute(
          path: '/auth/set-name', builder: (_, __) => const SetNameScreen()),
      StatefulShellRoute.indexedStack(
        builder: (ctx, state, shell) =>
            BottomNavScaffold(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/offers', builder: (_, __) => const OffersScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/explore', builder: (_, __) => const ExploreScreen()),
          ]),
        ],
      ),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(
          path: '/profile/edit',
          builder: (_, __) => const EditProfileScreen()),
      GoRoute(
          path: '/profile/rooms',
          builder: (_, __) => const ProfileRoomsScreen()),
      GoRoute(
          path: '/rooms/create',
          builder: (_, __) => const CreateRoomScreen()),
      GoRoute(
          path: '/rooms/join',
          builder: (_, __) => const JoinRoomScreen()),
      GoRoute(
          path: '/profile/nicknames',
          builder: (_, __) => const ProfileNicknamesScreen()),
      GoRoute(
          path: '/notifications',
          builder: (_, __) => const NotificationsScreen()),
    ],
  );
});
