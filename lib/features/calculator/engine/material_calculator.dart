import '../../../core/utils/unit_converter.dart';

// ── Results ───────────────────────────────────────────────────────────────────

class CementEstimate {
  final int structureBags;
  final int plasterBags;
  final int totalBags;

  const CementEstimate({
    required this.structureBags,
    required this.plasterBags,
    required this.totalBags,
  });
}

class SteelEstimate {
  final double kg;
  final double tons;

  const SteelEstimate({required this.kg, required this.tons});
}

class BrickEstimate {
  final int quantity;    // with wastage included
  final int base;        // without wastage
  final double wasteFactor;

  const BrickEstimate({
    required this.quantity,
    required this.base,
    required this.wasteFactor,
  });
}

class SandEstimate {
  final double cft;
  const SandEstimate({required this.cft});
}

class CrushEstimate {
  final double cft;
  const CrushEstimate({required this.cft});
}

class FullMaterialEstimate {
  final double areaSqft;
  final int floors;
  final CementEstimate cement;
  final SteelEstimate steel;
  final BrickEstimate bricks;
  final SandEstimate sand;
  final CrushEstimate crush;

  double get totalAreaSqft => areaSqft * floors;

  const FullMaterialEstimate({
    required this.areaSqft,
    required this.floors,
    required this.cement,
    required this.steel,
    required this.bricks,
    required this.sand,
    required this.crush,
  });
}

// ── Single material cost ──────────────────────────────────────────────────────

class MaterialCostResult {
  final double baseQuantity;
  final double wasteQuantity;
  final double adjustedQuantity;
  final double unitPrice;
  final double totalCost;
  final String unit;
  final String currencyCode;

  const MaterialCostResult({
    required this.baseQuantity,
    required this.wasteQuantity,
    required this.adjustedQuantity,
    required this.unitPrice,
    required this.totalCost,
    required this.unit,
    required this.currencyCode,
  });
}

// ── What-if ───────────────────────────────────────────────────────────────────

class WhatIfSingleResult {
  final double currentCost;
  final double futureCost;
  final double difference;
  final double pctChange;
  final String recommendation;

  const WhatIfSingleResult({
    required this.currentCost,
    required this.futureCost,
    required this.difference,
    required this.pctChange,
    required this.recommendation,
  });

  bool get isPriceIncrease => pctChange > 0;
}

// ── Calculator ────────────────────────────────────────────────────────────────

class MaterialCalculator {
  MaterialCalculator._();

  // ── Full material estimate for a structure ────────────────────────────────

  /// Calculates all materials needed for a construction area.
  /// areaSqm is the construction area per floor.
  static FullMaterialEstimate estimateForArea({
    required double constructionAreaSqm,
    required int floors,
    required String scope, // 'full', 'structure_only', 'finishing_only'
  }) {
    final areaSqft = UnitConverter.fromSqMeters(constructionAreaSqm, 'sqft');
    final totalSqft = areaSqft * floors;

    // ── Cement: ~0.50 bags per sqft total (structure + plaster)
    final structureBags = (totalSqft * 0.38).ceil();
    final plasterBags   = (totalSqft * 0.12).ceil();
    final totalBags     = structureBags + plasterBags;

    // ── Steel: ~3.2 kg per sqft for RCC (columns + beams + slabs)
    final steelKg   = totalSqft * 3.2;
    final steelTons = steelKg / 1000;

    // ── Bricks: assume 30% of area is walls, 4.5" thick = 55 bricks/sqft
    final baseQty = (totalSqft * 0.30 * 55).ceil();
    final withWaste = (baseQty * 1.05).ceil(); // 5% wastage

    // ── Sand: ~0.6 cft per sqft
    final sandCft = totalSqft * 0.6;

    // ── Crush: ~0.45 cft per sqft
    final crushCft = totalSqft * 0.45;

    return FullMaterialEstimate(
      areaSqft: areaSqft,
      floors: floors,
      cement: CementEstimate(
        structureBags: structureBags,
        plasterBags: plasterBags,
        totalBags: totalBags,
      ),
      steel: SteelEstimate(kg: steelKg, tons: steelTons),
      bricks: BrickEstimate(
        quantity: withWaste,
        base: baseQty,
        wasteFactor: 1.05,
      ),
      sand: SandEstimate(cft: sandCft),
      crush: CrushEstimate(cft: crushCft),
    );
  }

