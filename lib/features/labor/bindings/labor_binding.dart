import 'package:get/get.dart';
import '../controllers/labor_controller.dart';

class LaborBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LaborController>(() => LaborController());
  }
}
