# Amazon Appstore submission — reference notes

Like Samsung, this needs **no new build pipeline** — Amazon accepts the
same `app-release.aab` produced by `.github/workflows/build-release-aab.yml`.
Run that workflow (or reuse an existing artifact) and upload the resulting
`.aab` directly to Amazon Developer Console.

## Account setup (manual, free — can't be done from code)

1. Create a free Amazon Developer account at
   [developer.amazon.com](https://developer.amazon.com).
2. Choose **"Sole Proprietorship Developer Account"** at sign-up, not
   Business — no DUNS number or business registration required, unlike
   Samsung's Corporate Commercial Seller requirement. Identity verification
   only (a government ID).
3. Register CarVault as a new app in the Developer Console.

## Signing — different from Samsung, read carefully

Amazon does **not** let you keep your own signing key. Quoting Amazon's own
docs: *"Amazon removes the signature you used to sign your app and re-signs
it with an Amazon signature that is unique to you, does not change, and is
the same for all apps in your account."*

This means:
- Upload `app-release.aab` signed with the existing `upload-keystore.jks`
  as normal — the upload signature itself doesn't matter, Amazon replaces it.
- After creating the app in Developer Console, Amazon shows **your
  account's Amazon signature hash (SHA-1)** — this is a *third* certificate
  fingerprint (distinct from both the upload key registered for Play Store
  and any Samsung key), and it **must be added to Firebase**
  (Authentication → Project settings → Add fingerprint) for Google Sign-In
  to work on Amazon-distributed installs.
- This Amazon signature is per-*account*, not per-app — once registered,
  any future app under this same Amazon developer account reuses it, no
  repeat registration needed.

## Technical requirements

- Both AAB and APK accepted; AAB preferred (Amazon uses `bundletool` to
  generate optimized APKs per device, same model as Play Store).
- No unique target-SDK minimum documented for Amazon specifically (less
  strict than Play Store) — this app's targetSdk 36 is unaffected either way.
- If the `.aab` has any non-install-time asset packs, Amazon rejects it —
  not a concern here, this app has none.

## Listing content — already have what's needed

- **Privacy policy URL:** `https://khurrammhd.github.io/carvault_app/privacy-policy.html`
  (same one used for Play Store and Samsung, already live).
- **Data collection disclosure:** reuse the answers in
  `docs/play-store-data-safety.md` — same underlying facts (Firebase Auth
  email, locally-stored photos, optional user-controlled Drive backup,
  Crashlytics diagnostics, no ads, no third-party sharing), just re-entered
  into Amazon's own submission form fields.

## Submission flow

1. Create the Sole Proprietorship developer account (identity verification
   only) and register the app.
2. Run the **Build Release AAB** GitHub Actions workflow (or reuse a recent
   run) → download `app-release.aab`.
3. Upload it in Developer Console.
4. Copy the Amazon account signature hash shown after app creation → add it
   to Firebase as a new SHA-1 fingerprint.
5. Fill in the listing using the privacy policy URL and data-disclosure
   notes above.
6. Submit for review.
