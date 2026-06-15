import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/explore/screens/explore_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/merchant/screens/merchant_dash_screen.dart';
import 'features/merchant/screens/merchant_profile_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/offers/screens/offers_screen.dart';
import 'features/profile/screens/profile_nicknames_screen.dart';
import 'features/profile/screens/profile_rooms_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'shared/widgets/bottom_nav.dart';

class KootuApp extends ConsumerWidget {
  const KootuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final router = _buildRouter(ref);
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

GoRouter _buildRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/home',
    redirect: (ctx, state) {
      final authed = ref.read(authStateProvider).asData?.value != null;
      final atOnboarding = state.matchedLocation == '/onboarding';
      final atAuth = state.matchedLocation == '/auth';
      // For dev convenience we allow unauthenticated browsing (mock data
      // fallbacks are in place). Auth gating can be tightened later by
      // returning '/onboarding' when !authed && !atOnboarding && !atAuth.
      if (atAuth && authed) return '/home';
      if (atOnboarding && authed) return '/home';
      return null;
    },
    routes: [
      GoRoute(
          path: '/onboarding',
          builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
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
          path: '/profile/rooms',
          builder: (_, __) => const ProfileRoomsScreen()),
      GoRoute(
          path: '/profile/nicknames',
          builder: (_, __) => const ProfileNicknamesScreen()),
      GoRoute(
          path: '/notifications',
          builder: (_, __) => const NotificationsScreen()),
      GoRoute(
          path: '/merchant/dash',
          builder: (_, __) => const MerchantDashScreen()),
      GoRoute(
        path: '/merchant/:id',
        builder: (_, st) =>
            MerchantProfileScreen(merchantId: st.pathParameters['id']!),
      ),
    ],
  );
}
