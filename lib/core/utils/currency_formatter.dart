import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _pkrFormatter = NumberFormat.currency(
    locale: 'ur_PK',
    symbol: 'PKR ',
    decimalDigits: 0,
  );

  static final _compactFormatter = NumberFormat.compact(locale: 'en_US');

  static String format(double amount) {
    return _pkrFormatter.format(amount);
  }

  static String formatCompact(double amount) {
    if (amount >= 10000000) {
      return 'PKR ${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return 'PKR ${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return 'PKR ${(amount / 1000).toStringAsFixed(1)}k';
    }
    return 'PKR ${amount.toStringAsFixed(0)}';
  }

  static String formatLakh(double amount) {
    final lakh = amount / 100000;
    return 'PKR ${lakh.toStringAsFixed(1)}L';
  }

  static String formatCrore(double amount) {
    final crore = amount / 10000000;
    return 'PKR ${crore.toStringAsFixed(2)}Cr';
  }

  static String formatNumber(double amount) {
    return NumberFormat('#,##0', 'en_US').format(amount);
  }

  static double parsePkr(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }
}
