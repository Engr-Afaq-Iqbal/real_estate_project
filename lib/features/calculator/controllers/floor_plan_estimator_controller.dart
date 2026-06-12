import 'package:get/get.dart';

// ── Data models ───────────────────────────────────────────────────────────────

class UploadedPlan {
  final String displayName;
  final String fileType; // PDF / JPG / PNG
  final String fileSize;
  final String filePath;

  const UploadedPlan({
    required this.displayName,
    required this.fileType,
    required this.fileSize,
    required this.filePath,
  });
}

class FloorBreakdown {
  final String name;
  final String icon;
  final double areaSqft;
  final int rooms;
  final double cost;

  const FloorBreakdown({
    required this.name,
    required this.icon,
    required this.areaSqft,
    required this.rooms,
    required this.cost,
  });

  String get formattedCost {
    if (cost >= 1e7) return 'Rs ${(cost / 1e7).toStringAsFixed(1)}Cr';
    if (cost >= 1e5) return 'Rs ${(cost / 1e5).toStringAsFixed(1)}L';
    return 'Rs ${cost.toStringAsFixed(0)}';
  }
}

class PlanMaterialResult {
  final String name;
  final String icon;
  final double quantity;
  final String unit;
  final double unitPrice;

  const PlanMaterialResult({
    required this.name,
    required this.icon,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
  });

  double get totalCost => quantity * unitPrice;

  String get formattedCost {
    final c = totalCost;
    if (c >= 1e7) return 'Rs ${(c / 1e7).toStringAsFixed(1)}Cr';
    if (c >= 1e5) return 'Rs ${(c / 1e5).toStringAsFixed(1)}L';
    return 'Rs ${c.toStringAsFixed(0)}';
  }
}

class FloorPlanEstimationResult {
  final double greyStructureCost;
  final double finishingCost;
  final double labourCost;
  final List<FloorBreakdown> floorBreakdowns;
  final List<PlanMaterialResult> materials;

  const FloorPlanEstimationResult({
    required this.greyStructureCost,
    required this.finishingCost,
    required this.labourCost,
    required this.floorBreakdowns,
    required this.materials,
  });

  double get totalCost => greyStructureCost + finishingCost + labourCost;

  String get formattedTotal {
    final v = totalCost;
    if (v >= 1e7) return 'Rs ${(v / 1e7).toStringAsFixed(2)} Crore';
    if (v >= 1e5) return 'Rs ${(v / 1e5).toStringAsFixed(2)} Lakh';
    return 'Rs ${v.toStringAsFixed(0)}';
  }

  String get formattedGrey {
    if (greyStructureCost >= 1e5) return 'Rs ${(greyStructureCost / 1e5).toStringAsFixed(1)}L';
    return 'Rs ${greyStructureCost.toStringAsFixed(0)}';
  }

  String get formattedFinishing {
    if (finishingCost >= 1e5) return 'Rs ${(finishingCost / 1e5).toStringAsFixed(1)}L';
    return 'Rs ${finishingCost.toStringAsFixed(0)}';
  }

  String get formattedLabour {
    if (labourCost >= 1e5) return 'Rs ${(labourCost / 1e5).toStringAsFixed(1)}L';
    return 'Rs ${labourCost.toStringAsFixed(0)}';
  }
}

// ── Controller ────────────────────────────────────────────────────────────────

class FloorPlanEstimatorController extends GetxController {
  // Steps: 0 = upload, 1 = processing/AI, 2 = results
  final currentStep     = 0.obs;
  final uploadedPlans   = <UploadedPlan>[].obs;
  final selectedCity    = 'Lahore'.obs;
  final analyzeProgress = 0.0.obs;
  final result          = Rxn<FloorPlanEstimationResult>();

  static const cities = [
    'Lahore', 'Karachi', 'Islamabad', 'Rawalpindi',
    'Faisalabad', 'Multan', 'Peshawar',
  ];

  // Simulate file picker (real integration needs file_picker package)
  void pickFile() {
    final count = uploadedPlans.length;
    final floorName = switch (count) {
      0 => 'Ground Floor',
      1 => 'First Floor',
      2 => 'Second Floor',
      3 => 'Third Floor',
      _ => 'Floor ${count + 1}',
    };
    uploadedPlans.add(UploadedPlan(
      displayName: '$floorName Plan.pdf',
      fileType: 'PDF',
      fileSize: '${(1.2 + count * 0.4).toStringAsFixed(1)} MB',
      filePath: '/mock/floor_${count + 1}.pdf',
    ));
  }

  void removePlan(int index) {
    if (index < uploadedPlans.length) {
      uploadedPlans.removeAt(index);
    }
  }

