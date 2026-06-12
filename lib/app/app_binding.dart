import 'package:get/get.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/analytics_service.dart';
import '../core/services/geography_service.dart';
import '../core/services/price_master_service.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/market/controllers/market_controller.dart';
import '../features/tasks/controllers/tasks_controller.dart';

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
  }
}
