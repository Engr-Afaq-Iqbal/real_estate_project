import 'package:get/get.dart';
import '../controllers/shell_controller.dart';

// Tab 0: Dashboard
import '../../dashboard/controllers/dashboard_controller.dart';

// Tab 1: Projects
import '../../projects/controllers/projects_controller.dart';

// Tab 2: Settings (+ profile controller used inside settings)
import '../../profile/controllers/profile_controller.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    // Get.put for every controller whose screen lives inside IndexedStack —
    // IndexedStack builds ALL children on first render so every
    // GetView.controller getter fires before the first frame.
    Get.put<ShellController>(ShellController());
    Get.put<DashboardController>(DashboardController());
    Get.put<ProjectsController>(ProjectsController());
    // SettingsController is already permanent (registered in main.dart before runApp).
    // Calling Get.put again here would create a duplicate — skip it.
    Get.put<ProfileController>(ProfileController());
  }
}
