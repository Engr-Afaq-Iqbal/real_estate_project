import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../data/models/project_model.dart';
import '../data/models/project_scope_model.dart';
import '../data/models/stage_model.dart';
import '../engine/timeline_engine.dart';
import '../engine/budget_engine.dart';
import '../../../core/services/geography_service.dart';
import '../../../core/services/price_master_service.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../presentation/routes/app_routes.dart';

const _uuid = Uuid();

/// 8-step project creation wizard.
/// Step index → step name:
///   0: Project Type
///   1: Quick Details (name, floors, quality)
///   2: Location (country → city → area)
///   3: Plot & Area (size, unit, dimensions)
///   4: Budget (with live estimation + validation)
///   5: Timeline Preview (start date → auto-generate)
///   6: Team (contractor type, supervisor — optional)
///   7: Review & Create
class ProjectWizardController extends GetxController {
  static const int totalSteps = 8;

  @override
  void onInit() {
    super.onInit();
    // Recalculate hint whenever unit changes (even before text changes)
    ever(plotUnit, (_) => _updatePlotHint());
  }

  // ── Step navigation ───────────────────────────────────────────────────────
  final currentStep = 0.obs;

  bool get isFirstStep => currentStep.value == 0;
  bool get isLastStep  => currentStep.value == totalSteps - 1;
  bool get isReviewStep => currentStep.value == totalSteps - 1;

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
  final selectedProjectType = 'house'.obs;

  static const List<Map<String, String>> projectTypes = [
    {'key': 'house',          'label': 'New House',       'icon': '🏠'},
    {'key': 'villa',          'label': 'Villa',           'icon': '🏛️'},
    {'key': 'apartment',      'label': 'Apartment',       'icon': '🏢'},
    {'key': 'commercial',     'label': 'Commercial',      'icon': '🏗️'},
    {'key': 'shop',           'label': 'Shop',            'icon': '🏪'},
    {'key': 'office',         'label': 'Office',          'icon': '🖥️'},
    {'key': 'renovation',     'label': 'Renovation',      'icon': '🔧'},
    {'key': 'grey_structure', 'label': 'Grey Structure',  'icon': '🏗️'},
    {'key': 'interior',       'label': 'Interior',        'icon': '🛋️'},
    {'key': 'boundary_wall',  'label': 'Boundary Wall',   'icon': '🧱'},
    {'key': 'kitchen',        'label': 'Kitchen',         'icon': '🍳'},
    {'key': 'bathroom',       'label': 'Bathroom',        'icon': '🚿'},
    {'key': 'extension',      'label': 'Extension',       'icon': '➕'},
    {'key': 'landscaping',    'label': 'Landscaping',     'icon': '🌿'},
    {'key': 'custom',         'label': 'Custom',          'icon': '⚙️'},
  ];

  void selectProjectType(String type) => selectedProjectType.value = type;

  // ── Step 1: Quick Details ─────────────────────────────────────────────────
  final projectNameCtrl = TextEditingController();
  final floors          = 1.obs;
  final qualityTier     = 'standard'.obs;

  static const List<String> qualityTiers = ['economy', 'standard', 'premium', 'luxury'];

  String get projectName => projectNameCtrl.text.trim();
  bool get step1Valid    => projectName.isNotEmpty;

  // ── Step 2: Location ──────────────────────────────────────────────────────
  final selectedCountryId = GeographyService.defaultCountryId.obs;
  final selectedCityId    = GeographyService.defaultCityId.obs;
  final selectedAreaId    = Rxn<int>();

  List<CountryData> get countries {
    try { return Get.find<GeographyService>().countries; }
    catch (_) { return []; }
  }

  List<CityData> get cities {
    try { return Get.find<GeographyService>().citiesForCountry(selectedCountryId.value); }
    catch (_) { return []; }
  }

  List<AreaData> get areas {
    try { return Get.find<GeographyService>().areasForCity(selectedCityId.value); }
    catch (_) { return []; }
  }

  void selectCountry(int id) {
    selectedCountryId.value = id;
    selectedCityId.value    = cities.isNotEmpty ? cities.first.id : 0;
    selectedAreaId.value    = null;
  }

  void selectCity(int id) {
    selectedCityId.value = id;
    selectedAreaId.value = null;
  }

  String get selectedCityName {
    try { return cities.firstWhere((c) => c.id == selectedCityId.value).name; }
    catch (_) { return ''; }
  }

  String get selectedAreaName {
    if (selectedAreaId.value == null) return '';
    try { return areas.firstWhere((a) => a.id == selectedAreaId.value).name; }
    catch (_) { return ''; }
  }

  String get selectedCountryCurrency {
    try { return countries.firstWhere((c) => c.id == selectedCountryId.value).currencyCode; }
    catch (_) { return 'PKR'; }
  }

