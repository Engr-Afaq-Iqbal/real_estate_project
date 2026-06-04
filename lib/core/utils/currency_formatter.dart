import 'package:intl/intl.dart';

/// Multi-currency formatter.
/// Every monetary value is stored with a currency_code.
/// PKR uses lakh/crore compact notation; others use standard millions/thousands.
class CurrencyFormatter {
  CurrencyFormatter._();

  static const Map<String, _CurrencyMeta> _meta = {
    'PKR': _CurrencyMeta(symbol: 'PKR ', locale: 'en_US', decimals: 0),
    'SAR': _CurrencyMeta(symbol: 'SAR ', locale: 'en_US', decimals: 0),
    'AED': _CurrencyMeta(symbol: 'AED ', locale: 'en_US', decimals: 0),
    'QAR': _CurrencyMeta(symbol: 'QAR ', locale: 'en_US', decimals: 0),
    'USD': _CurrencyMeta(symbol: '\$ ', locale: 'en_US', decimals: 0),
    'GBP': _CurrencyMeta(symbol: '£ ', locale: 'en_GB', decimals: 0),
    'EUR': _CurrencyMeta(symbol: '€ ', locale: 'en_EU', decimals: 0),
    'INR': _CurrencyMeta(symbol: '₹ ', locale: 'en_IN', decimals: 0),
    'MYR': _CurrencyMeta(symbol: 'RM ', locale: 'en_US', decimals: 0),
    'TRY': _CurrencyMeta(symbol: '₺ ', locale: 'en_US', decimals: 0),
  };

  // ── Full formatted string ──────────────────────────────────────────────────

  /// Returns "PKR 5,000,000" or "SAR 150,000"
  static String format(double amount, {String currency = 'PKR'}) {
    final meta = _meta[currency] ?? _meta['PKR']!;
    final formatter = NumberFormat.currency(
      locale: meta.locale,
      symbol: meta.symbol,
      decimalDigits: meta.decimals,
    );
    return formatter.format(amount);
  }

  // ── Compact (lakh/crore for PKR; M/K for others) ──────────────────────────

  /// PKR → "PKR 5Cr" / "PKR 50L" / "PKR 500k"
  /// Others → "SAR 1.5M" / "USD 250K"
  static String formatCompact(double amount, {String currency = 'PKR'}) {
    final symbol = (_meta[currency] ?? _meta['PKR']!).symbol.trim();

    if (currency == 'PKR' || currency == 'INR') {
      if (amount >= 10000000) {
        return '$symbol ${(amount / 10000000).toStringAsFixed(1)}Cr';
      } else if (amount >= 100000) {
        return '$symbol ${(amount / 100000).toStringAsFixed(1)}L';
      } else if (amount >= 1000) {
        return '$symbol ${(amount / 1000).toStringAsFixed(1)}k';
      }
      return '$symbol ${amount.toStringAsFixed(0)}';
    }

    if (amount >= 1000000) {
      return '$symbol ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '$symbol ${amount.toStringAsFixed(0)}';
  }

  // ── Number-only (no symbol) ────────────────────────────────────────────────

  static String formatNumber(double amount) =>
      NumberFormat('#,##0', 'en_US').format(amount);

  static String formatNumberCompact(double amount, {String currency = 'PKR'}) {
    if (currency == 'PKR' || currency == 'INR') {
      if (amount >= 10000000) return '${(amount / 10000000).toStringAsFixed(1)}Cr';
      if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
      if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}k';
      return amount.toStringAsFixed(0);
    }
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }

  // ── Lakh / Crore shortcuts (backward compat) ─────────────────────────────

  static String formatLakh(double amount, {String currency = 'PKR'}) {
    final symbol = (_meta[currency] ?? _meta['PKR']!).symbol.trim();
    final lakh = amount / 100000;
    return '$symbol ${lakh.toStringAsFixed(1)}L';
  }

  static String formatCrore(double amount, {String currency = 'PKR'}) {
    final symbol = (_meta[currency] ?? _meta['PKR']!).symbol.trim();
    final crore = amount / 10000000;
    return '$symbol ${crore.toStringAsFixed(2)}Cr';
  }

  // ── Parse ──────────────────────────────────────────────────────────────────

  static double parse(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  // ── Symbol only ───────────────────────────────────────────────────────────

  static String symbol(String currency) =>
      (_meta[currency] ?? _meta['PKR']!).symbol.trim();

  // ── Currency code list ────────────────────────────────────────────────────

  static const List<String> supportedCurrencies = [
    'PKR', 'SAR', 'AED', 'QAR', 'USD', 'GBP', 'EUR', 'INR', 'MYR', 'TRY',
  ];
}

class _CurrencyMeta {
  final String symbol;
  final String locale;
  final int decimals;

  const _CurrencyMeta({
    required this.symbol,
    required this.locale,
    required this.decimals,
  });
}
