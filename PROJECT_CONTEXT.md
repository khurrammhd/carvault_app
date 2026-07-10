# PROJECT_CONTEXT.md

> **Purpose:** a running summary of this project for future Claude Code sessions (or human contributors) to get oriented quickly without re-reading the whole conversation history. Update this file whenever a significant change is made.
>
> **Last updated:** 2026-07-10

---

## 1. Project Goals

**CarVault — Vehicle Document Manager.** A mobile app that lets a vehicle owner or small used-car reseller photograph and store every document tied to each of their vehicles (registration certificate, plus any other paperwork), organize vehicles by **Buy/Sell** category, and instantly find any document by searching a registration number.

- Source of truth for intended design: `../design_handoff_carvault_app/` — `README.md` (screen-by-screen spec), `Car Docs App.dc.html` (interactive prototype), `CarVault Product Spec.dc.html` (PRD), design tokens (colors/type/spacing), `screenshots/`.
- Two personas: **Aria** (private owner, opens the app a few times a year) and **Devan** (reseller, 10–15 vehicles/year, uses the app weekly).
- v1 was originally local-first with no multi-device sync; **that's since expanded** — the app now has a second network dependency, a WhatsApp-style scheduled backup of all vehicle/document data to the user's own Google Drive (one-way backup + manual restore, not live multi-device sync). See §3/§5/§6.
- Goal: capture a document in under 30 seconds; find any vehicle's documents in one search.

---

## 2. Architecture Decisions