  // ── Step 3: Plot & Area ───────────────────────────────────────────────────
  final plotSizeCtrl          = TextEditingController();
  final plotUnit              = 'marla'.obs;
  final constructionAreaCtrl  = TextEditingController();
  final constructionAreaUnit  = 'marla'.obs;
  final plotWidthCtrl         = TextEditingController();
  final plotDepthCtrl         = TextEditingController();

  // Reactive hint — always has a value so Obx always subscribes
  final plotHintText = ''.obs;

  double? get plotSizeSqm {
    final val = double.tryParse(plotSizeCtrl.text.trim());
    if (val == null) return null;
    return UnitConverter.toSqMeters(val, plotUnit.value);
  }

  double? get constructionAreaSqm {
    final val = double.tryParse(constructionAreaCtrl.text.trim());
    if (val == null) return null;
    return UnitConverter.toSqMeters(val, constructionAreaUnit.value);
  }

  void _updatePlotHint() {
    final val = double.tryParse(plotSizeCtrl.text.trim());
    if (val == null || val <= 0) {
      plotHintText.value = '';
      return;
    }
    final unit = plotUnit.value;
    plotHintText.value = UnitConverter.hint(
      val, unit,
      unit == 'marla' ? ['sqft', 'sqm'] : ['marla', 'sqft'],
    );
  }

  /// Auto-fill construction area as 90% of plot size when plot is entered
  void onPlotSizeChanged(String value) {
    _updatePlotHint();
    if (constructionAreaCtrl.text.trim().isEmpty) {
      final plotVal = double.tryParse(value);
      if (plotVal != null) {
        final suggested = plotVal * 0.9;
        constructionAreaCtrl.text = suggested.toStringAsFixed(2);
      }
    }
    _runEstimation();
  }

  // ── Step 4: Budget ────────────────────────────────────────────────────────
  final budgetCtrl           = TextEditingController();
  final estimatedCost        = 0.0.obs;
  final budgetValidation     = Rxn<BudgetValidationResult>();
  final isEstimating         = false.obs;

  String get currencyCode => selectedCountryCurrency;

  void onBudgetChanged(String _) => _validateBudget();

  void _validateBudget() {
    final budget = double.tryParse(
        budgetCtrl.text.trim().replaceAll(',', '')) ?? 0;
    if (estimatedCost.value > 0 && budget > 0) {
      budgetValidation.value = BudgetEngine.validate(
        userBudget: budget,
        estimatedCost: estimatedCost.value,
        qualityTier: qualityTier.value,
      );
    } else {
      budgetValidation.value = null;
    }
  }

  Future<void> _runEstimation() async {
    final areaSqm = constructionAreaSqm;
    if (areaSqm == null || areaSqm <= 0) return;

    isEstimating.value = true;
    await Future.delayed(const Duration(milliseconds: 300));

    final estimate = BudgetEngine.estimateHouse(
      constructionAreaSqm: areaSqm,
      floors: floors.value,
      qualityTier: qualityTier.value,
      currencyCode: currencyCode,
    );
    estimatedCost.value = estimate.total;
    _validateBudget();
    isEstimating.value = false;
  }

  // ── Step 5: Timeline ──────────────────────────────────────────────────────
  final startDate        = DateTime.now().obs;
  final generatedStages  = <StageModel>[].obs;
  final isGenerating     = false.obs;

  DateTime get projectedEndDate {
    if (generatedStages.isEmpty) return startDate.value.add(const Duration(days: 365));
    return generatedStages.last.plannedEnd ?? startDate.value.add(const Duration(days: 365));
  }

  Future<void> generateTimeline() async {
    isGenerating.value = true;
    await Future.delayed(const Duration(milliseconds: 500));

    final scope = _buildScopeForPreview();
    try {
      final stages = TimelineEngine.generateForScope(
        scope: scope,
        projectStart: startDate.value,
      );
      generatedStages.value = stages;
    } catch (_) {
      generatedStages.value = [];
    }
    isGenerating.value = false;
  }

  ProjectScopeModel _buildScopeForPreview() => ProjectScopeModel(
        id: 'preview',
        projectId: 'preview',
        name: projectName.isNotEmpty ? projectName : 'My Project',
        projectType: selectedProjectType.value,
        qualityTier: qualityTier.value,
        constructionAreaSqm: constructionAreaSqm ?? 126.0,
        floors: floors.value,
        budgetAmount: double.tryParse(budgetCtrl.text.trim().replaceAll(',', '')) ?? 0,
        currencyCode: currencyCode,
        startDate: startDate.value,
      );

  // ── Step 6: Team ──────────────────────────────────────────────────────────
  final contractorType        = 'self'.obs;
  final supervisorPhoneCtrl   = TextEditingController();

  static const List<Map<String, String>> contractorTypes = [
    {'key': 'self',    'label': 'Self-Managed',       'desc': 'I will manage everything myself'},
    {'key': 'local',   'label': 'Local Contractor',   'desc': 'Hire a local mistry or contractor'},
    {'key': 'company', 'label': 'Construction Co.',   'desc': 'Hire a registered construction company'},
  ];

