# VoiceBill 🎙️🧾📲

**Multilingual Voice-First Billing & POS App for Indian Street Vendors**  
*Built for Hack Synthesis 3.0 (2026) - University of Engineering & Management (UEM) Kolkata*  
**Theme:** Open Innovation | **Team Name:** VoiceBill  
**Team Members:** Debajoyati Bera (Team Leader), Souvik Adak

---

### 🌐 **Live Interactive Demo:** [https://debajoyatibera.github.io/voicebill/](https://debajoyatibera.github.io/voicebill/)

---

## 💡 The Problem & Our Solution
Over 50+ million street vendors and hawkers in India struggle with traditional POS and billing apps due to small touchscreen keyboards, literacy barriers, and language constraints. 

**VoiceBill** removes typing entirely. Vendors speak naturally in vernacular languages—e.g. *"do chai, panch panch rupaye"*—and VoiceBill:
1. **Transcribes** vernacular speech in real-time on-device.
2. **Parses** unstructured voice into structured JSON (`item`, `quantity`, `pricePerUnit`) using AI.
3. **Calculates** and logs the daily collection offline.
4. **Speaks back** the day's total in rupees.
5. **Shares** instant business reports via **WhatsApp (1-click)** or exports a **CSV Spreadsheet** for Excel.

---

## ✨ Key Features & WOW Factors
- **🎙️ Real-Time Multi-Language Voice POS:** Seamless speech recognition in **English (India)**, **Hindi (`hi_IN`)**, and **Bengali (`bn_IN`)**.
- **🎨 Colorful WOW UI & Dynamic Aesthetics:** Glassmorphic cards, deep emerald/indigo gradients, and a glowing pulsing microphone button.
- **⌨️ Noisy Market Keyboard Fallback:** Type or paste `"do chai, panch rupaye"` in deafeningly loud outdoor markets where speech is impossible.
- **📲 1-Tap WhatsApp Daily Business Report:** Generates a clean markdown tally and launches WhatsApp (`wa.me`) synchronously without popup blockers.
- **📊 CSV Spreadsheet Download:** Export your day's transactions as a `.csv` spreadsheet for Excel or Google Sheets (with web-native HTML Anchor download support).
- **🔊 TTS Voice Summary:** Reads aloud the day's sales and total collection in rupees.
- **🔒 Secure Serverless AI Backend:** Routes Gemini AI requests through a keyless Appwrite / GCP Cloud Run proxy—zero API keys exposed in client bundles.

---

## 🛠️ Tech Stack
- **Frontend / UI:** Flutter 3 (Web, Android, iOS), CanvasKit / Web-optimized build.
- **AI & Cloud Backend:** Google Cloud Platform (GCP) Vertex AI, Cloud Run Serverless Container, Appwrite Proxy, Gemini 1.5 Flash SDK.
- **Voice & Media:** `speech_to_text` (Dictation Mode), `flutter_tts` (Text-to-Speech).
- **Export & Integration:** `url_launcher` (WhatsApp `wa.me` sharing & CSV spreadsheet download).
- **Local Storage:** `shared_preferences` (Offline persistence).

---

## 📂 Project Structure
```
lib/
  main.dart                  # App entry point
  models/
    sale_entry.dart          # Sale data model with confidence scoring
  services/
    export_service.dart      # WhatsApp sharing & CSV spreadsheet generation
    gemini_service.dart      # Calls secure keyless serverless proxy
    speech_service.dart      # Dictation mic recognizer (en_IN/hi_IN/bn_IN)
    storage_service.dart     # Local offline persistence via SharedPreferences
  screens/
    home_screen.dart         # Glowing mic, keyboard fallback, daily collection, export modal
  widgets/
    sale_card.dart           # Single sale list item with Check / Verified badges
```

---

## 🚀 Deploying to GitHub Pages
To compile and deploy the optimized web app:
```bash
flutter build web --base-href /voicebill/ --no-tree-shake-icons
```
Then push `build/web/` to the `gh-pages` branch on GitHub.

---

## 📜 License
MIT License — Built for Open Innovation.
