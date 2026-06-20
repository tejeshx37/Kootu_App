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
- 🔐 **Auth** — Email/Password + one-tap Google sign-in. (A serverless phone-OTP
  backend ships in [`functions/`](functions/) for future re-enable once DLT
  registration is in place — see "Phone OTP backend".)

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

#### Phone OTP backend (MSG91 + Cloud Functions) — _not wired in v1_

> Phone OTP is **not** exposed in the v1 sign-in screen. Sending SMS to Indian
> numbers requires TRAI/DLT registration (entity, header, content template),
> and that's deferred. The backend below ships ready-to-deploy; to turn it on,
> add `cloud_functions` to `pubspec.yaml`, restore the `sendPhoneOtp` /
> `signInWithPhoneOtp` methods on `AuthService` (see git history), and re-add a
> phone tab to `AuthScreen`. Until DLT is approved, Email + Google are the
> shipping sign-in methods.

The design avoids Firebase's client-side phone auth (which relies on Play
Integrity, rejecting unpublished/sideloaded builds with *"app not Recognized
by Play Store"* and falling back to a flaky reCAPTCHA web page).
Instead Kootu owns the OTP via two Cloud Functions in [`functions/`](functions/):

- `sendOtp(phone)` — generates a 6-digit code, stores a salted HMAC in
  `otps/{phone}` (TTL + attempt limit), and sends the SMS through **MSG91**.
- `verifyOtp(phone, code)` — checks the code and returns a Firebase **custom
  token**; the app calls `signInWithCustomToken`, so all Firestore rules and
  user docs keyed on `request.auth.uid` keep working unchanged.

This works on **any build (incl. debug)** with no Play Integrity and no browser.

**Setup:**

1. **Install & pick a region.** The client calls functions in `us-central1`
   (see `FirebaseFunctions.instance`); the functions declare the same region.
   ```bash
   cd functions && npm install
   ```

2. **MSG91 (India SMS gateway).** Create an MSG91 account, complete **DLT**
   registration, and create an **OTP flow/template**. Note your **authkey**,
   **sender id** (6 chars, e.g. `KOOTUA`) and **template id**. Set the sender +
   template at the top of `functions/index.js` (or via `MSG91_SENDER` /
   `MSG91_TEMPLATE_ID` env), and store secrets (never commit them):
   ```bash
   firebase functions:secrets:set MSG91_AUTHKEY   # paste your MSG91 authkey
   firebase functions:secrets:set OTP_PEPPER      # any long random string
   ```

3. **Deploy.**
   ```bash
   firebase deploy --only functions,firestore:rules
   ```
   The `otps/{phone}` collection is denied to all clients in
   `firestore.rules` — only the Admin SDK (these functions) touches it.

4. **Swap provider (optional).** To use Twilio/Gupshup instead of MSG91,
   replace the single `fetch(...)` block in `sendOtp` — the OTP generation,
   storage, verification and token minting stay identical.

> Email/Password and Google sign-in still use Firebase Auth directly and need
> no SMS/attestation setup. If you enable **App Check enforcement** for
> Authentication, register your debug token first (logcat → *Enter this debug
> secret*) or those two methods will fail with `App Check token is invalid`.

#### Release signing

1. **Release signing.** `android/app/build.gradle.kts` reads an optional
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
   Register the release keystore's SHA-1/256 in Firebase too (for Google
   sign-in, which still uses Firebase Auth directly).

> 🔒 Never commit `google-services.json`, `key.properties`, `*.jks`, or the
> MSG91/OTP secrets — they are gitignored or stored as Functions secrets.

#### Optional: AI item categorization (Gemini)

New list items are auto-categorized. Without a key the app uses a built-in
keyword matcher; provide a [Gemini API key](https://aistudio.google.com/app/apikey)
to upgrade to AI categorization.

Persist the key locally so you don't retype it every run:

```bash
cp dart_defines.example.json dart_defines.json   # one-time
# edit dart_defines.json and paste your real key
flutter run --dart-define-from-file=dart_defines.json
```

`dart_defines.json` is gitignored — your key never leaves your machine.
The committed `dart_defines.example.json` only shows the file shape.

> 🔒 If you ever accidentally paste a real key into chat, a screenshot, or a
> commit, **revoke it immediately** at the link above and generate a fresh one.

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
  `itemsProvider.family(roomId)`, `offersProvider`, `merchantsProvider`, and
  `userLocationProvider`.
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
