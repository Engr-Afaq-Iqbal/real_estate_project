import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/storage/local_storage.dart';
import '../../../presentation/routes/app_routes.dart';

class OnboardingController extends GetxController {
  Future<void> selectRole(String role) async {
    await LocalStorage.setString(StorageKeys.userRole, role);
    Get.toNamed(AppRoutes.login);
  }

  Future<void> checkAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    final isLoggedIn = LocalStorage.getBool(StorageKeys.isLoggedIn) ?? false;
    if (isLoggedIn) {
      Get.offAllNamed(AppRoutes.main);
    } else {
      Get.offNamed(AppRoutes.roleSelection);
    }
  }

  bool get isHomeownerRole =>
      LocalStorage.getString(StorageKeys.userRole) ==
      AppConstants.roleHomeowner;
}
