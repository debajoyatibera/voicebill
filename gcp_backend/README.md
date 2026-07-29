# VoiceBill GCP Vertex AI Backend ☁️

This directory contains the secure, keyless **Google Cloud Run** backend that connects to **Vertex AI (Gemini 1.5 Flash)** using Google Cloud Application Default Credentials (ADC).

## Why No API Keys?
When deployed to Google Cloud Run, the service automatically inherits the Cloud Run Service Account permissions.
1. No API keys are stored in source code.
2. No API keys are exposed to the client frontend.
3. Completely protected against unauthorized usage.

## How to Deploy to Google Cloud Run
Once you have an open Google Cloud billing account linked to your project (`voicebill-secure-2026`), deploy from this directory:

```bash
gcloud run deploy voicebill-backend \
  --source . \
  --region us-central1 \
  --allow-unauthenticated \
  --project=voicebill-secure-2026
```

Once deployed, copy your Cloud Run HTTPS URL (e.g. `https://voicebill-backend-xxxxx-uc.a.run.app/api/parse`) and paste it into `lib/services/gemini_service.dart`.
