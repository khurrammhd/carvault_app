# CarVault — build notes

## Current state

This project was assembled from a full design → architecture → implementation
pass (see the design docs in `../design_handoff_carvault_app/`). Authentication
is real (Firebase Auth — email/password + Google Sign-In), all local storage
(Drift/SQLite), the camera/document capture flow, search/filter, theming, and
navigation are real.

**One file you must add yourself before this builds: `android/app/google-services.json`**,
downloaded from your Firebase project's console (Project settings → your
Android app). It's git-ignored on purpose (it's project-specific) and the
Google services Gradle plugin (wired into `android/build.gradle.kts` and
`android/app/build.gradle.kts`) will fail the build if it's missing.

A permanent debug keystore lives at `android/keystores/debug.keystore` (checked
into git on purpose — see the comment in `android/app/build.gradle.kts`) so
every build, local or CI, signs identically. This matters specifically for
Google Sign-In, which is tied to the signing certificate's SHA-1 fingerprint —
register this one in your Firebase project (Project settings → your Android
app → SHA certificate fingerprints):

```
07:EC:3D:E6:0C:E0:8D:4A:D5:D8:09:C1:A0:4F:BF:90:9D:6E:0A:1B
```

## Building it

```
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build apk --debug
```

The `build_runner` step generates `lib/core/storage/app_database.g.dart`
(Drift's generated code) — the project will not compile without it.

The resulting APK is at `build/app/outputs/flutter-apk/app-debug.apk`.
Copy it to your phone (or run `flutter install` with the phone connected
over USB with Developer Options + USB debugging enabled) and install it —
you'll need to allow "install from unknown sources" for the first install
since it isn't from the Play Store.

## What works in this build

- Splash → real Firebase login/register/forgot-password/Google Sign-In →
  Dashboard/Vehicles/Profile tab navigation
- Add Vehicle: real camera/gallery capture, a real validated form, and a
  real save (writes to a local SQLite database via Drift)
- Edit Vehicle, and adding further documents to an existing vehicle
- Vehicle List: live search + Buy/Sell/All filtering (filter choice persists
  across app restarts)
- Vehicle Detail: real data, delete (with cascading document cleanup)
- Document Viewer: shows the actual captured photo
- Dashboard: real, live vehicle/document counts

## Known gaps (intentional, not oversights)

- No font assets bundled — text styles fall back to the system default
  (Roboto on Android, so it looks correct there regardless).
- The local SQLite database is not encrypted at rest (relies on Android's
  app sandboxing only) — see the security review for the SQLCipher
  recommendation if you want to add it.
- `core/network/`'s HTTP client (Dio, retry, timeout, token refresh) is
  fully built but not called anywhere — there's no backend yet.
- No signing config exists for a real release build — `buildTypes.release`
  currently reuses the debug signing config, same as Flutter's own default
  template, purely so `flutter build apk --release` doesn't fail. Add a
  real release keystore before ever publishing this anywhere.