  Future<void> analyzeAndEstimate() async {
    currentStep.value = 1;
    analyzeProgress.value = 0.0;

    // Simulate AI processing progress
    final steps = [0.12, 0.28, 0.45, 0.62, 0.78, 0.90, 1.0];
    for (final step in steps) {
      await Future.delayed(const Duration(milliseconds: 600));
      analyzeProgress.value = step;
    }

    await Future.delayed(const Duration(milliseconds: 400));
    _buildResult();
    currentStep.value = 2;
  }

  void _buildResult() {
    final planCount = uploadedPlans.length.clamp(1, 5);
    final cityMult = _cityMult(selectedCity.value);

    // Simulate per-floor analysis: each floor ~1800 sqft, 5-7 rooms
    final floorBreakdowns = <FloorBreakdown>[];
    final floorIcons = ['🏠', '🏢', '🌇', '🌆', '🌃'];
    final floorNames = ['Ground Floor', 'First Floor', 'Second Floor', 'Third Floor', 'Penthouse'];

    double totalArea = 0;
    for (int i = 0; i < planCount; i++) {
      final area = 1800.0 + (i * 120);
      final rooms = 6 - i;
      final cost = area * 2400 * cityMult;
      totalArea += area;
      floorBreakdowns.add(FloorBreakdown(
        name: floorNames[i],
        icon: floorIcons[i],
        areaSqft: area,
        rooms: rooms.clamp(3, 8),
        cost: cost,
      ));
    }

    final greyStructureCost = totalArea * 1800 * cityMult;
    final finishingCost     = totalArea * 1200 * cityMult;
    final labourCost        = totalArea * 700 * cityMult;

    final materials = _estimateMaterials(totalArea, planCount, cityMult);

    result.value = FloorPlanEstimationResult(
      greyStructureCost: greyStructureCost,
      finishingCost: finishingCost,
      labourCost: labourCost,
      floorBreakdowns: floorBreakdowns,
      materials: materials,
    );
  }

  List<PlanMaterialResult> _estimateMaterials(
      double area, int floors, double cityMult) {
    final total = area * floors;
    return [
      PlanMaterialResult(
        name: 'Cement', icon: '🏗️',
        quantity: (total / 100 * 6).roundToDouble(),
        unit: 'bags',
        unitPrice: 1420 * cityMult,
      ),
      PlanMaterialResult(
        name: 'Steel Rebar', icon: '⚙️',
        quantity: (total * 0.004).roundToDouble(),
        unit: 'kg',
        unitPrice: 288 * cityMult,
      ),
      PlanMaterialResult(
        name: 'Sand', icon: '🏖️',
        quantity: (total / 100 * 4.5).roundToDouble(),
        unit: 'cft',
        unitPrice: 55 * cityMult,
      ),
      PlanMaterialResult(
        name: 'Crush (Bajri)', icon: '🪨',
        quantity: (total / 100 * 3).roundToDouble(),
        unit: 'cft',
        unitPrice: 78 * cityMult,
      ),
      PlanMaterialResult(
        name: 'Bricks', icon: '🧱',
        quantity: (total * 0.45).roundToDouble(),
        unit: 'pcs',
        unitPrice: 18.5 * cityMult,
      ),
      PlanMaterialResult(
        name: 'Floor Tiles', icon: '🔲',
        quantity: (area * 0.9).roundToDouble(),
        unit: 'sqft',
        unitPrice: 280 * cityMult,
      ),
      PlanMaterialResult(
        name: 'Paint (Emulsion)', icon: '🎨',
        quantity: (total / 100 * 2).roundToDouble(),
        unit: 'drums',
        unitPrice: 8800 * cityMult,
      ),
      PlanMaterialResult(
        name: 'Copper Wire', icon: '⚡',
        quantity: (total / 100 * 120).roundToDouble(),
        unit: 'meters',
        unitPrice: 19.2 * cityMult,
      ),
      PlanMaterialResult(
        name: 'PVC Pipe 4"', icon: '🚿',
        quantity: (floors * 8).toDouble(),
        unit: 'pieces',
        unitPrice: 415 * cityMult,
      ),
      PlanMaterialResult(
        name: 'Waterproofing', icon: '💧',
        quantity: (total / 1000 * 4).roundToDouble(),
        unit: 'drums',
        unitPrice: 4400 * cityMult,
      ),
    ];
  }

  double _cityMult(String city) => switch (city) {
        'Karachi'    => 1.05,
        'Islamabad'  => 1.08,
        'Rawalpindi' => 1.06,
        'Faisalabad' => 0.97,
        'Multan'     => 0.95,
        'Peshawar'   => 0.98,
        _            => 1.00,
      };

  void reset() {
    currentStep.value = 0;
    uploadedPlans.clear();
    analyzeProgress.value = 0.0;
    result.value = null;
  }
}
