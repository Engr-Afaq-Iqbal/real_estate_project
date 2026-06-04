import '../../../core/data/price_master_data.dart';
import '../../../core/utils/unit_converter.dart';

// ── Budget validation result ──────────────────────────────────────────────────

enum BudgetStatus { comfortable, onTrack, tight, insufficient }

class BudgetValidationResult {
  final BudgetStatus status;
  final String headline;
  final String message;
  final double userBudget;
  final double estimatedCost;
  final double shortfall;
  final double surplus;
  final double recommendedBudget;
  final List<String> suggestions;

  const BudgetValidationResult({
    required this.status,
    required this.headline,
    required this.message,
    required this.userBudget,
    required this.estimatedCost,
    this.shortfall = 0,
    this.surplus = 0,
    required this.recommendedBudget,
    this.suggestions = const [],
  });

  bool get isHealthy =>
      status == BudgetStatus.comfortable || status == BudgetStatus.onTrack;
}

// ── What-if result ────────────────────────────────────────────────────────────

class WhatIfImpact {
  final String category;
  final double changePct;
  final double baseAmount;
  final double impact;

  const WhatIfImpact({
    required this.category,
    required this.changePct,
    required this.baseAmount,
    required this.impact,
  });
}

class WhatIfResult {
  final double baseTotal;
  final double newTotal;
  final double totalImpact;
  final double totalImpactPct;
  final List<WhatIfImpact> impacts;
  final String recommendation;

  const WhatIfResult({
    required this.baseTotal,
    required this.newTotal,
    required this.totalImpact,
    required this.totalImpactPct,
    required this.impacts,
    required this.recommendation,
  });

  bool get isCostIncrease => totalImpact > 0;
}

// ── House estimate result ─────────────────────────────────────────────────────

class HouseEstimateBreakdown {
  final double constructionAreaSqft;
  final double totalAreaSqft;  // area × floors
  final String qualityTier;
  final double ratePerSqft;
  final Map<String, double> components;  // component → amount
  final double subtotal;
  final double contingency;
  final double total;
  final double materialsOnly;
  final double laborOnly;
  final String priceDate;
  final String currencyCode;

  const HouseEstimateBreakdown({
    required this.constructionAreaSqft,
    required this.totalAreaSqft,
    required this.qualityTier,
    required this.ratePerSqft,
    required this.components,
    required this.subtotal,
    required this.contingency,
    required this.total,
    required this.materialsOnly,
    required this.laborOnly,
    required this.priceDate,
    required this.currencyCode,
  });
}

// ── Budget Engine ─────────────────────────────────────────────────────────────

class BudgetEngine {
  BudgetEngine._();

  // ── House Estimation ──────────────────────────────────────────────────────

  /// Estimates total cost for a house/structure.
  static HouseEstimateBreakdown estimateHouse({
    required double constructionAreaSqm,
    required int floors,
    required String qualityTier,
    double contingencyPct = 10,
    String currencyCode = 'PKR',
    int cityId = 101,
  }) {
    final constructionAreaSqft = UnitConverter.fromSqMeters(
        constructionAreaSqm, 'sqft');
    final totalAreaSqft = constructionAreaSqft * floors;

    final rates = PriceMasterData.ratesPerSqft;
    final Map<String, double> components = {};

    for (final entry in rates.entries) {
      final rate = entry.value[qualityTier] ?? 0.0;
      components[entry.key] = totalAreaSqft * rate;
    }

    final subtotal    = components.values.fold(0.0, (s, v) => s + v);
    final contingency = subtotal * (contingencyPct / 100);
    final total       = subtotal + contingency;

    // Split: ~60% materials, ~35% labor, ~5% equipment (approximate for PK)
    final materialsOnly = subtotal * 0.60;
    final laborOnly     = subtotal * 0.35;

    return HouseEstimateBreakdown(
      constructionAreaSqft: constructionAreaSqft,
      totalAreaSqft: totalAreaSqft,
      qualityTier: qualityTier,
      ratePerSqft: total / totalAreaSqft,
      components: components,
      subtotal: subtotal,
      contingency: contingency,
      total: total,
      materialsOnly: materialsOnly,
      laborOnly: laborOnly,
      priceDate: PriceMasterData.effectiveDate,
      currencyCode: currencyCode,
    );
  }

  // ── Budget Validation ─────────────────────────────────────────────────────

