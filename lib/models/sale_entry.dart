import 'package:uuid/uuid.dart';

/// Represents a single spoken sale, e.g. "do chai, panch panch rupaye"
/// -> item: "chai", quantity: 2, pricePerUnit: 5
class SaleEntry {
  final String id;
  final String item;
  final double quantity;
  final double pricePerUnit;
  final DateTime timestamp;
  final double confidence; // 0.0 - 1.0, how sure Gemini was about the parse
  final String rawTranscript; // original spoken text, kept for debugging/edit

  SaleEntry({
    String? id,
    required this.item,
    required this.quantity,
    required this.pricePerUnit,
    DateTime? timestamp,
    this.confidence = 1.0,
    this.rawTranscript = '',
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  double get total => quantity * pricePerUnit;

  Map<String, dynamic> toJson() => {
        'id': id,
        'item': item,
        'quantity': quantity,
        'pricePerUnit': pricePerUnit,
        'timestamp': timestamp.toIso8601String(),
        'confidence': confidence,
        'rawTranscript': rawTranscript,
      };

  factory SaleEntry.fromJson(Map<String, dynamic> json) {
    return SaleEntry(
      id: json['id'] as String?,
      item: json['item'] as String? ?? 'unknown',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      pricePerUnit: (json['pricePerUnit'] as num?)?.toDouble() ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      rawTranscript: json['rawTranscript'] as String? ?? '',
    );
  }
}