  // ── Create Project ────────────────────────────────────────────────────────
  final isCreating = false.obs;

  Future<void> createProject() async {
    isCreating.value = true;

    final budget = double.tryParse(
        budgetCtrl.text.trim().replaceAll(',', '')) ?? 0;

    final scopeId   = _uuid.v4();
    final projectId = _uuid.v4();

    final stages = generatedStages.map((s) => s.copyWith(
      // Assign real IDs — server would do this in production
    )).toList();

    final scope = ProjectScopeModel(
      id: scopeId,
      projectId: projectId,
      name: _scopeNameForType(selectedProjectType.value),
      projectType: selectedProjectType.value,
      qualityTier: qualityTier.value,
      plotSizeSqm: plotSizeSqm,
      constructionAreaSqm: constructionAreaSqm,
      plotWidthM: double.tryParse(plotWidthCtrl.text.trim()),
      plotDepthM: double.tryParse(plotDepthCtrl.text.trim()),
      floors: floors.value,
      budgetAmount: budget,
      estimatedCost: estimatedCost.value,
      currencyCode: currencyCode,
      startDate: startDate.value,
      targetEndDate: projectedEndDate,
      stages: stages,
    );

    final cityGeo = cities.where((c) => c.id == selectedCityId.value);
    final areaGeo = areas.where((a) => a.id == (selectedAreaId.value ?? 0));

    final project = ProjectModel(
      id: projectId,
      ownerId: 'current_user',
      name: projectName.isNotEmpty
          ? projectName
          : '${selectedCityName.isNotEmpty ? selectedCityName : 'My'} Project',
      status: 'active',
      priority: 'medium',
      countryId: selectedCountryId.value,
      cityId: selectedCityId.value,
      areaId: selectedAreaId.value,
      cityName: cityGeo.isNotEmpty ? cityGeo.first.name : null,
      areaName: areaGeo.isNotEmpty ? areaGeo.first.name : null,
      budgetAmount: budget,
      estimatedCost: estimatedCost.value,
      actualCost: 0,
      currencyCode: currencyCode,
      startDate: startDate.value,
      targetEndDate: projectedEndDate,
      contractorType: contractorType.value,
      scopes: [scope],
      completionPct: 0,
      healthScore: 100,
      lastUpdated: DateTime.now(),
    );

    // TODO: Call API to persist. For now, add to mock list via ProjectsController.
    await Future.delayed(const Duration(seconds: 1));

    isCreating.value = false;

    Get.offAllNamed(
      AppRoutes.projectStageTracker,
      arguments: project,
    );
  }

  // ── Validation per step ───────────────────────────────────────────────────

  bool isStepValid(int step) => switch (step) {
        0 => selectedProjectType.value.isNotEmpty,
        1 => projectName.isNotEmpty,
        2 => selectedCityId.value > 0,
        3 => plotSizeSqm != null,
        4 => true, // budget is optional — user can override
        5 => true,
        6 => true,
        7 => true,
        _ => false,
      };

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String _scopeNameForType(String type) => switch (type) {
        'house'          => 'Main House',
        'villa'          => 'Villa',
        'apartment'      => 'Apartment',
        'commercial'     => 'Commercial Building',
        'shop'           => 'Shop',
        'office'         => 'Office',
        'renovation'     => 'Renovation',
        'grey_structure' => 'Grey Structure',
        'interior'       => 'Interior Work',
        'boundary_wall'  => 'Boundary Wall',
        'kitchen'        => 'Kitchen Renovation',
        'bathroom'       => 'Bathroom Renovation',
        'extension'      => 'Extension',
        'landscaping'    => 'Landscaping',
        _                => 'Main Scope',
      };

  String get qualityLabel => qualityTier.value[0].toUpperCase() +
      qualityTier.value.substring(1);

  String get projectTypeLabel {
    try {
      return projectTypes
          .firstWhere((t) => t['key'] == selectedProjectType.value)['label']!;
    } catch (_) {
      return selectedProjectType.value;
    }
  }

  String get formattedEstimatedCost =>
      CurrencyFormatter.formatCompact(estimatedCost.value, currency: currencyCode);

  String get formattedBudget {
    final val = double.tryParse(budgetCtrl.text.trim().replaceAll(',', '')) ?? 0;
    return CurrencyFormatter.formatCompact(val, currency: currencyCode);
  }

  @override
  void onClose() {
    projectNameCtrl.dispose();
    plotSizeCtrl.dispose();
    constructionAreaCtrl.dispose();
    plotWidthCtrl.dispose();
    plotDepthCtrl.dispose();
    budgetCtrl.dispose();
    supervisorPhoneCtrl.dispose();
    super.onClose();
  }
}
