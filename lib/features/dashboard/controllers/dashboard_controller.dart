import 'package:get/get.dart';
import '../../projects/data/models/project_model.dart';
import '../../market/controllers/market_controller.dart';

// ── Market price model ────────────────────────────────────────────────────────

class MarketPrice {
  final String material;
  final String materialUr;
  final double price;
  final String unit;
  final double changeToday;   // + or - from yesterday
  final String currency;

  const MarketPrice({
    required this.material,
    required this.materialUr,
    required this.price,
    required this.unit,
    required this.changeToday,
    this.currency = 'PKR',
  });

  double get changePct => price > 0 ? (changeToday / price) * 100 : 0;
  bool get isUp   => changeToday > 0;
  bool get isDown => changeToday < 0;
}

// ── Upcoming task model ───────────────────────────────────────────────────────

class UpcomingTask {
  final String title;
  final String projectName;
  final String stageName;
  final DateTime dueDate;
  final bool isOverdue;
  final String priority;       // high, medium, low

  const UpcomingTask({
    required this.title,
    required this.projectName,
    required this.stageName,
    required this.dueDate,
    this.isOverdue = false,
    this.priority = 'medium',
  });
}

// ── Budget alert model ────────────────────────────────────────────────────────

class BudgetAlert {
  final String projectName;
  final double budgetPct;      // 0–1
  final String message;
  final String severity;       // warning, danger, info

  const BudgetAlert({
    required this.projectName,
    required this.budgetPct,
    required this.message,
    required this.severity,
  });
}

// ── Controller ────────────────────────────────────────────────────────────────

class DashboardController extends GetxController {
  final isLoading              = false.obs;
  final hasLoadError           = false.obs;
  final projects               = <ProjectModel>[].obs;
  final unreadNotifications    = 3.obs;
  final marketPrices           = <MarketPrice>[].obs;
  final upcomingTasks          = <UpcomingTask>[].obs;
  final budgetAlerts           = <BudgetAlert>[].obs;

  // Market prices meta (Fix 11)
  final marketPricesLastUpdated = Rxn<DateTime>();
  final isRefreshingPrices      = false.obs;

  // Calculator widget state
  final calcExpanded           = false.obs;
  final calcAreaCtrl           = ''.obs;
  final calcQuality            = 'standard'.obs;
  final calcFloors             = 1.obs;
  final quickEstimate          = Rxn<double>();

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value    = true;
    hasLoadError.value = false;
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      projects.value              = ProjectModel.mockList();
      marketPrices.value          = _marketAwarePrices();
      marketPricesLastUpdated.value = DateTime.now();
      upcomingTasks.value         = _mockUpcomingTasks();
      budgetAlerts.value          = _mockBudgetAlerts();
    } catch (_) {
      hasLoadError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshMarketPrices() async {
    if (isRefreshingPrices.value) return;
    isRefreshingPrices.value = true;
    await Future.delayed(const Duration(milliseconds: 900));
    marketPrices.value = _marketAwarePrices();
    marketPricesLastUpdated.value = DateTime.now();
    isRefreshingPrices.value = false;
  }

  ProjectModel? get primaryProject =>
      projects.isNotEmpty ? projects.first : null;

  List<ProjectModel> get activeProjects =>
      projects.where((p) => p.status == 'active').toList();

  int get overdueTaskCount =>
      upcomingTasks.where((t) => t.isOverdue).length;

  void toggleCalcWidget() => calcExpanded.value = !calcExpanded.value;

  void runQuickEstimate(String area) {
    final val = double.tryParse(area.trim());
    if (val == null || val <= 0) { quickEstimate.value = null; return; }
    final floors = calcFloors.value;
    // Use market-aware rate if MarketController is registered
    double rate;
    if (Get.isRegistered<MarketController>()) {
      rate = Get.find<MarketController>().estimateRate(calcQuality.value);
    } else {
      // Fallback Pakistan rates (per Marla)
      const rateMap = {'economy': 43200.0, 'standard': 60700.0, 'premium': 93600.0, 'luxury': 156800.0};
      rate = rateMap[calcQuality.value] ?? 60700.0;
    }
    quickEstimate.value = val * floors * rate * 1.1; // +10% contingency
  }

  /// Called by MarketController when the market changes.
  void notifyMarketChange() {
    marketPrices.value = _marketAwarePrices();
    marketPricesLastUpdated.value = DateTime.now();
    // Re-run any cached estimate
    calcAreaCtrl.value = calcAreaCtrl.value; // trigger rebuild
    quickEstimate.value = null;
  }

  // ── Mock data ──────────────────────────────────────────────────────────────

  /// Returns market prices for the currently selected market.
  List<MarketPrice> _marketAwarePrices() {
    if (!Get.isRegistered<MarketController>()) return _pkMarketPrices();
    final m = Get.find<MarketController>().market;
    return m.materials
        .take(4)
        .map((mat) => MarketPrice(
              material: mat.name,
              materialUr: mat.name, // Urdu translation N/A for non-PK
              price: mat.price,
              unit: mat.unit,
              changeToday: mat.changeToday,
              currency: m.currency,
            ))
        .toList();
  }

  static List<MarketPrice> _pkMarketPrices() => [
        const MarketPrice(
          material: 'Steel', materialUr: 'سریا',
          price: 262, unit: '/kg', changeToday: 4,
        ),
        const MarketPrice(
          material: 'Cement', materialUr: 'سیمنٹ',
          price: 1280, unit: '/bag', changeToday: -20,
        ),
        const MarketPrice(
          material: 'Sand', materialUr: 'ریت',
          price: 55, unit: '/cft', changeToday: 0,
        ),
        const MarketPrice(
          material: 'Bricks', materialUr: 'اینٹ',
          price: 18500, unit: '/1000', changeToday: 500,
        ),
      ];

  static List<UpcomingTask> _mockUpcomingTasks() => [
        UpcomingTask(
          title: 'Approve payroll for this week',
          projectName: 'DHA House — 10 Marla',
          stageName: 'Gray Structure',
          dueDate: DateTime.now().add(const Duration(days: 1)),
          priority: 'high',
        ),
        UpcomingTask(
          title: 'Upload foundation completion photos',
          projectName: 'Bahria Heights — Block C',
          stageName: 'Foundation',
          dueDate: DateTime.now().subtract(const Duration(days: 2)),
          isOverdue: true,
          priority: 'medium',
        ),
        UpcomingTask(
          title: 'Mark plaster stage complete',
          projectName: 'Khan Villa Renovation',
          stageName: 'Plastering',
          dueDate: DateTime.now().add(const Duration(days: 3)),
          priority: 'medium',
        ),
      ];

  static List<BudgetAlert> _mockBudgetAlerts() => [
        const BudgetAlert(
          projectName: 'DHA House — 10 Marla',
          budgetPct: 0.68,
          message: '68% of budget used at 38% completion.',
          severity: 'warning',
        ),
        const BudgetAlert(
          projectName: 'Bahria Heights — Block C',
          budgetPct: 0.72,
          message: 'On track — spending aligns with progress.',
          severity: 'info',
        ),
      ];
}
