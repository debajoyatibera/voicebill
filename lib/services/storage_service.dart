import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sale_entry.dart';

/// Persists sales locally using SharedPreferences.
/// Sales are stored as a JSON list under a key like "sales_2026-07-26",
/// so each day's ledger is independent.
class StorageService {
  static const _keyPrefix = 'sales_';

  String _dateKey(DateTime date) =>
      '$_keyPrefix${DateFormat('yyyy-MM-dd').format(date)}';

  Future<List<SaleEntry>> getSalesForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_dateKey(date));
    if (raw == null || raw.isEmpty) return [];

    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SaleEntry.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> addSale(SaleEntry sale) async {
    final prefs = await SharedPreferences.getInstance();
    final sales = await getSalesForDate(sale.timestamp);
    sales.add(sale);
    await prefs.setString(
      _dateKey(sale.timestamp),
      jsonEncode(sales.map((s) => s.toJson()).toList()),
    );
  }

  Future<void> deleteSale(String id, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final sales = await getSalesForDate(date);
    sales.removeWhere((s) => s.id == id);
    await prefs.setString(
      _dateKey(date),
      jsonEncode(sales.map((s) => s.toJson()).toList()),
    );
  }

  Future<double> getDailyTotal(DateTime date) async {
    final sales = await getSalesForDate(date);
    return sales.fold<double>(0, (sum, s) => sum + s.total);
  }

  Future<void> clearDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dateKey(date));
  }
}
