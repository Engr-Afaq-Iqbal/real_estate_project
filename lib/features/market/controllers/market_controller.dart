import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/data/market_config_data.dart';
import '../../../core/storage/local_storage.dart';

class MarketController extends GetxController {
  // ── Selected market ──────────────────────────────────────────────────────
  final _selectedCode = 'PK'.obs;
  final recentCodes   = <String>[].obs;

  String get selectedCode => _selectedCode.value;

  MarketInfo get market => marketByCode(_selectedCode.value);

  // ── Derived reactive getters (consumed by Obx in UI) ─────────────────────

  String get flag     => market.flag;
  String get name     => market.name;
  String get currency => market.currency;
  AreaUnitGroup get areaUnitGroup => market.areaUnitGroup;
  WorkWeek      get workWeek      => market.workWeek;
  bool          get isArabic      => market.isArabicMarket;

  /// Work week labels shown in the attendance header.
  List<String> get workWeekDays => switch (workWeek) {
        WorkWeek.satThu => ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu'],
        WorkWeek.sunThu => ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
        WorkWeek.monFri => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
      };

  String get restDayLabel => switch (workWeek) {
        WorkWeek.satThu => 'Fri',
        WorkWeek.sunThu => 'Sat',
        WorkWeek.monFri => 'Sun',
      };

  /// Quick estimator input label
  String get estimatorInputLabel => market.inputUnitLabel;

  // ── Currency formatting ──────────────────────────────────────────────────

  /// Formats an amount with correct lakh/crore for PK/IN/BD/LK,
  /// or millions/thousands for all other markets.
  String formatAmount(double amount) {
    final m = market;
    if (m.code == 'PK' || m.code == 'BD') {
      return _formatLakhCrore(amount, m.currencySymbol);
    }
    if (m.code == 'IN' || m.code == 'LK') {
      return _formatLakhCrore(amount, m.currencySymbol);
    }
    // Large IDR/VND values
    if (m.currency == 'IDR' || m.currency == 'VND') {
      if (amount >= 1e12) return '${m.currencySymbol} ${(amount / 1e12).toStringAsFixed(1)}T';
      if (amount >= 1e9)  return '${m.currencySymbol} ${(amount / 1e9).toStringAsFixed(1)}B';
      if (amount >= 1e6)  return '${m.currencySymbol} ${(amount / 1e6).toStringAsFixed(1)}M';
      return '${m.currencySymbol} ${NumberFormat('#,##0').format(amount.toInt())}';
    }
    // Standard millions/thousands
    if (amount >= 1e6)  return '${m.currencySymbol} ${(amount / 1e6).toStringAsFixed(2)}M';
    if (amount >= 1000) return '${m.currencySymbol} ${NumberFormat('#,##0').format(amount.toInt())}';
    return '${m.currencySymbol} ${amount.toStringAsFixed(0)}';
  }

  static String _formatLakhCrore(double amount, String symbol) {
    if (amount >= 1e7)  return '$symbol ${(amount / 1e7).toStringAsFixed(1)} Crore';
    if (amount >= 1e5)  return '$symbol ${(amount / 1e5).toStringAsFixed(1)} Lakh';
    if (amount >= 1000) return '$symbol ${NumberFormat('#,##0').format(amount.toInt())}';
    return '$symbol ${amount.toStringAsFixed(0)}';
  }

  // ── Construction estimate rate (per input unit) ──────────────────────────

  double estimateRate(String quality) {
    final r = market.rates;
    final ratePerSqm = switch (quality) {
      'economy' => r.economy,
      'premium' => r.premium,
      'luxury'  => r.luxury,
      _         => r.standard,
    };
    // For marla-input markets, convert sqm rate to per-marla
    // 1 Marla = 272.25 sqft = 25.29 sqm
    if (market.areaUnitGroup == AreaUnitGroup.marlaAndSqft &&
        market.inputUnitLabel == 'Marla') {
      return ratePerSqm * 25.2929;
    }
    // For sqft-input markets, convert to per sqft
    if (market.inputUnitLabel == 'Sq Ft') {
      return ratePerSqm * 0.09290304;
    }
    return ratePerSqm; // per sqm
  }

  // ── Select market ─────────────────────────────────────────────────────────

  void selectMarket(String code) {
    if (_selectedCode.value == code) return;
    _selectedCode.value = code;

    // Persist
    LocalStorage.setString(StorageKeys.selectedMarket, code);

    // Update recents (max 3)
    final r = List<String>.from(recentCodes)..remove(code);
    r.insert(0, code);
    if (r.length > 3) r.removeLast();
    recentCodes.value = r;
    LocalStorage.setString(StorageKeys.recentMarkets, r.join(','));

    // Propagate changes to rest of app
    _notifyDependents();
  }

  void _notifyDependents() {
    // Trigger DashboardController to reload market prices & estimator
    try {
      Get.find<dynamic>(tag: 'DashboardController').notifyMarketChange();
    } catch (_) {}
  }

  // ── Recent markets ─────────────────────────────────────────────────────────

  List<MarketInfo> get recentMarkets =>
      recentCodes.map((c) => marketByCode(c)).toList();

  // ── Init ──────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    final saved = LocalStorage.getString(StorageKeys.selectedMarket);
    if (saved != null && saved.isNotEmpty) {
      _selectedCode.value = saved;
    }
    final savedRecent = LocalStorage.getString(StorageKeys.recentMarkets);
    if (savedRecent != null && savedRecent.isNotEmpty) {
      recentCodes.value = savedRecent
          .split(',')
          .where((c) => c.isNotEmpty)
          .take(3)
          .toList();
    }
  }
}
