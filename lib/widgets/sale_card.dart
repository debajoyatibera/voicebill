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
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: lowConfidence
              ? Colors.amber.shade300
              : theme.colorScheme.primary.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: lowConfidence
                  ? [Colors.amber.shade400, Colors.orange.shade600]
                  : [const Color(0xFF00C9FF), const Color(0xFF92FE9D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: (lowConfidence ? Colors.orange : const Color(0xFF00C9FF))
                    .withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            lowConfidence ? Icons.priority_high_rounded : Icons.check_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                '${sale.item[0].toUpperCase()}${sale.item.substring(1)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            if (lowConfidence)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Check',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${_fmt(sale.quantity)} x ₹${_fmt(sale.pricePerUnit)}  ·  ${DateFormat.jm().format(sale.timestamp)}',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.65),
              fontWeight: FontWeight.w500,
              fontSize: 13.5,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '₹${_fmt(sale.total)}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 22,
                color: theme.colorScheme.error.withOpacity(0.7),
              ),
              onPressed: onDelete,
              tooltip: 'Delete sale',
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}
