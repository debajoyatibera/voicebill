import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sale_entry.dart';

class SaleCard extends StatelessWidget {
  final SaleEntry sale;
  final VoidCallback onDelete;

  const SaleCard({super.key, required this.sale, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final lowConfidence = sale.confidence < 0.6;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              lowConfidence ? Colors.orange.shade100 : Colors.green.shade100,
          child: Icon(
            lowConfidence ? Icons.help_outline : Icons.check,
            color: lowConfidence ? Colors.orange : Colors.green,
          ),
        ),
        title: Text(
          '${sale.item[0].toUpperCase()}${sale.item.substring(1)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${_fmt(sale.quantity)} x ₹${_fmt(sale.pricePerUnit)} · '
          '${DateFormat.jm().format(sale.timestamp)}'
          '${lowConfidence ? '  (low confidence, tap to check)' : ''}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '₹${_fmt(sale.total)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}
