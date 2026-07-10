# Samsung Galaxy Store submission — reference notes

Unlike Play Store, this needs **no new build pipeline** — Galaxy Store
accepts the same `app-release.aab` produced by
`.github/workflows/build-release-aab.yml`. Run that workflow (or reuse an
artifact from a prior run) and upload the resulting `.aab` directly to
Samsung's Seller Portal.

## Technical requirements — already met

- Target API level ≥ 33 required. This app's `targetSdk`/`compileSdk` both
  resolve to **36** (Flutter's current stable default, `flutter.targetSdkVersion`
  in `android/app/build.gradle.kts`) — well clear.
- At least one 64-bit binary required. Flutter's `.aab` output includes
  `arm64-v8a` by default — met automatically, no build flag changes needed.
- AAB upload is supported directly (Galaxy Store generates a universal APK
  from it for each device, similar to Play Store's model).

## Account setup (manual, free — can't be done from code)

1. Create a Samsung Developer account at
   [seller.samsungapps.com](https://seller.samsungapps.com) — **no fee**.
2. Register CarVault as a new app in Seller Portal.

## Signing key — a choice to make in Samsung's UI

When uploading an `.aab`, Samsung asks how to handle signing (their own
equivalent of Play App Signing):

- **Recommended: upload the existing `android/keystores/upload-keystore.jks`**
  (the same one already generated for Play Store) so Samsung signs with the
  same key. This means the SHA-1 already registered in Firebase
  (`87:4E:08:7E:41:36:02:F7:D5:70:E4:7A:74:CB:5B:BB:DB:02:E4:E3`, see
  `PROJECT_CONTEXT.md` §6) **already covers Galaxy Store installs too** —
  no extra Firebase fingerprint needed, and Google Sign-In works
  immediately on Galaxy-Store-installed builds.
- Alternative: let Galaxy Store generate/manage its own key. Simpler in the
  moment, but produces a *third* signing certificate whose SHA-1 would need
  registering in Firebase separately (same pattern as Play App Signing's
  second fingerprint) — avoid this unless there's a specific reason to.

## Listing content — already have what's needed

- **Privacy policy URL:** `https://khurrammhd.github.io/carvault_app/privacy-policy.html`
  (same one built for Play Store, already live).
- **Data collection disclosure:** Samsung's equivalent of Play's Data Safety
  form asks similar questions — `docs/play-store-data-safety.md`'s answers
  apply here too (email via Firebase Auth, locally-stored photos, optional
  user-controlled Google Drive backup, Crashlytics diagnostics; no ads, no
  third-party sharing).
- Content rating questionnaire: straightforward for a utility app with no
  objectionable content — no special handling needed.

## Submission flow

1. Complete account setup above.
2. Run the **Build Release AAB** GitHub Actions workflow (or reuse a
   recent run) → download `app-release.aab`.
3. Register the app in Seller Portal, upload the `.aab`, upload the
   existing upload keystore when prompted for signing (see above).
4. Fill in the store listing using the privacy policy URL and data
   disclosure notes above.
5. Submit for review.
