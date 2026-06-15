import 'package:get/get.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/analytics_service.dart';
import '../core/services/geography_service.dart';
import '../core/services/price_master_service.dart';
import '../core/constants/storage_keys.dart';
import '../core/storage/local_storage.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/market/controllers/market_controller.dart';
import '../features/tasks/controllers/tasks_controller.dart';
import '../features/teams/controllers/team_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // ── Global services (permanent) ───────────────────────────────────────
    Get.put<ConnectivityService>(ConnectivityService(), permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);
    Get.put<AnalyticsService>(AnalyticsService(), permanent: true);
    Get.put<GeographyService>(GeographyService(), permanent: true);
    Get.put<PriceMasterService>(PriceMasterService(), permanent: true);

    // ── Market selector (permanent — drives currency, area units, rates) ──
    Get.put<MarketController>(MarketController(), permanent: true);

    // ── Auth controller (permanent, drives navigation) ────────────────────
    Get.put<AuthController>(AuthController(), permanent: true);

    // ── Tasks hub (permanent — drives header badge & Today's Alert card) ──
    Get.put<TasksController>(TasksController(), permanent: true);

    // ── Team module (Contractor/developer role only) ───────────────────────
    // Customers must never have TeamController registered — enforced here at
    // the global binding level so no team data, routes, or state is reachable
    // from the customer role at any point in the app lifecycle.
    final role = LocalStorage.getString(StorageKeys.userRole) ?? 'homeowner';
    if (role == 'developer') {
      Get.put<TeamController>(TeamController(), permanent: true);
    }
  }
}
