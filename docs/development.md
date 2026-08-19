# Development Guide

## Local Development Environment

- **OS**: Windows 10 (x64)
- **IDE**: Android Studio (with Flutter + Dart plugins)
- **SDK**: Flutter (stable channel), Dart SDK `^3.13.0`
- **Platform**: Android

The project is a Flutter Android application with application ID / namespace
`com.menglan.family_menu`.

## Toolchain

| Tool           | Purpose                              |
|----------------|--------------------------------------|
| Android Studio | Editing, debugging, emulator control |
| Flutter        | Build, run, test, analyze            |
| Android Emulator | Run and visually inspect the app   |
| Git / GitHub   | Version control                      |

## Android Emulator Test Device

The reference test device is:

- **Device**: Pixel 8
- **Android version**: Android 16
- **API level**: 36

Use this emulator for visual inspection and screenshots during UI review.

## Validation Commands

Run from the project root:

```bash
# Static analysis (must pass before considering work done)
flutter analyze

# Run tests
flutter test

# Fetch dependencies (when pubspec.yaml changes)
flutter pub get

# Run the app on the emulator
flutter run

# Build a release APK
flutter build apk

# Build a release AAB (for Google Play)
flutter build appbundle
```

## Development Workflow

Every feature follows an incremental cycle:

```
Requirement
   ↓
Plan
   ↓
Implementation
   ↓
flutter analyze
   ↓
Relevant tests
   ↓
Run Android App
   ↓
Visual inspection on Pixel 8 (API 36) emulator
   ↓
User review (screenshots)
   ↓
Approval
   ↓
Git commit
   ↓
Git push
```

Guidelines:

- Do not implement multiple unrelated features in one step.
- Keep UI changes small and individually previewable.
- The user reviews each UI milestone (via emulator screenshots) before the next.
- Never claim a feature is complete unless it has actually been verified.

## Troubleshooting

When a build or test fails:

1. Inspect the actual error output.
2. Determine the root cause.
3. Fix the root cause.
4. Rerun the failed validation.
