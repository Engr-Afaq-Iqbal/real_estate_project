import 'package:get/get.dart';
import '../controllers/shell_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../projects/controllers/projects_controller.dart';
import '../../calculator/controllers/calculator_controller.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../settings/controllers/settings_controller.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    // Use Get.put (not lazyPut) for every controller a tab screen needs.
    // IndexedStack builds ALL children immediately on first render, so every
    // GetView.controller getter fires before the first frame is painted.
    // lazyPut registers a factory but Get 4.7.x can resolve it before
    // ShellBinding finishes; Get.put instantiates synchronously, guaranteeing
    // the instance exists before any child widget calls Get.find<T>().
    Get.put<ShellController>(ShellController());
    Get.put<DashboardController>(DashboardController());
    Get.put<ProjectsController>(ProjectsController());
    Get.put<CalculatorController>(CalculatorController());
    Get.put<ChatController>(ChatController());
    Get.put<SettingsController>(SettingsController());
  }
}
