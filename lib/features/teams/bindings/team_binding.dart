import 'package:get/get.dart';
import '../controllers/team_controller.dart';

class TeamBinding extends Bindings {
  @override
  void dependencies() {
    // TeamController is already registered as permanent in AppBinding for
    // the developer role. This lazyPut is a no-op if already registered and
    // acts as a fallback for direct route access during development.
    Get.lazyPut<TeamController>(() => TeamController(), fenix: true);
  }
}
