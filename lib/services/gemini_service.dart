import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/sale_entry.dart';

/// Sends a raw spoken transcript (English/Hindi/Bengali, possibly mixed)
/// to Gemini 3.6 Flash and gets back structured sale data.
class GeminiService {
  final String apiKey;
  late final GenerativeModel _model;

  GeminiService({required this.apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-3.6-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.1,
        responseMimeType: 'application/json',
      ),
    );
  }

  static const _systemPrompt = '''
You are a billing assistant for Indian street vendors. You will receive a
short spoken sentence, in English, Hindi, Bengali, or a mix (Hinglish/Benglish),
describing a sale. Extract the item name, quantity, and price PER UNIT in
Indian Rupees.

Examples:
"do chai, panch panch rupaye" -> item: chai, quantity: 2, pricePerUnit: 5
"tin plate momo, kuri taka kore" -> item: momo, quantity: 3, pricePerUnit: 20
"one samosa for ten rupees" -> item: samosa, quantity: 1, pricePerUnit: 10
"paanch packet chips, bees rupaye ka ek" -> item: chips, quantity: 5, pricePerUnit: 20

Rules:
- Always translate/normalize the item name to a simple lowercase English word
  (e.g. "চা"/"chai" -> "chai").
- quantity and pricePerUnit must be numbers (not strings).
- If price given is a TOTAL price rather than per-unit, divide by quantity.
- If you cannot confidently parse a valid sale, set "item" to "" and
  "confidence" to 0.
- confidence is your own estimate between 0 and 1 of how sure you are.

Respond with ONLY a JSON object in this exact shape, no extra text:
{"item": "string", "quantity": number, "pricePerUnit": number, "confidence": number}
''';

  /// Returns a SaleEntry parsed from [transcript], or null if Gemini
  /// could not confidently extract a sale.
  Future<SaleEntry?> parseTranscript(String transcript) async {
    if (transcript.trim().isEmpty) return null;

    try {
      final response = await _model.generateContent([
        Content.text('$_systemPrompt\n\nSpoken text: "$transcript"'),
      ]);

      final text = response.text;
      if (text == null || text.trim().isEmpty) return null;

      final Map<String, dynamic> data = jsonDecode(text) as Map<String, dynamic>;

      final item = (data['item'] as String? ?? '').trim();
      final confidence = (data['confidence'] as num?)?.toDouble() ?? 0.0;

      if (item.isEmpty || confidence <= 0.0) return null;

      return SaleEntry(
        item: item,
        quantity: (data['quantity'] as num?)?.toDouble() ?? 0,
        pricePerUnit: (data['pricePerUnit'] as num?)?.toDouble() ?? 0,
        confidence: confidence,
        rawTranscript: transcript,
      );
    } catch (e) {
      // Network error, malformed JSON, quota issue, etc.
      // Caller (home_screen) decides how to surface this to the user.
      rethrow;
    }
  }
}
