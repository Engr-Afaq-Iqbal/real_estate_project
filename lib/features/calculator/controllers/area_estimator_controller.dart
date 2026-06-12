import 'package:get/get.dart';

// ── Floor data model ──────────────────────────────────────────────────────────

class FloorData {
  int bedrooms    = 3;
  int washrooms   = 2;
  int kitchens    = 1;
  int tvLounges   = 1;
  int drawingRooms = 0;
  int diningAreas = 1;
  int storeRooms  = 0;
  int staircases  = 1;
  int balconies   = 0;
  int servantRooms = 0;
  int heightFt    = 10;
  bool hasElevator = false;
  double parkingAreaSqft  = 0;
  double terraceAreaSqft  = 0;
}

// ── Material result ───────────────────────────────────────────────────────────

class MaterialResult {
  final String name;
  final String icon;
  final double quantity;
  final String unit;
  final double unitPrice;
  double get totalCost => quantity * unitPrice;

  const MaterialResult({
    required this.name,
    required this.icon,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
  });
}

// ── Estimation result ─────────────────────────────────────────────────────────

class EstimationResult {
  final double greyStructureCost;
  final double finishingCost;
  final double laborCost;
  final double plumbingElecCost;
  final double miscCost;
  final List<MaterialResult> materials;

  const EstimationResult({
    required this.greyStructureCost,
    required this.finishingCost,
    required this.laborCost,
    required this.plumbingElecCost,
    required this.miscCost,
    required this.materials,
  });

  double get totalCost =>
      greyStructureCost + finishingCost + laborCost + plumbingElecCost + miscCost;

  String get formattedTotal {
    final v = totalCost;
    if (v >= 1e7) return 'Rs ${(v / 1e7).toStringAsFixed(2)} Crore';
    if (v >= 1e5) return 'Rs ${(v / 1e5).toStringAsFixed(2)} Lakh';
    return 'Rs ${v.toStringAsFixed(0)}';
  }
}

// ── Controller ────────────────────────────────────────────────────────────────

class AreaEstimatorController extends GetxController {
  final currentStep      = 0.obs;
  final selectedCity     = 'Lahore'.obs;
  final numFloors        = 1.obs;
  final plotSizeMarla    = 0.0.obs;
  final coveredAreaSqft  = 0.0.obs;
  final quality          = 'standard'.obs;

  // Extras
  final hasDoubleHeight  = false.obs;
  final doubleHeightArea = 0.0.obs;
  final hasBasement      = false.obs;
  final hasBoundaryWall  = false.obs;
  final hasSepticTank    = false.obs;
  final hasGarden        = false.obs;
  final gardenAreaSqft   = 0.0.obs;
  final roofType         = 'rcc_slab'.obs;
  final waterTankGallons = 0.obs;

  final isCalculating = false.obs;
  final result        = Rxn<EstimationResult>();

  final _floorDataMap = <int, FloorData>{};

  // ── Static config ─────────────────────────────────────────────────────────

  static const cities = [
    'Lahore', 'Karachi', 'Islamabad', 'Rawalpindi',
    'Faisalabad', 'Multan', 'Peshawar', 'Other',
  ];

  static const cityEmojis = {
    'Lahore':     '🌿',
    'Karachi':    '🌊',
    'Islamabad':  '🏔️',
    'Rawalpindi': '🏙️',
    'Faisalabad': '🏭',
    'Multan':     '☀️',
    'Peshawar':   '🦅',
    'Other':      '📍',
  };

  static const qualities = [
    {'key': 'economy',  'label': 'Economy',  'icon': '💰'},
    {'key': 'standard', 'label': 'Standard', 'icon': '🏠'},
    {'key': 'premium',  'label': 'Premium',  'icon': '✨'},
    {'key': 'luxury',   'label': 'Luxury',   'icon': '👑'},
  ];

  static const floorHeights = [7, 8, 9, 10, 11, 12];

  static const roofTypes = [
    {'key': 'rcc_slab',    'label': 'RCC Slab',    'icon': '🏗️'},
    {'key': 'steel_truss', 'label': 'Steel Truss',  'icon': '⚙️'},
    {'key': 'precast',     'label': 'Pre-cast',     'icon': '🧱'},
    {'key': 'flat_roof',   'label': 'Flat Roof',    'icon': '🏢'},
  ];

  // ── Floor data accessors ──────────────────────────────────────────────────

  FloorData getFloor(int index) {
    return _floorDataMap.putIfAbsent(index, () => FloorData());
  }

  void refresh() => update();

  // ── Navigation ────────────────────────────────────────────────────────────

