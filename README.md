# VoiceBill 🎙️🧾

Voice-first billing for street vendors who can't use typing-based POS apps.

🌐 **Live Demo:** [https://debajoyatibera.github.io/voicebill/](https://debajoyatibera.github.io/voicebill/)

Speak a sale in English, Hindi, or Bengali — e.g. *"do chai, panch panch rupaye"* — and VoiceBill transcribes it on-device, sends it to a secure backend AI service to convert into structured data (item, quantity, price), logs it to a running daily total, and reads the day's summary back out loud.

## Tech stack
- **Flutter** (UI, Web / Android / iOS cross-platform)
- **speech_to_text** — real-time speech-to-text transcription
- **Appwrite Serverless AI Proxy** — secure backend proxy that connects to Gemini AI without exposing client API keys
- **flutter_tts** — "speak summary" voice readback
- **shared_preferences** — local offline storage keyed by date
- **permission_handler** — mic permission handling
- **http** — network communication with backend AI proxy

## Project structure
```
lib/
  main.dart                  # app entry point
  models/
    sale_entry.dart          # sale data model
  services/
    gemini_service.dart      # calls secure Appwrite serverless proxy
    speech_service.dart      # mic listening, multi-locale (en_IN/hi_IN/bn_IN)
    storage_service.dart     # local persistence via SharedPreferences
  screens/
    home_screen.dart         # mic button, daily total, sales list
  widgets/
    sale_card.dart           # single sale list item
```

## Security & Backend Architecture
Unlike typical client apps that bake secret API keys into frontend code, **VoiceBill uses a secure serverless Appwrite backend proxy** (`https://6a68556d00328c455ba7.fra.appwrite.run`).
- Zero API keys are stored in client source code or `.js` bundles.
- Safe for public web deployment on GitHub Pages without triggering Secret Scanning alerts.
- Backend handles prompt engineering, response validation, and Gemini AI authentication.

## Local Development
1. Install the Flutter SDK: https://docs.flutter.dev/get-started/install
2. Get dependencies:
   ```bash
   flutter pub get
   ```
3. Run locally in Chrome or mobile:
   ```bash
   flutter run -d chrome
   ```
   *(No `--dart-define=GEMINI_API_KEY=...` required!)*

## Deploying to GitHub Pages
To rebuild and deploy the web app:
```bash
flutter build web --base-href /voicebill/
```
Then push the contents of `build/web/` to the `gh-pages` branch on GitHub.

## License
MIT — built for Open Innovation.
