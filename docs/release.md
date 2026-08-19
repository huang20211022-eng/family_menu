# Release Plan

Family Menu is intended to be a publicly downloadable, open-source Android
application. Releases are distributed through three channels.

## Release Channels

### 1. GitHub Releases

- Primary open-source distribution channel.
- Hosts release notes, source archives, and **APK** artifacts.
- Used for preview, beta, and stable releases available for direct download.

### 2. Direct APK Distribution

- Manual/side-load distribution of the signed APK.
- Enables users who are not on the Play Store (or who prefer side-loading)
  to install the app.
- The APK is built with `flutter build apk` and signed with the release key.

### 3. Google Play Store

- Official store distribution.
- Uses the **Android App Bundle (AAB)** format, built with
  `flutter build appbundle`.
- Requires Play Console setup, signing key management, store listing assets,
  and data-safety declarations.

## Artifact Formats

| Channel            | Artifact            | Build command            |
|--------------------|---------------------|--------------------------|
| GitHub Releases    | APK                 | `flutter build apk`      |
| Direct APK         | APK                 | `flutter build apk`      |
| Google Play        | AAB                 | `flutter build appbundle`|

> Google Play uses AAB; GitHub and direct distribution use APK.

## Release Signing

- Release builds must be signed with a proper release keystore (not the debug
  key, which is currently a placeholder in `android/app/build.gradle.kts`).
- The keystore and its passwords are secrets and must **never** be committed.
- Store credentials in local, git-ignored configuration (e.g.
  `android/key.properties`) or CI secrets.

## Release Checklist (planned)

1. Increment `version` in `pubspec.yaml` and update `CHANGELOG.md`.
2. Run `flutter analyze` and `flutter test`.
3. Build the artifact (`apk` and/or `appbundle`).
4. Verify the artifact on the Pixel 8 (API 36) emulator/device.
5. Sign with the release key.
6. Publish to the target channel and attach the signed artifact.