  // ── Single material cost ──────────────────────────────────────────────────

  /// Calculates the cost for a specific quantity at a given price.
  static MaterialCostResult costForMaterial({
    required double quantity,
    required String unit,
    required double pricePerUnit,
    required String currencyCode,
    double wasteFactor = 1.0, // e.g., 1.05 = 5% wastage
  }) {
    final adjusted = quantity * wasteFactor;
    final waste    = adjusted - quantity;

    return MaterialCostResult(
      baseQuantity: quantity,
      wasteQuantity: waste,
      adjustedQuantity: adjusted,
      unitPrice: pricePerUnit,
      totalCost: adjusted * pricePerUnit,
      unit: unit,
      currencyCode: currencyCode,
    );
  }

  // ── What-if single material ───────────────────────────────────────────────

  /// Compares current vs future price for a quantity of material.
  static WhatIfSingleResult whatIfSingleMaterial({
    required double quantity,
    required double currentPrice,
    required double futurePrice,
    required String unit,
    required String currencyCode,
  }) {
    final currentCost = quantity * currentPrice;
    final futureCost  = quantity * futurePrice;
    final diff        = futureCost - currentCost;
    final pct         = currentCost > 0 ? (diff / currentCost) * 100 : 0.0;

    String rec;
    if (pct > 5) {
      rec = 'Price is expected to rise by ${pct.toStringAsFixed(1)}%. '
            'Consider purchasing now to save on costs.';
    } else if (pct < -5) {
      rec = 'Price is projected to fall by ${(-pct).toStringAsFixed(1)}%. '
            'It may be worth waiting before purchasing.';
    } else {
      rec = 'Price change is minimal (${pct.toStringAsFixed(1)}%). '
            'No urgent action needed.';
    }

    return WhatIfSingleResult(
      currentCost: currentCost,
      futureCost: futureCost,
      difference: diff,
      pctChange: pct,
      recommendation: rec,
    );
  }

  // ── Tile calculator ───────────────────────────────────────────────────────

  /// How many tiles needed for a given area.
  static TileEstimate tilesForArea({
    required double areaSqft,
    required double tileSizeInches,  // e.g., 24 for 24"×24"
    double wasteFactor = 1.10,       // 10% standard wastage for tiles
  }) {
    final tileSqft = (tileSizeInches / 12) * (tileSizeInches / 12);
    final base     = (areaSqft / tileSqft).ceil();
    final withWaste = (base * wasteFactor).ceil();

    return TileEstimate(
      baseCount: base,
      withWasteCount: withWaste,
      tileSizeInches: tileSizeInches,
      areaSqft: areaSqft,
    );
  }

  // ── Paint calculator ──────────────────────────────────────────────────────

  /// How many liters of paint for a wall area.
  /// Coverage: ~10–12 sqft per liter (1 coat), assume 2 coats.
  static PaintEstimate paintForArea({
    required double wallAreaSqft,
    double coveragePerLiter = 11.0,  // sqft per liter per coat
    int coats = 2,
  }) {
    final liters = (wallAreaSqft / coveragePerLiter) * coats;
    return PaintEstimate(
      liters: liters,
      wallAreaSqft: wallAreaSqft,
      coats: coats,
    );
  }
}

// ── Additional result types ───────────────────────────────────────────────────

class TileEstimate {
  final int baseCount;
  final int withWasteCount;
  final double tileSizeInches;
  final double areaSqft;

  const TileEstimate({
    required this.baseCount,
    required this.withWasteCount,
    required this.tileSizeInches,
    required this.areaSqft,
  });
}

class PaintEstimate {
  final double liters;
  final double wallAreaSqft;
  final int coats;

  const PaintEstimate({
    required this.liters,
    required this.wallAreaSqft,
    required this.coats,
  });
}
