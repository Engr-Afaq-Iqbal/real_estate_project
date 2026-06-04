import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/price_master_service.dart';
import '../../../core/services/geography_service.dart';
import '../../../core/data/price_master_data.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/utils/currency_formatter.dart';
import '../engine/material_calculator.dart';

enum MaterialCalcMode { byArea, byQuantity }

class MaterialCalculatorController extends GetxController {
  // ── Mode ──────────────────────────────────────────────────────────────────
  final mode = MaterialCalcMode.byArea.obs;

  void setMode(MaterialCalcMode m) => mode.value = m;

  // ── Category & material selection ─────────────────────────────────────────
  final selectedCategory = Rxn<MaterialCategoryData>();
  final selectedMaterial = Rxn<MaterialPriceData>();
  final selectedCityId   = 101.obs;

  List<MaterialCategoryData> get categories {
    try { return Get.find<PriceMasterService>().categories; }
    catch (_) { return PriceMasterData.categories; }
  }

  List<MaterialPriceData> get materialsForCategory {
    final cat = selectedCategory.value;
    if (cat == null) return [];
    try {
      return Get.find<PriceMasterService>().materialsForCategory(
        categoryId: cat.id,
        cityId: selectedCityId.value,
      );
    } catch (_) {
      return [];
    }
  }

  void selectCategory(MaterialCategoryData cat) {
    selectedCategory.value = cat;
    selectedMaterial.value = null;
    quantityCtrl.clear();
    result.value = null;
  }

  void selectMaterial(MaterialPriceData mat) {
    selectedMaterial.value = mat;
    priceCtrl.text = mat.price.toStringAsFixed(0);
    result.value = null;
  }

  // ── Area mode ─────────────────────────────────────────────────────────────
  final areaCtrl         = TextEditingController();
  final areaUnit         = 'sqft'.obs;
  final floors           = 1.obs;
  final fullEstimate     = Rxn<FullMaterialEstimate>();
  // Reactive hint — always subscribed so Obx never crashes
  final areaHintText     = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ever(areaUnit, (_) => _updateAreaHint());
    ever(floors,   (_) => calculateFromArea());
  }

  void onAreaChanged(String _) {
    _updateAreaHint();
    calculateFromArea();
  }

  void _updateAreaHint() {
    final val = double.tryParse(areaCtrl.text.trim());
    if (val == null || val <= 0) {
      areaHintText.value = '';
      return;
    }
    final unit = areaUnit.value;
    areaHintText.value = UnitConverter.hint(
        val, unit, unit == 'sqft' ? ['marla', 'sqm'] : ['sqft', 'marla']);
  }

  void calculateFromArea() {
    final val = double.tryParse(areaCtrl.text.trim());
    if (val == null) return;
    final sqm = UnitConverter.toSqMeters(val, areaUnit.value);
    fullEstimate.value = MaterialCalculator.estimateForArea(
      constructionAreaSqm: sqm,
      floors: floors.value,
      scope: 'full',
    );
  }

  // ── Quantity mode ─────────────────────────────────────────────────────────
  final quantityCtrl     = TextEditingController();
  final priceCtrl        = TextEditingController();
  final wasteFactor      = 1.05.obs; // 5% default wastage
  final result           = Rxn<MaterialCostResult>();

  void calculateFromQuantity() {
    final qty   = double.tryParse(quantityCtrl.text.trim());
    final price = double.tryParse(priceCtrl.text.trim().replaceAll(',', ''));
    final mat   = selectedMaterial.value;
    if (qty == null || price == null || mat == null) return;

    result.value = MaterialCalculator.costForMaterial(
      quantity: qty,
      unit: mat.unit,
      pricePerUnit: price,
      currencyCode: 'PKR',
      wasteFactor: wasteFactor.value,
    );
  }

  // ── Formatted helpers ─────────────────────────────────────────────────────
  String get formattedTotal {
    final r = result.value;
    if (r == null) return '--';
    return CurrencyFormatter.formatCompact(r.totalCost);
  }

  @override
  void onClose() {
    areaCtrl.dispose();
    quantityCtrl.dispose();
    priceCtrl.dispose();
    super.onClose();
  }
}
