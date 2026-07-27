# VoiceBill 🎙️🧾

Voice-first billing for street vendors who can't use typing-based POS apps.

Speak a sale in English, Hindi, or Bengali — e.g. *"do chai, panch panch
rupaye"* — and VoiceBill transcribes it on-device, sends it to Gemini 1.5
Flash to turn into structured data (item, quantity, price), logs it to a
running daily total, and can read the day's summary back out loud.

## Tech stack
- **Flutter** (UI, cross-platform)
- **speech_to_text** — on-device speech-to-text
- **google_generative_ai** — Gemini 1.5 Flash for parsing transcripts into JSON
- **flutter_tts** — "speak summary" readback
- **shared_preferences** — local, offline storage keyed by date
- **permission_handler** — mic permission
- **uuid**, **intl** — utility packages

No backend, no Firebase — everything runs locally except the Gemini API call.

## Project structure
```
lib/
  main.dart                  # entry point, reads GEMINI_API_KEY
  models/
    sale_entry.dart          # sale data model
  services/
    gemini_service.dart      # transcript -> structured JSON via Gemini
    speech_service.dart      # mic listening, multi-locale (en_IN/hi_IN/bn_IN)
    storage_service.dart     # local persistence via SharedPreferences
  screens/
    home_screen.dart         # mic button, daily total, sales list
  widgets/
    sale_card.dart           # single sale list item
```

## Setup

1. Install the Flutter SDK: https://docs.flutter.dev/get-started/install
2. Run `flutter doctor` and fix anything marked with a red `✗`.
3. From this project folder, run:
   ```
   flutter create .
   ```
   This generates the missing `android/`, `ios/`, etc. platform folders
   around the existing `lib/` code.
4. Add mic + internet permissions:
   - **Android**: open `android/app/src/main/AndroidManifest.xml` and add
     the two `<uses-permission>` lines and the `<queries>` block shown in
     this repo's manifest reference.
   - **iOS**: open `ios/Runner/Info.plist` and add the two keys from
     `ios/Runner/Info-permissions-snippet.plist`, then delete that snippet file.
5. Get dependencies:
   ```
   flutter pub get
   ```
6. Get a Gemini API key from https://aistudio.google.com/app/apikey
7. Run the app, passing your key in at launch (never hard-code it):
   ```
   flutter run --dart-define=GEMINI_API_KEY=your_key_here
   ```

## How it works
1. Vendor taps the mic button and speaks a sale in their language.
2. `speech_to_text` transcribes speech on-device in real time.
3. On the final transcript, `GeminiService` sends it to Gemini 1.5 Flash
   with a prompt asking for `{item, quantity, pricePerUnit, confidence}`
   as JSON.
4. The parsed `SaleEntry` is saved locally (`StorageService`, keyed by
   today's date) and shown in the list with a running total.
5. Tapping "Speak summary" uses `flutter_tts` to read back what was sold
   and the day's total.

## Known limitations / future scope
- Requires internet for the Gemini parsing step (works offline for
  everything else — storage, mic, playback).
- No multi-day analytics/export yet (CSV export planned).
- No manual correction UI for low-confidence parses yet (flagged in the UI
  with an orange icon, but not yet editable).
- Single-device only — no cloud sync across vendor's devices.

## License
MIT — built for a college hackathon (Open Innovation theme).