| Concern | Choice | Why |
|---|---|---|
| Framework | **Flutter** (Dart) | Single codebase for the Material 3 design spec targeting both Android and iOS |
| Backend | **Firebase** (Auth + Crashlytics only) | Only real network need is auth; no custom API in v1 |
| State management / DI | **Riverpod** (`flutter_riverpod`) | Providers double as the DI graph; no separate service locator |
| Routing | **go_router** | `StatefulShellRoute.indexedStack` for the Home/Vehicles/Profile bottom nav; Add Vehicle's 3 steps are nested `GoRoute`s (not internal step state) so hardware/gesture back steps backward correctly |
| Local database | **Drift** (SQLite) | Relational fit for `Vehicle 1—N Document`; reactive `Stream` queries back live UI updates |
| Document images | Local file system (`path_provider`) | Drift stores only a file path; images live in app-private storage |
| Secure cache | `flutter_secure_storage` | Caches the last signed-in user (email/id) for instant "welcome back" reads — **not** where the real session lives (Firebase's SDK owns that) |
| Simple prefs | `shared_preferences` | One real use today: persisting the Vehicle List filter choice |
| Networking | `dio`-based `ApiClient` with retry/timeout/auth/token-refresh/logging interceptors | **Built but not called by any feature** — there's no backend yet; this is the ready seam for when one exists |
| Error handling | Custom sealed `Result<T>` / `Failure` types (`core/errors/`) | Every repository method returns `Result<T>`, forcing explicit success/failure handling; `Failure` subtypes: `AuthFailure`, `ValidationFailure`, `NetworkFailure`, `UnexpectedFailure` |
| Folder structure | **Feature-first** (`lib/features/<feature>/{domain,data,presentation}`) + `lib/core/` for cross-cutting code | Scales better than layer-first as features grow; each feature is self-contained |
| Clean architecture | Domain (entities, repository interfaces, use cases) → Data (models, datasources, repository impls) → Presentation (providers, screens, widgets) | Domain never imports Firebase/Drift/Dio; only the data layer touches those |
| Cloud backup | `archive` (zip/unzip) + `googleapis`/`googleapis_auth` (Drive v3 client) + `extension_google_sign_in_as_googleapis_auth` (turns the existing `google_sign_in` session into an authenticated client) + `workmanager: ^0.9.0+3` (daily scheduling — bumped from an initial `0.5.2`, see §8.7) | Backs up the local DB + document images to the user's own Google Drive on a schedule; reuses the existing Firebase Auth / Google Sign-In session rather than a new backend |

**Deliberate exceptions to "core never depends on features":** `core/routing/auth_state_provider.dart` and `core/storage/secure_session_storage.dart` both depend on the auth feature's concrete types. This is intentional — routing/session-caching are cross-feature composition concerns, not reusable domain-agnostic code. The `backup` feature adds two more: `data/repositories/drive_auth_repository_impl.dart` and `data/repositories/backup_repository_impl.dart` both depend directly on `auth`'s concrete `FirebaseAuthDataSource`/`AuthRepository` — connecting Drive is inherently a composition of "which Google account" (auth) and "what to back up" (backup).

---

## 3. Features Implemented

- **Auth:** Splash → Login / Register / Forgot Password → Dashboard, all backed by **real Firebase Auth** (email/password + Google Sign-In). Session state is reactive end-to-end (login/logout anywhere immediately redirects the whole app via the router's `redirect` + `ref.listen`).
- **Dashboard:** live vehicle/document counts, time-of-day greeting, avatar initials derived from the signed-in user, up to 3 recent vehicles, loading skeleton, empty state, FAB → Add Vehicle.
- **Vehicle List:** live search (reg. number/make/model) + Buy/Sell/All filter chips (filter choice persists via `shared_preferences`).
- **Vehicle Detail:** full vehicle info, document list, **Edit** (pencil icon → `EditVehicleScreen`), **Add Document** (camera/gallery → attaches to the existing vehicle), **Delete Vehicle** (cascades documents + cached files), Share is a stub.
- **Add Vehicle** (3 steps, each its own route for correct back-stack behavior): Capture (camera/gallery via `image_picker`) → Details (validated form, only reg. number required) → Review → Save (writes to Drift + copies the photo into the file cache).
- **Document Viewer:** shows the real captured photo full-screen with metadata.
- **Profile:** shows signed-in email, real Log Out.
- **Bottom nav:** Home / Vehicles / Profile, each its own independent navigation stack.
- **Native + Flutter splash screens:** both branded (background color + app-mark badge with car glyph) so there's no white flash before Flutter loads.
- **Backup & Restore (Google Drive):** WhatsApp-style scheduled one-way backup + manual restore, not live multi-device sync. Connect Google Drive from Settings (incremental consent for Google-signed-in users, a separate Drive-only Google sign-in for email/password users that doesn't touch their Firebase identity) → daily backup at a user-chosen time via a self-rescheduling WorkManager task → zips the local DB + document images into one file, uploaded to a visible "CarVault Backups" folder in the user's own Drive (`drive.file` scope), atomically replacing the previous backup each run. A one-time "back up to Google Drive?" prompt appears on the Dashboard right after registration. Settings screen: enable/disable, connect/disconnect, backup time picker, "Back up now", "Restore latest backup" (behind a confirmation dialog — replaces all local data).

**Explicitly not implemented (by design, not oversight):** onboarding (not in the design docs — user confirmed skip), deep links (nothing needs them yet, but the router is deep-link-ready), document deletion UI (use case exists, no screen wires it), delete-vehicle confirmation dialog, Share functionality, biometric app lock, automatic "restore backup?" prompt on fresh install (backup's restore is manual-only for v1 — see §7).

---

## 4. Files Created or Modified (structure as of last update)

```
carvault_app/
├── NOTES.md                      # build/setup notes, Firebase wiring status
├── PROJECT_CONTEXT.md            # this file
├── android/
│   ├── build.gradle.kts          # + Google services plugin
│   ├── app/
│   │   ├── build.gradle.kts      # + google-services plugin, permanent debug signing config
│   │   ├── google-services.json  # real Firebase config, committed (public repo — see §6)
│   │   └── src/main/res/drawable*/launch_background.xml, launch_badge.xml, ic_launch_car.xml
│   └── keystores/debug.keystore  # permanent, committed debug keystore (see §6)
├── lib/
│   ├── main.dart, bootstrap.dart, app/app.dart
│   ├── core/
│   │   ├── config/environment.dart          # dev/production flavor switch
│   │   ├── constants/app_constants.dart      # spacing/radius/size tokens
│   │   ├── errors/{failure,result,unit}.dart # Result<T>/Failure vocabulary
│   │   ├── logging/app_logger.dart
│   │   ├── network/                          # ApiClient + interceptors — built, unused
│   │   ├── routing/{app_router,auth_state_provider,route_paths}.dart
│   │   ├── storage/{app_database,app_preferences,document_file_cache,secure_session_storage}.dart
│   │   ├── theme/{app_colors,app_text_styles,app_theme,app_theme_extension}.dart
│   │   ├── utils/{id_generator,validators}.dart
│   │   └── widgets/{buttons,inputs,nav}/      # shared design-system components
│   └── features/
│       ├── auth/           # domain + data + presentation — real Firebase Auth
│       ├── backup/          # domain + data + presentation — Google Drive backup/restore + Settings screen
│       ├── dashboard/       # domain + presentation (composes vehicles feature)
│       ├── documents/       # Document Viewer screen
│       ├── profile/         # Profile screen
│       └── vehicles/        # domain + data + presentation — vehicles/documents CRUD
└── test/
    └── result_dynamic_typing_test.dart  # regression test for the AuthController bug (§8)
```

Full current file list: run `find lib -name "*.dart"` from the project root (grew past 92 Dart files with the backup feature — re-run to get the current count).

**Notable file-level history:**
- `lib/features/auth/data/repositories/fake_auth_repository.dart` — existed temporarily (in-memory auth stand-in for early device testing before a real Firebase project existed), **deleted** once real Firebase Auth was wired up.
- `test/splash_redirect_logic_test.dart` — existed temporarily to pin down the fake repository's stream-replay bug, **deleted** once that class was removed (real Firebase's `authStateChanges()` doesn't have that bug).

---

## 5. Important Design Decisions

- **Onboarding: skipped.** The design docs' IA goes straight `Login → Dashboard`; user explicitly chose "skip it" over inventing slides.
- **Deep links: not implemented.** Nothing in the design docs needs them (no share links, no push notifications). The router already uses clean, parseable paths, so this is a platform-manifest change away, not a routing rewrite, if ever needed.
- **Add Vehicle's 3 steps are separate `GoRoute`s, not one screen with internal state** — this was specifically required for correct hardware/gesture back behavior (a real bug was found and fixed: using `context.go()` to advance steps discarded the Dashboard/Vehicle List screen underneath; fixed by switching to `context.push()`).
- **Vehicle Detail's back button explicitly navigates to Vehicle List** (`context.go(RoutePaths.vehicles)`) rather than `context.pop()`, since this screen can be reached either by a genuine push or by a full navigation reset (right after saving a new vehicle), where `pop()` isn't reliable.
- **`AddVehicleDraft` is reused for both the Add Vehicle flow and the Edit Vehicle screen** — same validation, same shape — rather than a parallel "EditDraft" type. Edit Vehicle owns its own local form state rather than sharing the global `addVehicleDraftProvider`, to avoid cross-contaminating an in-progress add flow.
- **`VehicleModel`/`DocumentModel` (data layer) are distinct from `VehicleEntity`/`DocumentEntity` (domain layer)** — the data models carry `toJson`/`fromJson`/validation/Drift mapping; domain entities are plain and storage-agnostic. `AddVehicleDraft` deliberately has **no** serialization (it's transient in-memory form state, never persisted).
- **Repository pattern isolates API / Local DB / Cache explicitly:** `AuthRepository` isolates API (Firebase) + Cache (secure session storage); `VehicleRepository` isolates Local DB (Drift) + Cache (document file cache) — no API, since there's no vehicle backend in v1.
- **Backup is a self-rescheduling one-off WorkManager task, not `registerPeriodicTask`.** WorkManager's periodic tasks can't pin to a specific wall-clock time (only "every N hours from first registration"), which would drift from the user's chosen time faster than reschedule-on-completion does. Runs close to, not exactly at, the chosen time under Doze — an accepted tradeoff (no `SCHEDULE_EXACT_ALARM` permission needed), the same real-world behavior WhatsApp's own backup has.
- **Drive-only Google sign-in reuses the single `GoogleSignIn` instance already owned by `FirebaseAuthDataSource`**, rather than a second instance. This means an email/password user's Drive connection is cleared on every app logout (`signOut()` already calls `_googleSignIn.signOut()` unconditionally) and must be reconnected — accepted deliberately, since running two live `GoogleSignIn` instances concurrently is unverified territory on Android and a bigger risk than this papercut.
- **Backups are found by well-known folder/file name, not a remembered file ID** (`findOrCreateBackupFolder` searches for a folder named "CarVault Backups"; the backup file itself is `carvault_backup_<uid>.zip`). Required because `drive.file` scope only grants the app visibility into files *it* created — after a reinstall there's no local ID to look up by, so restore must search by name on a fresh OAuth grant.
- **The WorkManager background isolate reinitializes everything from scratch** (`backup_callback_dispatcher.dart`): Firebase, `SharedPreferences`, a fresh `ProviderContainer`, and `GoogleSignIn.signInSilently()` to rehydrate Drive credentials — nothing carries over from the running app. This is the single highest-risk part of the feature; see §7/§8 for its on-device verification status.

---

## 6. APIs and Integrations

- **Firebase project:** `carvault-e0e9a`. Android app package: `com.carvault.carvault`.
- **Firebase Auth:** email/password + Google Sign-In, both real (not mocked).
- **Firebase Crashlytics:** wired in `bootstrap.dart`, active in production flavor only (`Environment.reportCrashes`).
- **Google Sign-In requires a stable signing certificate.** A permanent debug keystore is committed at `android/keystores/debug.keystore` (git-ignore has a narrow exception for this one file) so every build — local or CI — signs identically. SHA-1 fingerprint (registered in Firebase): `07:EC:3D:E6:0C:E0:8D:4A:D5:D8:09:C1:A0:4F:BF:90:9D:6E:0A:1B`.
- **`google-services.json` is committed to the repo** (not gitignored) — required for GitHub Actions to see it on a fresh checkout. The repo is public; the user was explicitly asked and chose "commit it" over "make the repo private," on the basis that Firebase's own docs say this file's contents are safe for public exposure (access control is via Security Rules, not this file).
- **No custom REST API exists.** `core/network/ApiClient` (Dio + retry/timeout/auth-token/logging interceptors) is fully built and tested in isolation but not called by any feature.
- **GitHub repo:** `https://github.com/khurrammhd/carvault_app` (public).
- **CI/CD:** `.github/workflows/build-apk.yml` — on push to `main`, builds a debug APK on a GitHub-hosted Ubuntu runner and uploads it as the `app-debug-apk` artifact.
- **Google Drive API** (project `carvault-e0e9a`): must be enabled in Google Cloud Console (APIs & Services → Library) — a manual, one-time console action, not something any code change can do. Scope used: `drive.file` (visible-to-the-user files only, not the hidden `drive.appdata` folder) — deliberate, so a "CarVault Backups" folder shows up in the user's own Drive. Backup file per user: `carvault_backup_<uid>.zip`, atomically replaced each run.

---

## 7. Pending Tasks

- [ ] Confirm Google Sign-In works end-to-end on-device after the latest build (OAuth client was just added to `google-services.json`; not yet confirmed working by the user).
- [ ] Add a delete-vehicle confirmation dialog (currently deletes immediately — flagged in the original design review as a must-fix before shipping).
- [ ] Wire document deletion to a screen (the `DeleteDocument` use case exists; no UI calls it yet).
- [ ] Implement the Share button (currently a stub on Vehicle Detail).
- [ ] Set up a real release signing config before ever distributing outside of direct APK installs (currently release builds reuse the debug signing config, matching Flutter's own default template).
- [ ] Consider SQLCipher encryption for the local database (currently unencrypted, relies on Android app-sandboxing only).
- [ ] Consider a biometric app-lock, given the sensitivity of stored documents (raised in the original security review, never built).
- [ ] **Enable the Google Drive API for project `carvault-e0e9a` in Google Cloud Console** — every Drive call 403s until this manual, one-time step is done (not something a code change can do).
- [ ] **Confirm CI is green on commit `273635e`** (the `workmanager` version fix, §8.7) — the prior push failed on a Kotlin compile error in the `workmanager` plugin; this commit should fix it, but the actual CI result hasn't been confirmed yet (tooling on this end hit a GitHub API rate limit while checking, and a raw page fetch of the Actions UI is unreliable — its status is loaded client-side by JavaScript, so it isn't in the fetched HTML). Check `https://github.com/khurrammhd/carvault_app/actions` directly.
- [ ] On-device verification of the whole backup feature is still outstanding (blocked on local builds — see §8.4 — so this must go through GitHub Actions CI + `adb install`, same as every other change here): both connection paths (Google-signed-in incremental consent, email/password Drive-only sign-in), a real scheduled backup firing, force-stop/reboot survival, and a full restore-after-simulated-reinstall.
- [ ] Consider auto-detecting an existing backup on fresh install and offering to restore it (currently restore is manual-only, reachable from Settings).
- [ ] If backup archives grow large enough that a background upload risks being killed as a long-running task, consider a foreground service + notification (Android 13+ `POST_NOTIFICATIONS`) — not needed for the small datasets expected today.

---

## 8. Known Issues (resolved during this conversation — kept here as history)

These were real bugs found and fixed; listed so they aren't accidentally reintroduced:

1. **Dashboard crash** (`RenderShiftedBox` "isNonNegative is not true"): caused by a negative `Padding` value used to replicate a CSS negative-margin overlap effect. Fixed with `Transform.translate` instead (negative `EdgeInsets` values trip that assertion in this Flutter version).
2. **Back navigation broken in Add Vehicle:** steps advanced via `context.go()`, which replaces the entire nav stack rather than pushing onto it — silently discarding Dashboard/Vehicle List underneath. Fixed by switching to `context.push()`.
3. **Splash screen hung forever** (two root causes, both fixed):
   - First bug: the temporary `FakeAuthRepository`'s stream never emitted an initial value, so the router's redirect logic waited forever. Attempted fix (broadcast `StreamController` + `onListen` replay) looked correct in isolation but didn't survive Riverpod's real subscribe cycle (two independent listeners — the router's refresh listener and `authStateProvider`'s own subscription — only one of which got the replay). Properly fixed by switching to `rxdart`'s `BehaviorSubject` (replays its current value to every subscriber, no timing tricks) and by routing the router's refresh through `ref.listen` instead of a raw second stream subscription.
   - Second, unrelated bug (found after switching to real Firebase and reported as "stuck on authentication"): `AuthController._run` accepted `Future<dynamic> Function()`, so the awaited result's *static* type was `dynamic`. `Result.when()` is an **extension method**, resolved by static type — with no static type to match, every single auth action (not just Google) crashed at runtime with `NoSuchMethodError` instead of a compile error, since `flutter analyze` doesn't catch this class of bug. Fixed by making `_run` generic over the `Result`'s value type. A regression test (`test/result_dynamic_typing_test.dart`) now pins down both the broken and fixed behavior.
4. **Local Android builds are broken on the primary dev machine** — `flutter build apk`/`gradlew` fail with `java.io.IOException: Unable to establish loopback connection`, traced to Java's internal NIO `Pipe` implementation failing to create a Unix Domain Socket on this specific Windows setup. Reproduced identically across Oracle JDK 21, Azul Zulu JDK 21, and Eclipse Temurin JDK 17 — not a JDK-version problem. Root cause is Windows-level (AF_UNIX support); `netsh winsock reset` (needs admin + reboot) and involving IT were both explicitly declined. **Workaround in permanent use:** build via GitHub Actions instead of locally.
5. **`google-services.json`'s `oauth_client` stayed empty across the first three downloads** even after the SHA-1 was correctly registered — root cause was that the **Google provider wasn't yet toggled "Enabled"** under Firebase Authentication → Sign-in method (a separate switch from SHA-1 registration). Once enabled, the re-downloaded file had the expected OAuth client entries.
6. **Project path containing spaces** (`...Mobile Application\Car Documents Management App-screenshots\carvault_app`) caused a Flutter/Gradle-on-Windows bug (`Error when reading '/main.dart'`) — fixed by moving the project to a space-free path. (It has since been moved again, by the user, to its current location `C:\Khurram\Android_app\carvault_app` — also space-free.)
7. **CI build failed on the backup feature's first push** (`Execution failed for task ':workmanager:compileDebugKotlin'`, a Kotlin compiler/metadata-version mismatch): `workmanager` was pinned at `0.5.2`, which predates that package's own `0.7.0` release bumping its required Kotlin/AGP/Gradle toolchain (Kotlin 2.1.0, AGP 8.10.1, Gradle 8.11.1) — its bundled Kotlin source doesn't compile against the newer toolchain the CI runner actually uses. **Fixed by upgrading to `workmanager: ^0.9.0+3`** — a pure version bump; the Dart API surface used here (`registerOneOffTask`, `ExistingWorkPolicy.replace`, `Constraints`/`NetworkType.connected`, `cancelByUniqueName`, `executeTask`) is unchanged between 0.5.2 and 0.9.0+3, confirmed by reading the installed package source directly rather than assuming. Pushed as commit `273635e`; **CI result for this fix not yet confirmed** — see §7.

---

## 9. Next Steps

1. **Enable the Google Drive API for `carvault-e0e9a`** in Google Cloud Console (§7) — nothing Drive-related will work until this is done.
2. Confirm CI is green on `273635e` (§7), then work through the on-device verification list in §7 — this code has passed `flutter analyze` and the existing test suite locally, but the Drive auth flows, the WorkManager background isolate, and restore have **not yet been exercised on a real device**.
3. Confirm the latest build (native splash + all auth fixes + real OAuth client) installs and works correctly on-device — both email/password and Google Sign-In.
4. Work through the rest of the Pending Tasks list (§7) roughly in priority order: delete confirmation dialog and document deletion UI are the most user-facing gaps.
5. If/when a custom backend is ever introduced beyond Drive backup, `core/network/ApiClient` is the ready seam — no repository interfaces need to change, only their implementations gain a remote data source alongside the existing local one.
6. Keep this file updated after any further significant change — new features, architecture changes, newly discovered bugs, or newly resolved ones.