  /// Compares user budget against estimated cost and provides actionable feedback.
  static BudgetValidationResult validate({
    required double userBudget,
    required double estimatedCost,
    required String qualityTier,
    double contingencyPct = 10,
  }) {
    if (estimatedCost <= 0) {
      return BudgetValidationResult(
        status: BudgetStatus.onTrack,
        headline: 'Budget Set',
        message: 'Run the estimator to compare your budget against market rates.',
        userBudget: userBudget,
        estimatedCost: 0,
        recommendedBudget: userBudget,
      );
    }

    final ratio       = userBudget / estimatedCost;
    final recommended = estimatedCost * (1 + contingencyPct / 100);

    if (ratio >= 1.15) {
      return BudgetValidationResult(
        status: BudgetStatus.comfortable,
        headline: 'Well Funded',
        message:
            'Your budget is ${((ratio - 1) * 100).toStringAsFixed(0)}% above the market estimate. '
            'You have a comfortable contingency buffer.',
        userBudget: userBudget,
        estimatedCost: estimatedCost,
        surplus: userBudget - estimatedCost,
        recommendedBudget: recommended,
        suggestions: [
          'Consider upgrading from $qualityTier to ${_nextTier(qualityTier)} quality',
          'Keep ${((userBudget - estimatedCost) / userBudget * 100).toStringAsFixed(0)}% as emergency reserve',
        ],
      );
    }

    if (ratio >= 0.95) {
      return BudgetValidationResult(
        status: BudgetStatus.onTrack,
        headline: 'Budget Aligned',
        message:
            'Your budget aligns well with market estimates. '
            'We recommend keeping a ${contingencyPct.toStringAsFixed(0)}% contingency.',
        userBudget: userBudget,
        estimatedCost: estimatedCost,
        surplus: userBudget - estimatedCost,
        recommendedBudget: recommended,
      );
    }

    if (ratio >= 0.80) {
      return BudgetValidationResult(
        status: BudgetStatus.tight,
        headline: 'Tight Budget',
        message:
            'Your budget is ${((1 - ratio) * 100).toStringAsFixed(0)}% below the market estimate. '
            'Consider the options below.',
        userBudget: userBudget,
        estimatedCost: estimatedCost,
        shortfall: estimatedCost - userBudget,
        recommendedBudget: recommended,
        suggestions: [
          'Switch to ${_prevTier(qualityTier)} quality to reduce estimate by ~${_tierSavingPct(qualityTier)}%',
          'Phase construction: grey structure now, finishing later',
          'Reduce covered area to fit within budget',
        ],
      );
    }

    return BudgetValidationResult(
      status: BudgetStatus.insufficient,
      headline: 'Insufficient Budget',
      message:
          'Your budget is significantly below the market estimate. '
          'Estimated shortfall is considerable.',
      userBudget: userBudget,
      estimatedCost: estimatedCost,
      shortfall: estimatedCost - userBudget,
      recommendedBudget: recommended,
      suggestions: [
        'Phase 1: Grey structure only (~52% of total cost)',
        'Consider a construction loan from HBL / Bank Alfalah',
        'Reduce plot coverage or floors',
      ],
    );
  }

  // ── Budget Distribution ───────────────────────────────────────────────────

  /// Distribute total budget across stage percentages.
  /// Returns { stageId → allocated amount }
  static Map<String, double> distributeAcrossStages({
    required double totalBudget,
    required List<BudgetStagePct> stages,
    double contingencyPct = 10,
  }) {
    final workingBudget = totalBudget * (1 - contingencyPct / 100);
    final totalPct = stages.fold(0.0, (s, st) => s + st.costPct);

    final result = <String, double>{};
    for (final stage in stages) {
      final normalized = totalPct > 0 ? stage.costPct / totalPct : 0.0;
      result[stage.id] = workingBudget * normalized;
    }
    return result;
  }

  // ── What-If Analysis ──────────────────────────────────────────────────────

  /// Calculates the impact of price changes on total project cost.
  static WhatIfResult whatIf({
    required double baseTotal,
    required Map<String, double> categoryAmounts,
    required List<PriceChangeInput> changes,
  }) {
    double newTotal = baseTotal;
    final impacts = <WhatIfImpact>[];

    for (final change in changes) {
      final baseAmount = categoryAmounts[change.category] ?? 0;
      final impact     = baseAmount * (change.changePct / 100);
      newTotal += impact;

      impacts.add(WhatIfImpact(
        category: change.category,
        changePct: change.changePct,
        baseAmount: baseAmount,
        impact: impact,
      ));
    }

    impacts.sort((a, b) => b.impact.abs().compareTo(a.impact.abs()));

    final totalImpact    = newTotal - baseTotal;
    final totalImpactPct = baseTotal > 0 ? (totalImpact / baseTotal) * 100 : 0.0;

    final rec = totalImpact > 0
        ? 'Costs projected to increase. Consider buying high-impact materials now to lock in prices.'
        : 'Cost outlook is favorable. You may save on this budget.';

    return WhatIfResult(
      baseTotal: baseTotal,
      newTotal: newTotal,
      totalImpact: totalImpact,
      totalImpactPct: totalImpactPct,
      impacts: impacts,
      recommendation: rec,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String _nextTier(String tier) => switch (tier) {
        'economy'  => 'standard',
        'standard' => 'premium',
        'premium'  => 'luxury',
        _          => tier,
      };

  static String _prevTier(String tier) => switch (tier) {
        'luxury'   => 'premium',
        'premium'  => 'standard',
        'standard' => 'economy',
        _          => tier,
      };

  static String _tierSavingPct(String currentTier) => switch (currentTier) {
        'luxury'  => '35–40',
        'premium' => '25–30',
        _         => '15–20',
      };
}

// ── Input value objects ───────────────────────────────────────────────────────

class BudgetStagePct {
  final String id;
  final double costPct;
  const BudgetStagePct({required this.id, required this.costPct});
}

class PriceChangeInput {
  final String category;   // e.g., 'steel', 'cement', 'labor'
  final double changePct;  // e.g., 10.0 = +10%
  const PriceChangeInput({required this.category, required this.changePct});
}