  void nextStep() {
    if (currentStep.value < 4) {
      if (currentStep.value == 3) {
        _calculate();
      }
      currentStep.value++;
    }
  }

  void prevStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  // ── Estimation engine ─────────────────────────────────────────────────────

  Future<void> _calculate() async {
    isCalculating.value = true;
    await Future.delayed(const Duration(milliseconds: 1200));

    final double area = coveredAreaSqft.value > 0 ? coveredAreaSqft.value : 2000.0;
    final floors   = numFloors.value;
    final mult     = _cityMult(selectedCity.value);
    final qMult    = _qualityMult(quality.value);

    // Base rates per sqft (Pakistan standard, Lahore base)
    const greyRatePerSqft   = 1800.0; // PKR per sqft
    const finishRatePerSqft = 1200.0;
    const laborRate         = 700.0;
    const plumbElecRate     = 600.0;

    final greyStructureCost  = area * greyRatePerSqft   * mult * qMult;
    final finishingCost      = area * finishRatePerSqft * mult * qMult;
    final laborCost          = area * laborRate          * mult * qMult;
    final plumbingElecCost   = area * plumbElecRate      * mult * qMult;

    // Extras
    double extrasTotal = 0;
    if (hasBasement.value)    extrasTotal += area * 0.3 * 1500 * mult;
    if (hasBoundaryWall.value) extrasTotal += 150000 * mult;
    if (hasSepticTank.value)  extrasTotal += 80000 * mult;
    if (hasGarden.value)      extrasTotal += gardenAreaSqft.value * 200 * mult;
    if (hasDoubleHeight.value) extrasTotal += doubleHeightArea.value * 500 * mult;

    final subTotal =
        greyStructureCost + finishingCost + laborCost + plumbingElecCost + extrasTotal;
    final miscCost = subTotal * 0.10;

    // Material quantities (per sqft approximations)
    final materials = _estimateMaterials(area, floors, mult, qMult);

    result.value = EstimationResult(
      greyStructureCost: greyStructureCost,
      finishingCost: finishingCost,
      laborCost: laborCost,
      plumbingElecCost: plumbingElecCost,
      miscCost: miscCost,
      materials: materials,
    );

    isCalculating.value = false;
  }

  List<MaterialResult> _estimateMaterials(
      double area, int floors, double cityMult, double qualityMult) {
    final total    = area * floors;
    final floorsDbl = floors.toDouble();

    return [
      MaterialResult(
        name: 'Cement', icon: '🏗️',
        quantity: (total / 100 * 6).roundToDouble(),
        unit: 'bags',
        unitPrice: 1420.0 * cityMult,
      ),
      MaterialResult(
        name: 'Steel (Sariya)', icon: '⚙️',
        quantity: (total * 0.004 * qualityMult).roundToDouble(),
        unit: 'kg',
        unitPrice: 288.0 * cityMult,
      ),
      MaterialResult(
        name: 'Sand', icon: '🏖️',
        quantity: (total / 100 * 4.5).roundToDouble(),
        unit: 'cft',
        unitPrice: 55.0 * cityMult,
      ),
      MaterialResult(
        name: 'Crush (Bajri)', icon: '🪨',
        quantity: (total / 100 * 3).roundToDouble(),
        unit: 'cft',
        unitPrice: 78.0 * cityMult,
      ),
      MaterialResult(
        name: 'Bricks', icon: '🧱',
        quantity: (total * 0.45).roundToDouble(),
        unit: 'pcs',
        unitPrice: 18.5 * cityMult,
      ),
      MaterialResult(
        name: 'Floor Tiles', icon: '🔲',
        quantity: (area * 0.9 * qualityMult).roundToDouble(),
        unit: 'sqft',
        unitPrice: 280.0 * cityMult,
      ),
      MaterialResult(
        name: 'Paint (Emulsion)', icon: '🎨',
        quantity: (total / 100 * 2).roundToDouble(),
        unit: 'drums (20L)',
        unitPrice: 8800.0 * cityMult,
      ),
      MaterialResult(
        name: 'Copper Wire', icon: '⚡',
        quantity: (total / 100 * 120).roundToDouble(),
        unit: 'meters',
        unitPrice: 19.2 * cityMult,
      ),
      MaterialResult(
        name: 'PVC Pipe 4"', icon: '🚿',
        quantity: (floorsDbl * 8).roundToDouble(),
        unit: 'pieces',
        unitPrice: 415.0 * cityMult,
      ),
      MaterialResult(
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

  double _qualityMult(String q) => switch (q) {
        'economy' => 0.75,
        'premium' => 1.40,
        'luxury'  => 2.00,
        _         => 1.00,
      };
}
