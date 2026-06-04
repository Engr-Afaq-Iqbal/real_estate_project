import 'package:get/get.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/storage/local_storage.dart';

class ShellController extends GetxController {
  final currentIndex         = 0.obs;
  final userRole             = ''.obs;
  final unreadNotifications  = 3.obs;  // drives badge on Alerts tab

  @override
  void onInit() {
    super.onInit();
    userRole.value = LocalStorage.getString(StorageKeys.userRole) ?? 'homeowner';
  }

  void changeTab(int index) => currentIndex.value = index;

  bool get isHomeowner => userRole.value == 'homeowner';
  bool get isDeveloper  => userRole.value == 'developer';
}
