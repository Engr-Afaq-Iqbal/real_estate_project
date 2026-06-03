import 'package:get/get.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/analytics_service.dart';
import '../features/auth/controllers/auth_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // ── Global services (permanent) ───────────────────────────────────────
    Get.put<ConnectivityService>(ConnectivityService(), permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);
    Get.put<AnalyticsService>(AnalyticsService(), permanent: true);

    // ── Auth controller (permanent, drives navigation) ────────────────────
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}
