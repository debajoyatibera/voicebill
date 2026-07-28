import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sale_entry.dart';

class GeminiService {
  static const String _proxyUrl = 'https://6a68556d00328c455ba7.fra.appwrite.run';

  Future<SaleEntry?> parseTranscript(String transcript) async {
    if (transcript.trim().isEmpty) return null;

    final response = await http.post(
      Uri.parse(_proxyUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'transcript': transcript}),
    );

    if (response.statusCode != 200) {
      throw Exception('Proxy request failed: ${response.statusCode} ${response.body}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;

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
  }
}
