# VoiceBill 🎙️🧾📲

Voice-first billing app for street vendors who can't use typing-based POS apps — now with **1-Click WhatsApp Daily Report Sharing & CSV Spreadsheet Export**!

🌐 **Live Demo:** [https://debajoyatibera.github.io/voicebill/](https://debajoyatibera.github.io/voicebill/)

Speak a sale in English, Hindi, or Bengali — e.g. *"do chai, panch panch rupaye"* — and VoiceBill transcribes it on-device, sends it to a secure backend AI service to convert into structured data (item, quantity, price), logs it to a running daily total, reads the day's summary back out loud, and lets vendors share their daily tally on WhatsApp with 1 tap.

## Key Features
- **🎙️ Real-Time Multi-Language Voice POS:** Understands English, Hindi, and Bengali speech.
- **⌨️ Noisy Market Keyboard Fallback:** Type or paste `"do chai, panch rupaye"` anytime in noisy environments.
- **📲 1-Tap WhatsApp Daily Report:** Generate a beautifully formatted daily tally and share directly via WhatsApp (`wa.me`).
- **📊 CSV Spreadsheet Download:** Export your day's transactions as a standard `.csv` spreadsheet for Excel or Google Sheets.
- **🔊 TTS Voice Summary:** Reads aloud the day's sales and total collection in rupees.
- **🔒 Secure Serverless AI Backend:** Routes Gemini AI requests through a keyless Appwrite / GCP Cloud Run proxy.

## Tech stack
- **Flutter** (Web / Android / iOS cross-platform UI)
- **speech_to_text** (Continuous dictation mode speech recognition)
- **Appwrite Serverless / GCP Vertex AI Proxy** (Secure keyless backend)
- **url_launcher** (WhatsApp integration & CSV data URI export)
- **flutter_tts** (Voice readback)
- **shared_preferences** (Offline daily storage)

## Project structure
```
lib/
  main.dart                  # app entry point
  models/
    sale_entry.dart          # sale data model
  services/
    export_service.dart      # WhatsApp sharing & CSV data URI spreadsheet generation
    gemini_service.dart      # calls secure serverless proxy
    speech_service.dart      # dictation mic recognizer (en_IN/hi_IN/bn_IN)
    storage_service.dart     # local persistence via SharedPreferences
  screens/
    home_screen.dart         # mic, keyboard fallback, daily total, export modal
  widgets/
    sale_card.dart           # single sale list item with confidence badges
```

## Deploying to GitHub Pages
To compile and deploy the web app:
```bash
flutter build web --base-href /voicebill/
```
Then push `build/web/` to the `gh-pages` branch on GitHub.

## License
MIT — built for Open Innovation.
