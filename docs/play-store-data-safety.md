# Play Console "Data safety" form — reference answers

Play Console's Data safety section (App content → Data safety) is a manual
questionnaire in their UI — there's no way to fill it in from code. This is
what to answer, based on what CarVault actually does as of this build.

## Does your app collect or share any of the required user data types?

**Yes.**

## Data types

| Category | Type | Collected? | Shared with third parties? | Purpose |
|---|---|---|---|---|
| Personal info | Email address | Yes | No | Account management, app functionality (Firebase Auth sign-in) |
| Photos and videos | Photos | Yes | No* | App functionality (document photos, stored locally + optional user-controlled Drive backup) |
| App activity | Crash logs | Yes | No | Analytics/diagnostics (Firebase Crashlytics, production builds only) |
| App info and performance | Diagnostics | Yes | No | Analytics/diagnostics (Firebase Crashlytics) |

\* The photos are uploaded to the user's *own* Google Drive when they opt into
backup — that's the user sharing data with their own Google account, not
CarVault sharing data with a third party. Answer "No" to third-party sharing;
if Play Console's wording forces a distinction, note in the optional
free-text field that backups go to the user's own Drive under the app's
`drive.file` scope, not a developer-controlled destination.

## Is all of the user data collected encrypted in transit?

**Yes** — Firebase Auth and Google Drive API traffic are both HTTPS/TLS.

## Do you provide a way for users to request that their data be deleted?

**Yes.** In-app: delete individual vehicles/documents, or delete the app
entirely to remove local data, or disconnect/delete the Drive backup
directly from Google Drive. Account-level deletion: via email to
khurram.mhd@gmail.com (state this exact flow in the form's account
deletion fields — Play Console asks for either an in-app path or a web URL;
CarVault doesn't have a hosted account-deletion web form, so use the email
contact route).

## Privacy policy URL

Once GitHub Pages is enabled for this repo (see below), the URL is:

```
https://khurrammhd.github.io/carvault_app/privacy-policy.html
```

## Enabling GitHub Pages (one-time, manual — can't be done from code)

1. Go to the repo on GitHub → **Settings** → **Pages**.
2. Under "Build and deployment" → Source, choose **Deploy from a branch**.
3. Branch: **main**, folder: **/docs**. Save.
4. After a minute or two, the page is live at the URL above — paste that
   into Play Console's Data Safety form and the main Store Listing's
   privacy policy field.

## Sensitive scope note (Google Cloud Console, separate from Play Console)

Because the app requests the `drive.file` OAuth scope, Google's own OAuth
consent screen (Google Cloud Console → APIs & Services → OAuth consent
screen, project `carvault-e0e9a`) needs:
- App name, support email, and **the same privacy policy URL** above.
- The consent screen published to "In production" (not left in "Testing"),
  or only up to 100 explicitly-added test users will ever be able to sign
  in with Google / use Drive backup.
- `drive.file` is a "sensitive" (not "restricted") scope — it does **not**
  require Google's full CASA security assessment, but Google may still run
  a lighter automated/manual review before removing the "unverified app"
  warning users see on first Google sign-in. Submit for verification from
  the same OAuth consent screen page once the app info above is filled in.
