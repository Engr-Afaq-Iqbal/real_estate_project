import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/geography_service.dart';
import '../../../core/services/price_master_service.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../projects/engine/budget_engine.dart';
import '../data/models/saved_calculation_model.dart';
import 'package:uuid/uuid.dart';

const _uuidCalc = Uuid();

class HouseEstimatorController extends GetxController {
  // ── Step navigation ───────────────────────────────────────────────────────
  static const int totalSteps = 3;
  final currentStep = 0.obs;

  void nextStep() {
    if (currentStep.value < totalSteps - 1) currentStep.value++;
    if (currentStep.value == totalSteps - 1) _runEstimation();
  }

  void prevStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  // ── Step 0: Plot & Area ───────────────────────────────────────────────────
  final plotSizeCtrl         = TextEditingController();
  final plotUnit             = 'marla'.obs;
  final constructionCtrl     = TextEditingController();
  final constructionUnit     = 'marla'.obs;
  final floors               = 1.obs;

  // Reactive hint text — always has a value so Obx always subscribes
  final constructionHintText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Recalculate hint whenever unit changes
    ever(constructionUnit, (_) => _updateHint());
  }

  void onConstructionAreaChanged(String value) {
    _updateHint();
  }

  void _updateHint() {
    final text = constructionCtrl.text.trim();
    final val  = double.tryParse(text);
    if (val == null || val <= 0) {
      constructionHintText.value = '';
      return;
    }
    final unit = constructionUnit.value;
    constructionHintText.value = UnitConverter.hint(
      val,
      unit,
      unit == 'marla' ? ['sqft', 'sqm'] : ['marla', 'sqft'],
    );
  }

  double? get constructionAreaSqm {
    final val = double.tryParse(constructionCtrl.text.trim());
    if (val == null) return null;
    return UnitConverter.toSqMeters(val, constructionUnit.value);
  }

  bool get step0Valid =>
      constructionAreaSqm != null && constructionAreaSqm! > 0;

  // ── Step 1: Quality & Location ────────────────────────────────────────────
  final qualityTier   = 'standard'.obs;
  final selectedCityId = 101.obs;
  final isRenovation  = false.obs;

  List<CityData> get cities {
    try { return Get.find<GeographyService>().citiesForCountry(1); }
    catch (_) { return []; }
  }

  String get selectedCityName {
    try { return cities.firstWhere((c) => c.id == selectedCityId.value).name; }
    catch (_) { return 'Lahore'; }
  }

  bool get step1Valid => true;

  // ── Step 2: Results ───────────────────────────────────────────────────────
  final estimate     = Rxn<HouseEstimateBreakdown>();
  final isCalculating = false.obs;

  String get formattedTotal =>
      estimate.value != null
          ? CurrencyFormatter.formatCompact(estimate.value!.total, currency: 'PKR')
          : '--';

  String get ratePerSqft =>
      estimate.value != null
          ? 'PKR ${CurrencyFormatter.formatNumber(estimate.value!.ratePerSqft)}/sqft'
          : '';

  Future<void> _runEstimation() async {
    final areaSqm = constructionAreaSqm;
    if (areaSqm == null) return;

    isCalculating.value = true;
    await Future.delayed(const Duration(milliseconds: 400));

    try {
      final result = BudgetEngine.estimateHouse(
        constructionAreaSqm: areaSqm,
        floors: floors.value,
        qualityTier: qualityTier.value,
        cityId: selectedCityId.value,
      );
      estimate.value = result;
    } catch (_) {
      estimate.value = null;
    }
    isCalculating.value = false;
  }

  // ── Save calculation ──────────────────────────────────────────────────────
  final isSaving = false.obs;

  Future<void> saveCalculation(String title) async {
    final est = estimate.value;
    if (est == null) return;

    isSaving.value = true;
    await Future.delayed(const Duration(milliseconds: 600));

    final saved = SavedCalculationModel(
      id: _uuidCalc.v4(),
      calcType: 'full_house',
      title: title.isNotEmpty ? title : 'House Estimate — ${selectedCityName}',
      cityId: selectedCityId.value,
      cityName: selectedCityName,
      currencyCode: 'PKR',
      inputs: {
        'construction_area_sqm': constructionAreaSqm,
        'floors': floors.value,
        'quality_tier': qualityTier.value,
        'city_id': selectedCityId.value,
      },
      results: {
        'total': est.total,
        'subtotal': est.subtotal,
        'contingency': est.contingency,
        'rate_per_sqft': est.ratePerSqft,
        'components': est.components,
      },
      priceBasisDate: est.priceDate,
      totalAmount: est.total,
      createdAt: DateTime.now(),
    );

    isSaving.value = false;
    Get.back();
    Get.snackbar('Saved', '"${saved.title}" saved to calculations');
  }

  // ── Component label mapping ───────────────────────────────────────────────
  static String componentLabel(String key) => switch (key) {
        'foundation'    => 'Foundation',
        'structure'     => 'Structure (RCC)',
        'blockwork'     => 'Brick / Block Work',
        'plaster'       => 'Plaster',
        'flooring'      => 'Flooring',
        'plumbing'      => 'Plumbing',
        'electrical'    => 'Electrical',
        'paint'         => 'Paint',
        'doors_windows' => 'Doors & Windows',
        'ceiling'       => 'Ceiling',
        'kitchen'       => 'Kitchen & Fixtures',
        _               => key,
      };

  @override
  void onClose() {
    plotSizeCtrl.dispose();
    constructionCtrl.dispose();
    super.onClose();
  }
}
