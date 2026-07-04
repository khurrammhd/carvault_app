# CarVault — build notes

## Current state

This project was assembled from a full design → architecture → implementation
pass (see the design docs in `../design_handoff_carvault_app/`). It is a real,
complete Flutter project — not a prototype — with one deliberate exception:
**there is no real Firebase project configured yet**, so authentication runs
on `FakeAuthRepository` (in-memory, accepts any email/password) instead of
real Firebase Auth. Everything else — local SQLite storage via Drift, the
camera/document capture flow, search/filter, theming, navigation — is real.

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

- Splash → fake login/register/forgot-password → Dashboard/Vehicles/Profile
  tab navigation
- Add Vehicle: real camera/gallery capture, a real validated form, and a
  real save (writes to a local SQLite database via Drift)
- Vehicle List: live search + Buy/Sell/All filtering (filter choice persists
  across app restarts)
- Vehicle Detail: real data, delete (with cascading document cleanup)
- Document Viewer: shows the actual captured photo
- Dashboard: real, live vehicle/document counts

## Wiring up real Firebase

When you're ready to replace the fake auth:

1. Create a Firebase project at https://console.firebase.google.com and add
   an Android app with package name `com.carvault.carvault`.
2. Run `flutterfire configure` in this directory (installs `firebase_options.dart`).
3. Add to `pubspec.yaml`:
   ```
   firebase_core: ^3.8.0
   firebase_auth: ^5.3.3
   firebase_crashlytics: ^4.1.5
   google_sign_in: ^6.2.2
   ```
4. Replace `lib/features/auth/data/repositories/fake_auth_repository.dart`'s
   `authRepositoryProvider` binding with a real Firebase-backed
   `AuthRepositoryImpl` (wraps `FirebaseAuth` calls, translates
   `FirebaseAuthException` into `AuthFailure`s the same way `FakeAuthRepository`
   returns `Success`/`Failed`). Nothing in `core/routing`, the auth use cases,
   or any screen needs to change — they only depend on the `AuthRepository`
   interface.
5. Restore `Firebase.initializeApp(...)` + Crashlytics wiring in
   `lib/bootstrap.dart`.
6. Swap `core/network/auth_token_provider.dart`'s `FakeAuthTokenProvider` for
   a real Firebase ID-token-backed implementation if/when the (currently
   unused) `core/network/` HTTP client gets a real backend to call.

## Known gaps (intentional, not oversights)

- No font assets bundled — text styles fall back to the system default
  (Roboto on Android, so it looks correct there regardless).
- The local SQLite database is not encrypted at rest (relies on Android's
  app sandboxing only) — see the security review for the SQLCipher
  recommendation if you want to add it.
- `core/network/`'s HTTP client (Dio, retry, timeout, token refresh) is
  fully built but not called anywhere — there's no backend yet.
