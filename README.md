# Voice Keyboard (Windows + Android)

A Flutter starter app for **speech-to-text as a voice keyboard**.

It is designed for the "speak one-by-one" behavior you asked for, for example:

- `a` → `a`
- `space` → inserts one blank space
- `two` → `2`

## Features

- Works from one Flutter codebase for:
  - Windows desktop app
  - Android APK
- Microphone input via `speech_to_text`
- Voice command/token parser for one-by-one dictation
- Quick controls:
  - Start listening
  - Stop listening
  - Clear text

## How it works

When speech is recognized, the app splits words and maps each token to output:

- NATO/letter names and plain letters (`a`, `bee`, `cee`...) → letters
- Number words (`zero`..`nine`) → digits
- Editing commands (`space`, `newline`, `backspace`) → text actions
- Punctuation commands (`comma`, `period`, `question mark`) → punctuation

You can extend the dictionary in `lib/main.dart`.

## Prerequisites

1. Install Flutter SDK (stable)
2. Run:

```bash
flutter doctor
```

## Run on Windows

```bash
flutter config --enable-windows-desktop
flutter pub get
flutter run -d windows
```

## Build Windows executable

```bash
flutter build windows
```

Output is under:

`build/windows/x64/runner/Release/`

## Run on Android

```bash
flutter pub get
flutter run -d <android-device-id>
```

## Build Android APK

```bash
flutter build apk --release
```

APK output:

`build/app/outputs/flutter-apk/app-release.apk`

## Permissions notes

- Android needs microphone permission (configured in `android/app/src/main/AndroidManifest.xml` in a full Flutter app scaffold).
- Windows will prompt for microphone access depending on OS privacy settings.

## Next improvements

- Add confidence threshold and auto-commit only final results
- Add custom vocabulary file (domain words)
- Add cursor movement commands (`left`, `right`)
- Add "hold-to-talk" push button mode
