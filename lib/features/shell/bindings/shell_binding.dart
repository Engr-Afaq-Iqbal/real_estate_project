import 'package:get/get.dart';
import '../controllers/shell_controller.dart';

// Tab 0: Dashboard
import '../../dashboard/controllers/dashboard_controller.dart';

// Tab 1: Projects
import '../../projects/controllers/projects_controller.dart';

// Tab 2: Updates
import '../../updates/controllers/updates_controller.dart';

// Tab 3: Notifications
import '../../notifications/controllers/notifications_controller.dart';

// Tab 4: Profile
import '../../profile/controllers/profile_controller.dart';

// Still needed globally (open via routes from other tabs)
import '../../settings/controllers/settings_controller.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    // Use Get.put (not lazyPut) for every controller whose screen lives
    // inside the IndexedStack. IndexedStack builds ALL children on first
    // render, so every GetView.controller getter fires immediately.
    // Get.put instantiates synchronously, guaranteeing the instance exists
    // before any child widget calls Get.find<T>().
    Get.put<ShellController>(ShellController());
    Get.put<DashboardController>(DashboardController());
    Get.put<ProjectsController>(ProjectsController());
    Get.put<UpdatesController>(UpdatesController());
    Get.put<NotificationsController>(NotificationsController());
    Get.put<ProfileController>(ProfileController());
    Get.put<SettingsController>(SettingsController());
  }
}
