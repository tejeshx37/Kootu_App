<div align="center">

# 🛒 Kootu

### Hyperlocal social shopping for Indian families

Plan shared shopping lists with your household, discover nearby deals that match
what you actually need, and never miss a local offer again.

[![Flutter](https://img.shields.io/badge/Flutter-3.27+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.6+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20FCM-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](#)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

</div>

---

## Overview

**Kootu** ("கூட்டு" — *together*) is a mobile app that turns the everyday chore
of family shopping into something shared and social. Households create a **Room**,
add items to a collaborative list in real time, and tick things off as they're
bought. In parallel, Kootu surfaces **hyperlocal offers** from nearby merchants
that match the items already on the list — so a reminder to buy rice can quietly
become a deal at the shop down the road.

> The Flutter app is a faithful port of the original React/TSX design prototype
> that lives under [`src/`](src/). The prototype remains in the repo as the visual
> source of truth; the shipping product is the Flutter app under [`lib/`](lib/).

## Features

- 🏠 **Shared rooms** — create a household room, invite members with a 6-character
  code, and collaborate on one live shopping list.
- ✅ **Real-time list** — add items, auto-categorize them by keyword, and check
  them off; every change syncs instantly across all members via Firestore.
- 🎯 **Matched offers** — nearby merchant deals are filtered against your list so
  you only see offers that are actually relevant.
- 🧭 **Explore** — browse local products and services by category.
- 🔔 **Notifications** — offer alerts and room activity in one place.
- 📓 **Notebook UI** — the home list is styled as a ruled notebook page, so adding
  items feels like writing your shopping list by hand.
- 🌗 **Dark mode** — full light/dark theming, persisted across launches.
- 📱 **Phone-OTP auth** — passwordless sign-in with Firebase Phone Authentication.

## Tech stack

| Layer            | Choice                                                            |
| ---------------- | ---------------------------------------------------------------- |
| Framework        | Flutter (Material 3)                                             |
| Language         | Dart                                                             |
| State management | [Riverpod](https://riverpod.dev)                                |
| Navigation       | [go_router](https://pub.dev/packages/go_router) (stateful shell) |
| Auth             | Firebase Authentication (Phone / OTP)                           |
| Database         | Cloud Firestore (real-time)                                      |
| Messaging        | Firebase Cloud Messaging                                         |
| Storage          | Firebase Storage                                                 |
| Location         | [geolocator](https://pub.dev/packages/geolocator)               |
| Typography       | Google Fonts — Nunito (headings) + Plus Jakarta Sans (body)     |

## Getting started

### Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) `>= 3.27` (Dart `>= 3.6`)
- A configured Android device or emulator
- A [Firebase](https://console.firebase.google.com) project with **Phone Auth**,
  **Firestore**, **Storage**, and **FCM** enabled
- [`firebase-tools`](https://firebase.google.com/docs/cli) and the
  [`flutterfire_cli`](https://pub.dev/packages/flutterfire_cli)

### 1. Clone & install

```bash
git clone https://github.com/tejeshx37/Kootu_App.git
cd Kootu_App
flutter pub get
```

### 2. Connect your Firebase project

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=<your-firebase-project>
```

This regenerates `lib/firebase_options.dart` and drops `google-services.json`
under `android/app/`. In the Firebase console, enable the **Phone**, **Email/
Password** and **Google** sign-in providers.

> ℹ️ Firebase Phone Auth requires `minSdkVersion 23` — already set in
> `android/app/build.gradle.kts`.

#### Production auth setup (required for Phone OTP & Google)

Phone OTP and Google sign-in use Google's **Play Integrity / Android Device
Verification**. This **cannot be satisfied from app code** — it requires the
Firebase Console steps below **and a real physical device with Google Play**.
On emulators Play Integrity often returns *17028 Invalid app info in
play_integrity_token* and Firebase falls back to a reCAPTCHA web page (itself
unreliable in partitioned-storage Custom Tabs — *"Unable to process request due
to missing initial state"*). **Use a test phone number on the emulator (step 4)
and a real device for true attestation.**

1. **Register signing fingerprints.** Get them with:
   ```bash
   cd android && ./gradlew signingReport
   ```
   Copy **both** the **SHA-1** and **SHA-256** for the `debug` variant (and later
   your `release` keystore) → Firebase Console → *Project settings* → the
   `com.kootu.kootu` Android app → **Add fingerprint**. Then **re-download
   `google-services.json`** into `android/app/`. Both SHAs are required — a
   missing SHA-256 is the usual cause of *Invalid app info*.

   > Confirm the file matches the Dart config — both must agree:
   > ```bash
   > grep project_number android/app/google-services.json   # 1031395777844
   > ```
   > It must equal `messagingSenderId` in `lib/firebase_options.dart`.

2. **App Check (Play Integrity).** The app already calls
   `FirebaseAppCheck.instance.activate(...)` in `lib/main.dart` (debug provider
   in debug builds, Play Integrity in release). Finish the setup:
   - Enable the **Play Integrity API** in Google Cloud for project `kootuapp`.
   - Firebase Console → **App Check** → register the Android app with the
     **Play Integrity** provider.
   - For emulators/debug builds, run the app once and copy the printed token:
     `DebugAppCheckProvider: Enter this debug secret … <UUID>` → add it under
     *App Check → app → Manage debug tokens*. Otherwise you'll see
     `App attestation failed (403)`.
   - Keep App Check in **monitoring (unenforced)** mode until the Metrics tab
     shows verified requests, then enable **enforcement** for Authentication to
     avoid locking yourself out.

3. **Release signing.** `android/app/build.gradle.kts` reads an optional
   `android/key.properties` (gitignored) and signs release builds with your
   keystore when present, falling back to debug signing otherwise. Create one:
   ```bash
   keytool -genkey -v -keystore ~/kootu-release.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias kootu
   ```
   Then add `android/key.properties`:
   ```properties
   storeFile=/absolute/path/to/kootu-release.jks
   storePassword=••••••
   keyAlias=kootu
   keyPassword=••••••
   ```
   Register the release keystore's SHA-1/256 in Firebase too (step 1).

4. **Unblock dev testing now.** Firebase Console → Authentication → Sign-in
   method → **Phone** → add a **test number** (e.g. `+91 9042512878` →
   `123456`). Test numbers skip SMS + integrity entirely, so you can exercise
   the whole flow while the above propagates.

> 🔒 Never commit `google-services.json`, `key.properties`, or `*.jks` — they
> are already gitignored.

#### Optional: AI item categorization (Gemini)

New list items are auto-categorized. Without a key the app uses a built-in
keyword matcher; provide a Gemini API key to upgrade to AI categorization:

```bash
flutter run --dart-define=GEMINI_API_KEY=your_key_here
```

### 3. Deploy Firestore rules & indexes

```bash
npm i -g firebase-tools
firebase login
firebase use <your-firebase-project>
firebase deploy --only firestore:rules,firestore:indexes
```

### 4. Run

```bash
flutter run -d <android-device>
```

New accounts are bootstrapped automatically: the first sign-in creates the user
document and an empty **Family Room**, then the user is asked for their name (and
locality) before reaching Home. All data is real Firestore data — when a
collection is empty the relevant screen shows a friendly empty state rather than
placeholder content.

The **Offers**, **Explore → Products** and **Explore → Services** screens read
from the `offers`, `serviceCategories` and `serviceProviders` collections. These
are curated server-side (Firebase console / Admin SDK) and are read-only to
clients; until you populate them, those screens show empty states.

## Project structure

```
lib/
  main.dart              # entry: Firebase + SharedPreferences + ProviderScope
  app.dart               # MaterialApp.router + GoRouter (auth redirects)
  core/
    theme/               # design tokens, ColorScheme, TextTheme, shadows
    constants/           # categories + keyword auto-categorizer
    models/              # Room, ListItem, Offer, AppUser, service models
    services/            # Auth, Firestore, Storage, AI categorizer
    providers/           # Riverpod providers (theme / auth / data)
    data/                # mock fixtures (seed + offline fallback)
  features/
    home/                # HomeScreen, AddItemBar, ItemCard, RoomSwitcher
    offers/              # OffersScreen, OfferCard (matched-only filter)
    explore/             # Products / Services tabs, category grid
    profile/             # Profile, Rooms, Nicknames
    auth/                # Onboarding, phone-OTP AuthScreen
    merchant/            # MerchantDash, MerchantProfile
    notifications/       # Offers & Alerts / Room Activity tabs
  shared/widgets/        # bottom_nav, category_tag, notebook_background

firestore.rules          # server-side security rules
firestore.indexes.json   # composite indexes
src/                      # original React/TSX design prototype (reference)
```

## Architecture

- **Riverpod providers** in `core/providers/` expose everything screens need —
  `themeModeProvider`, `authStateProvider`, `roomsProvider`,
  `itemsProvider.family(roomId)`, `offersProvider`, and `matchedOnlyProvider`.
- **All Firestore access is centralized** in `FirestoreService`; widgets never
  touch `FirebaseFirestore.instance` directly.
- **GoRouter** (in `app.dart`) uses a stateful navigation shell for the bottom
  tabs and redirects unauthenticated traffic to onboarding.
- **Theming** lives in `core/theme/`: `app_colors.dart` holds the only hex
  literals (brand teal `#1D9E75`, warm accent `#FF6B35`, paper tokens, shadows),
  and `app_theme.dart` assembles the Material 3 `ThemeData`.

## Security

Because the client can always be bypassed, the real authorization boundary is
[`firestore.rules`](firestore.rules). Notable protections:

- Users can only read/write their own `users/{uid}` document.
- Room data is readable only by its members.
- Invite codes are looked up by exact id only (`list` is denied) to prevent
  enumeration of rooms.
- The join flow lets a new member add only themselves while preserving all
  existing members — no kicking or takeover.

Always review and deploy the rules before pointing the app at a real project.

## Contributing

Contributions are welcome. Please:

1. Fork the repo and create a feature branch.
2. Run `flutter analyze` and `flutter test` before opening a PR.
3. Keep changes focused and describe them clearly in the PR.

## License

Licensed under the **Apache License 2.0** — see [`LICENSE`](LICENSE) for the full
text.

This project includes design components from
[shadcn/ui](https://ui.shadcn.com/) (MIT) and photos from
[Unsplash](https://unsplash.com/license); see [`ATTRIBUTIONS.md`](ATTRIBUTIONS.md).
</content>
</invoke>
