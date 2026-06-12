import 'package:get/get.dart';
import '../controllers/tasks_controller.dart';

/// Safety net for direct navigation — the controller is normally registered
/// permanently in AppBinding so badge counts stay live app-wide.
class TasksBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<TasksController>()) {
      Get.put<TasksController>(TasksController(), permanent: true);
    }
  }
}
