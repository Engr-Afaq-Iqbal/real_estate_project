import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../projects/engine/budget_engine.dart';
import '../data/models/saved_calculation_model.dart';

class _PriceSlider {
  final String key;
  final String label;
  double changePct;

  _PriceSlider({required this.key, required this.label, this.changePct = 0});
}

class WhatIfController extends GetxController {
  // ── Base calculation ──────────────────────────────────────────────────────
  final baseCalc       = Rxn<SavedCalculationModel>();
  final baseTotalCtrl  = TextEditingController();

  double get baseTotal {
    if (baseCalc.value != null) return baseCalc.value!.totalAmount;
    return double.tryParse(baseTotalCtrl.text.trim().replaceAll(',', '')) ?? 0;
  }

  void setBaseCalculation(SavedCalculationModel calc) {
    baseCalc.value = calc;
    baseTotalCtrl.text = calc.totalAmount.toStringAsFixed(0);
    _buildDefaultSliders();
    runScenario();
  }

  void clearBaseCalculation() {
    baseCalc.value = null;
    baseTotalCtrl.clear();
    result.value = null;
  }

  // ── Category amounts (breakdown for what-if) ──────────────────────────────
  // Defaults: typical distribution for a standard house
  final Map<String, double> _defaultSplit = {
    'steel':    0.15,   // 15% of total
    'cement':   0.12,
    'bricks':   0.08,
    'sand':     0.04,
    'crush':    0.03,
    'tiles':    0.08,
    'plumbing': 0.05,
    'electrical':0.05,
    'paint':    0.04,
    'timber':   0.04,
    'labor':    0.32,   // largest component
  };

  Map<String, double> get categoryAmounts {
    final total = baseTotal;
    return _defaultSplit.map((k, v) => MapEntry(k, total * v));
  }

  // ── Price sliders ─────────────────────────────────────────────────────────
  final sliders = <_PriceSlider>[].obs;

  void _buildDefaultSliders() {
    sliders.value = [
      _PriceSlider(key: 'steel',     label: 'Steel'),
      _PriceSlider(key: 'cement',    label: 'Cement'),
      _PriceSlider(key: 'bricks',    label: 'Bricks'),
      _PriceSlider(key: 'labor',     label: 'Labor'),
      _PriceSlider(key: 'tiles',     label: 'Tiles'),
      _PriceSlider(key: 'plumbing',  label: 'Plumbing'),
      _PriceSlider(key: 'electrical',label: 'Electrical'),
      _PriceSlider(key: 'paint',     label: 'Paint'),
    ];
  }

  void updateSlider(String key, double pct) {
    final idx = sliders.indexWhere((s) => s.key == key);
    if (idx != -1) {
      sliders[idx].changePct = pct;
      sliders.refresh();
      runScenario();
    }
  }

  void resetAllSliders() {
    for (final s in sliders) { s.changePct = 0; }
    sliders.refresh();
    runScenario();
  }

  // ── Scenario result ───────────────────────────────────────────────────────
  final result = Rxn<WhatIfResult>();

  void runScenario() {
    final total = baseTotal;
    if (total <= 0) return;

    final changes = sliders
        .where((s) => s.changePct != 0)
        .map((s) => PriceChangeInput(
              category: s.key,
              changePct: s.changePct,
            ))
        .toList();

    result.value = BudgetEngine.whatIf(
      baseTotal: total,
      categoryAmounts: categoryAmounts,
      changes: changes,
    );
  }

  // ── Formatted helpers ─────────────────────────────────────────────────────
  String get formattedBaseTotal =>
      CurrencyFormatter.formatCompact(baseTotal);

  String get formattedNewTotal {
    final r = result.value;
    return r != null
        ? CurrencyFormatter.formatCompact(r.newTotal)
        : formattedBaseTotal;
  }

  String get formattedImpact {
    final r = result.value;
    if (r == null || r.totalImpact == 0) return 'No change';
    final sign  = r.totalImpact > 0 ? '+' : '';
    final amount = CurrencyFormatter.formatCompact(r.totalImpact.abs());
    final pct   = r.totalImpactPct.toStringAsFixed(1);
    return '$sign$amount ($sign$pct%)';
  }

  bool get hasIncrease =>
      (result.value?.totalImpact ?? 0) > 0;

  @override
  void onInit() {
    super.onInit();
    _buildDefaultSliders();
  }

  @override
  void onClose() {
    baseTotalCtrl.dispose();
    super.onClose();
  }
}
