# Kootu — Flutter port

This Flutter app is a 1:1 functional port of the React/TSX prototype in `src/`.

## Quick start

```bash
# 1. Scaffold the Android side (one-time, if android/ is missing):
flutter create . --platforms=android --org com.kootu

# 2. Wire up Firebase (asia-south1):
#    - In Firebase console: create project, enable Auth (Phone),
#      Firestore, Storage, FCM. Add test number +91 9999999999 → 123456.
dart pub global activate flutterfire_cli
flutterfire configure --project=<your-firebase-project>
# This rewrites lib/firebase_options.dart and drops google-services.json
# under android/app/. Then bump android/app/build.gradle minSdkVersion to 23
# (Firebase Auth requires it).

# 3. Deploy Firestore rules + indexes (requires firebase-tools):
npm i -g firebase-tools
firebase login
firebase use <your-firebase-project>
firebase deploy --only firestore:rules,firestore:indexes

# 4. Run on device:
flutter pub get
flutter run -d <android-device>
```

### What's wired up

- Phone-OTP sign-in via `AuthService.verifyPhone` / `signInWithSmsCode`.
- First sign-in calls `FirestoreService.bootstrapNewUser` which creates
  `users/{uid}` with zero rooms — brand-new accounts start blank and create
  or join a room explicitly from Home.
- The router (in `app.dart`) redirects unauthenticated traffic to
  `/onboarding`. Mock data still backs every signed-out preview.
- `firestore.rules` + `firestore.indexes.json` ship at the repo root.

## Project layout

```
lib/
  main.dart              # entry: Firebase + SharedPreferences + ProviderScope
  app.dart               # MaterialApp.router + GoRouter
  core/
    theme/               # tokens, ColorScheme, TextTheme
    constants/           # CATEGORIES + KEYWORDS auto-categorizer
    models/              # Room, ListItem, Offer, AppUser
    services/            # AuthService, FirestoreService
    providers/           # Riverpod providers (theme/auth/data)
    data/                # mock fixtures (seed + fallback)
  features/
    home/                # HomeScreen, AddItemBar, ItemCard, RoomSwitcher
    offers/              # OffersScreen, OfferCard (matched-only filter)
    explore/             # Products/Services tabs, grid, cards
    profile/             # Profile, Rooms, Nicknames
    auth/                # Onboarding (3-slide), AuthScreen (phone OTP)
    merchant/            # MerchantDash, MerchantProfile
    notifications/       # Tabs: Offers & Alerts / Room Activity
  shared/widgets/        # bottom_nav, category_tag
```

## State & data flow

- `flutter_riverpod` providers in `core/providers/` expose everything
  screens need (`themeModeProvider`, `authStateProvider`,
  `roomsProvider`, `itemsProvider.family(roomId)`,
  `offersProvider`, `matchedOnlyProvider`).
- All Firestore I/O lives in `FirestoreService`. Widgets never touch
  `FirebaseFirestore.instance` directly.
- When Firestore returns empty (e.g. before backend seeding), providers
  fall back to `MockData` so screens are never blank.

## Theming

`app_colors.dart` holds the only hex literals — primary teal `#1D9E75`,
warm accent `#FF6B35`, success/warning/error, and light/dark surfaces.
`app_theme.dart` builds `ColorScheme`s, `TextTheme` (Nunito headings +
Plus Jakarta Sans body), and component themes. Dark mode is persisted
via `SharedPreferences` (the React prototype lost it on refresh).
