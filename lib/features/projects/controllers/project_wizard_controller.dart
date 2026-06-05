import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../config/wizard_step_config.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/utils/currency_formatter.dart';

const _uuid = Uuid();

/// 6-step project creation wizard controller.
///
/// Step 0: Project Type
/// Step 1: Dynamic Details (per type)
/// Step 2: Location + Plot & Area
/// Step 3: Budget + Timeline
/// Step 4: Team
/// Step 5: Review + Interactive Timeline
class ProjectWizardController extends GetxController {
  static const int totalSteps = 6;

  // ── Step navigation ───────────────────────────────────────────────────────
  final currentStep   = 0.obs;
  final isAnimating   = false.obs;

  bool get isFirstStep => currentStep.value == 0;
  bool get isLastStep  => currentStep.value == totalSteps - 1;

  void nextStep() {
    if (currentStep.value < totalSteps - 1) currentStep.value++;
  }

  void prevStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) currentStep.value = step;
  }

  // ── Step 0: Project Type ──────────────────────────────────────────────────
  final selectedTypeKey = 'house'.obs;

  ProjectTypeConfig get selectedConfig =>
      configForType(selectedTypeKey.value) ?? kProjectTypeConfigs.first;

  void selectType(String key) {
    selectedTypeKey.value = key;
    _resetStep2Fields();
    stages.value = _generateStages();
  }

  String get projectTypeLabel => selectedConfig.label;

  // ── Step 1: Dynamic fields ────────────────────────────────────────────────
  // Stores current values keyed by field.key
  final fieldValues = <String, dynamic>{}.obs;

  void _resetStep2Fields() {
    fieldValues.clear();
    for (final field in selectedConfig.step2Fields) {
      if (field.defaultValue != null) {
        fieldValues[field.key] = field.defaultValue;
      }
    }
    // Initialize quality
    fieldValues['quality'] ??= 'Standard';
  }

  void setFieldValue(String key, dynamic value) {
    fieldValues[key] = value;
    fieldValues.refresh();
    if (key == 'floors' || key == 'quality') {
      stages.value = _generateStages();
    }
  }

  T? getFieldValue<T>(String key) => fieldValues[key] as T?;

  // Chip multi-select helper
  void toggleChipValue(String fieldKey, String option) {
    final current = List<String>.from(fieldValues[fieldKey] as List<String>? ?? []);
    if (current.contains(option)) {
      current.remove(option);
    } else {
      current.add(option);
    }
    fieldValues[fieldKey] = current;
    fieldValues.refresh();
  }

  bool isChipSelected(String fieldKey, String option) {
    final current = fieldValues[fieldKey];
    if (current is List) return current.contains(option);
    if (current is String) return current == option;
    return false;
  }

  @override
  void onInit() {
    super.onInit();
    _resetStep2Fields();
    ever(plotUnit,             (_) { _updatePlotHint(); _updatePlotSqm(); });
    ever(constructionAreaUnit, (_) => _updateConstructionSqm());
    stages.value = _generateStages();
  }

  // ── Step 2: Location ──────────────────────────────────────────────────────
  final selectedCountryCode = 'PK'.obs;
  final selectedCity        = 'Lahore'.obs;
  final customCity          = ''.obs;
  final neighbourhood       = ''.obs;

  CountryInfo get selectedCountry {
    try { return kAllCountries.firstWhere((c) => c.code == selectedCountryCode.value); }
    catch (_) { return kAllCountries.first; }
  }

  List<String> get citiesForCountry => selectedCountry.cities;

  String get currencyCode => selectedCountry.currency;

  void selectCountry(String code) {
    selectedCountryCode.value = code;
    final cities = kAllCountries.firstWhere(
        (c) => c.code == code, orElse: () => kAllCountries.first).cities;
    selectedCity.value = cities.isNotEmpty ? cities.first : '';
    customCity.value   = '';
  }

  void selectCity(String city) {
    selectedCity.value = city;
    customCity.value   = '';
  }

  String get effectiveCity =>
      customCity.value.isNotEmpty ? customCity.value : selectedCity.value;

  // ── Step 2: Plot & Area ───────────────────────────────────────────────────
  final plotSizeCtrl          = TextEditingController();
  final plotUnit              = 'marla'.obs;
  final constructionAreaCtrl  = TextEditingController();
  final constructionAreaUnit  = 'marla'.obs;
  final plotWidthCtrl         = TextEditingController();
  final plotDepthCtrl         = TextEditingController();

  final plotHintText          = ''.obs;
  // Reactive sqm values — always subscribed so Obx never crashes on first render
  final plotSizeSqmObs        = Rxn<double>();
  final constructionAreaSqmObs = Rxn<double>();

  bool get showPlotArea => selectedConfig.showPlotArea;

  double? get plotSizeSqm => plotSizeSqmObs.value;

  double? get constructionAreaSqm => constructionAreaSqmObs.value;

  double? get plotWidthM {
    final val = double.tryParse(plotWidthCtrl.text.trim());
    return val != null ? val * 0.3048 : null; // ft to m
  }

  double? get plotDepthM {
    final val = double.tryParse(plotDepthCtrl.text.trim());
    return val != null ? val * 0.3048 : null; // ft to m
  }

  void _updatePlotSqm() {
    final val = double.tryParse(plotSizeCtrl.text.trim());
    plotSizeSqmObs.value = val != null && val > 0
        ? UnitConverter.toSqMeters(val, plotUnit.value)
        : null;
  }

  void _updateConstructionSqm() {
    final val = double.tryParse(constructionAreaCtrl.text.trim());
    constructionAreaSqmObs.value = val != null && val > 0
        ? UnitConverter.toSqMeters(val, constructionAreaUnit.value)
        : null;
  }

  void onPlotSizeChanged(String value) {
    _updatePlotHint();
    _updatePlotSqm();
    if (constructionAreaCtrl.text.trim().isEmpty) {
      final v = double.tryParse(value);
      if (v != null) {
        constructionAreaCtrl.text = (v * 0.9).toStringAsFixed(2);
        _updateConstructionSqm();
      }
    }
    _updateBudgetEstimate();
    stages.value = _generateStages();
  }

  void _updatePlotHint() {
    final val = double.tryParse(plotSizeCtrl.text.trim());
    if (val == null || val <= 0) { plotHintText.value = ''; return; }
    final unit = plotUnit.value;
    plotHintText.value = UnitConverter.hint(
        val, unit, unit == 'marla' ? ['sqft', 'sqm'] : ['marla', 'sqft']);
  }

  // ── Step 3: Budget ────────────────────────────────────────────────────────
  final budgetCtrl      = TextEditingController();
  final estimatedCostLow  = 0.0.obs;
  final estimatedCostHigh = 0.0.obs;

  double get budget =>
      double.tryParse(budgetCtrl.text.trim().replaceAll(',', '')) ?? 0;

  void onBudgetChanged(String _) => _updateBudgetEstimate();

  void _updateBudgetEstimate() {
    final areaSqm = constructionAreaSqm ?? plotSizeSqm;
    if (areaSqm == null || areaSqm <= 0) {
      estimatedCostLow.value  = 0;
      estimatedCostHigh.value = 0;
      return;
    }
    final quality = fieldValues['quality'] as String? ?? 'Standard';
    final floors  = fieldValues['floors'] as int? ?? 1;
    final sqft    = UnitConverter.fromSqMeters(areaSqm, 'sqft') * floors;

    final rates = {
      'Economy':  const [1400.0, 1800.0],
      'Standard': const [2000.0, 2600.0],
      'Premium':  const [3000.0, 4000.0],
      'Luxury':   const [5000.0, 7000.0],
    };
    final rate = rates[quality] ?? rates['Standard']!;
    estimatedCostLow.value  = sqft * rate[0];
    estimatedCostHigh.value = sqft * rate[1];
  }

  String get formattedEstimateRange {
    if (estimatedCostLow.value <= 0) return '';
    return '${CurrencyFormatter.formatCompact(estimatedCostLow.value, currency: currencyCode)} '
        '– ${CurrencyFormatter.formatCompact(estimatedCostHigh.value, currency: currencyCode)}';
  }

  // ── Step 3: Timeline ──────────────────────────────────────────────────────
  final startDate         = DateTime.now().obs;
  final stages            = <WizardStage>[].obs;
  final isGenerating      = false.obs;
  final editModeActive    = false.obs;  // for Step 6 interactive timeline

  List<WizardStage> _generateStages() {
    final templates = selectedConfig.stages;
    final quality   = fieldValues['quality'] as String? ?? 'Standard';
    final areaSqm   = constructionAreaSqm ?? plotSizeSqm ?? 126.0;
    final raw       = templates.asMap().entries.map((e) => WizardStage(
      id: _uuid.v4(),
      name: e.value.name,
      durationDays: scaleDuration(e.value.baseDurationDays, areaSqm, quality),
      costPct: e.value.costPct,
      color: e.value.color,
      order: e.key,
    )).toList();
    return computeStageDates(raw, startDate.value);
  }

  Future<void> generateTimeline() async {
    isGenerating.value = true;
    await Future.delayed(const Duration(milliseconds: 600));
    stages.value = _generateStages();
    isGenerating.value = false;
  }

  // Drag-and-drop reorder
  void reorderStages(int oldIndex, int newIndex) {
    final list = List<WizardStage>.from(stages);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
    stages.value = computeStageDates(list, startDate.value);
  }

  void deleteStage(String id) {
    final list = stages.where((s) => s.id != id).toList();
    stages.value = computeStageDates(list, startDate.value);
  }

  void toggleEditMode() => editModeActive.value = !editModeActive.value;

  // ── Step 4: Team ──────────────────────────────────────────────────────────
  final contractorType        = 'self'.obs;
  final companyCodeCtrl       = TextEditingController();
  final supervisorPhoneCtrl   = TextEditingController();
  final companyVerified       = false.obs;
  final companyRequestSent    = false.obs;

  List<TeamOption> get teamOptions => selectedConfig.teamOptions;

  Future<void> verifyCompanyCode() async {
    if (companyCodeCtrl.text.trim().isEmpty) return;
    await Future.delayed(const Duration(seconds: 1));
    companyRequestSent.value = true;
  }

  // ── Step 5: Create project ────────────────────────────────────────────────
  final isCreating = false.obs;

  Future<void> createProject() async {
    isCreating.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isCreating.value = false;
    Get.back();
    Get.snackbar(
      'Project Created',
      '${fieldValues['name'] ?? selectedConfig.label} has been created successfully',
      duration: const Duration(seconds: 3),
    );
  }

  // ── Validation ────────────────────────────────────────────────────────────
  bool isStepValid(int step) => switch (step) {
        0 => selectedTypeKey.value.isNotEmpty,
        1 => true,
        2 => selectedCountryCode.value.isNotEmpty,
        3 => true,
        4 => true,
        5 => true,
        _ => false,
      };

  bool get canContinue => isStepValid(currentStep.value);

  // ── Cleanup ───────────────────────────────────────────────────────────────
  @override
  void onClose() {
    plotSizeCtrl.dispose();
    constructionAreaCtrl.dispose();
    plotWidthCtrl.dispose();
    plotDepthCtrl.dispose();
    budgetCtrl.dispose();
    companyCodeCtrl.dispose();
    supervisorPhoneCtrl.dispose();
    super.onClose();
  }
}
