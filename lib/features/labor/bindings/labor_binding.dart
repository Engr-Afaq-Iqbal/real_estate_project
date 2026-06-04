import 'package:get/get.dart';
import '../controllers/labor_list_controller.dart';
import '../controllers/attendance_controller.dart';
import '../controllers/payroll_controller.dart';

class LaborBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LaborListController>(() => LaborListController());
    Get.lazyPut<AttendanceController>(() => AttendanceController());
    Get.lazyPut<PayrollController>(() => PayrollController());
  }
}
