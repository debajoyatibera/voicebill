const express = require('express');
const cors = require('cors');
const { VertexAI } = require('@google-cloud/vertexai');

const app = express();
app.use(cors());
app.use(express.json());

// Google Cloud Project ID and Location
const PROJECT_ID = process.env.GOOGLE_CLOUD_PROJECT || 'voicebill-secure-2026';
const LOCATION = process.env.VERTEX_LOCATION || 'us-central1';

// Initialize Vertex AI with Application Default Credentials (No API keys needed!)
const vertexAI = new VertexAI({ project: PROJECT_ID, location: LOCATION });
const generativeModel = vertexAI.preview.getGenerativeModel({
  model: 'gemini-1.5-flash-002',
});

app.post('/api/parse', async (req, res) => {
  try {
    const { transcript } = req.body;
    if (!transcript || typeof transcript !== 'string') {
      return res.status(400).json({ error: 'Missing transcript string' });
    }

    const prompt = `
You are an assistant for a street vendor in India.
The vendor speaks a sale in Hindi, Bengali, English, or a mix.
Your job is to extract:
1) "item": the English or common name of the item sold (e.g. "Tea", "Samosa", "Chai", "Vada Pav").
2) "quantity": total count sold (number). If not stated, assume 1.
3) "pricePerUnit": price for one unit in Rupees (number). If only total price is given, divide by quantity.
4) "confidence": how confident you are from 0.0 to 1.0.

Transcript: "${transcript}"

Return ONLY valid JSON matching this structure:
{
  "item": "Chai",
  "quantity": 2,
  "pricePerUnit": 10.0,
  "confidence": 0.95
}
`;

    const request = {
      contents: [{ role: 'user', parts: [{ text: prompt }] }],
    };

    const responseStream = await generativeModel.generateContent(request);
    const aggregatedResponse = await responseStream.response;
    const text = aggregatedResponse.candidates[0].content.parts[0].text;

    const cleanedText = text.replace(/```json/gi, '').replace(/```/g, '').trim();
    const parsedData = JSON.parse(cleanedText);

    res.json(parsedData);
  } catch (error) {
    console.error('Vertex AI Error:', error);
    res.status(500).json({
      error: 'Failed to process transcript with Vertex AI',
      details: error.message,
    });
  }
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`GCP Vertex AI VoiceBill backend listening on port ${PORT}`);
});
