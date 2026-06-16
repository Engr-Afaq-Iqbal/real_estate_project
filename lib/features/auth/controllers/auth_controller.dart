import 'package:get/get.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/utils/logger.dart';
import '../../../presentation/routes/app_routes.dart';
import '../data/models/user_model.dart';

class AuthController extends GetxController {
  final currentUser = Rxn<UserModel>();
  final isLoading = false.obs;
  final isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final loggedIn = LocalStorage.getBool(StorageKeys.isLoggedIn) ?? false;
    isLoggedIn.value = loggedIn;
  }

  Future<void> loginWithPhone({
    required String phone,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      // Mock implementation — replace with ApiClient call
      await Future.delayed(const Duration(seconds: 2));

      final role = LocalStorage.getString(StorageKeys.userRole) ?? 'homeowner';
      final mockUser = UserModel(
        id: 'user_001',
        name: role == 'homeowner'
            ? 'Ahmed Khan'
            : role == 'contractor'
                ? 'Malik Contractors'
                : 'Malik Builders',
        phone: phone,
        email: 'ahmed.khan@gmail.com',
        role: role,
        city: 'Lahore',
        isPhoneVerified: true,
        projectCount: 1,
        updatesCount: 12,
        rating: 4.8,
        createdAt: DateTime(2025, 1, 1),
      );

      await _persistSession(mockUser, 'mock_access_token');
      currentUser.value = mockUser;
      isLoggedIn.value = true;
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      AppLogger.error('Login failed', e);
      Get.snackbar('Error', 'Login failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithOtp(String phone) async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1));
      // TODO: call OTP API
      Get.snackbar('OTP Sent', 'A verification code has been sent to $phone');
    } catch (e) {
      AppLogger.error('OTP login failed', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await SecureStorage.deleteAll();
    await LocalStorage.remove(StorageKeys.isLoggedIn);
    await LocalStorage.remove(StorageKeys.userId);
    currentUser.value = null;
    isLoggedIn.value = false;
    Get.offAllNamed(AppRoutes.splash);
  }

  Future<void> _persistSession(UserModel user, String token) async {
    await SecureStorage.write(StorageKeys.accessToken, token);
    await LocalStorage.setBool(StorageKeys.isLoggedIn, true);
    await LocalStorage.setString(StorageKeys.userId, user.id);
    await LocalStorage.setString(StorageKeys.userRole, user.role);
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'good_morning'.tr;
    if (hour < 17) return 'good_afternoon'.tr;
    return 'good_evening'.tr;
  }

  String get userFirstName {
    final name = currentUser.value?.name ?? '';
    return name.split(' ').first;
  }
}
