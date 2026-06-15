# Kootu — Flutter port

This Flutter app is a 1:1 functional port of the React/TSX prototype in `src/`.

## Quick start

```bash
flutter pub get
# Wire up Firebase for Android (asia-south1):
#   dart pub global activate flutterfire_cli
#   flutterfire configure --project=<your-firebase-project>
flutter run -d <android-device>
```

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
