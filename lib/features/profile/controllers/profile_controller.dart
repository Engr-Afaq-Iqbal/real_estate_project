import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final isEditing = false.obs;
  final isSaving = false.obs;

  AuthController get _auth => Get.find<AuthController>();

  String get name => _auth.currentUser.value?.name ?? '';
  String get email => _auth.currentUser.value?.email ?? '';
  String get phone => _auth.currentUser.value?.phone ?? '';
  String get city => _auth.currentUser.value?.city ?? '';
  String get initials => _auth.currentUser.value?.initials ?? '?';
  bool get isPhoneVerified => _auth.currentUser.value?.isPhoneVerified ?? false;
  bool get isEmailVerified => _auth.currentUser.value?.isEmailVerified ?? false;
  bool get isCnicVerified => _auth.currentUser.value?.isCnicVerified ?? false;
  int get projectCount => _auth.currentUser.value?.projectCount ?? 0;
  int get updatesCount => _auth.currentUser.value?.updatesCount ?? 0;
  double get rating => _auth.currentUser.value?.rating ?? 0.0;
  bool get isHomeowner => _auth.currentUser.value?.isHomeowner ?? true;

  Future<bool> saveProfile({
    required String newName,
    required String newEmail,
    required String newPhone,
    required String newCity,
  }) async {
    if (newName.trim().isEmpty) return false;

    isSaving.value = true;
    await Future.delayed(const Duration(seconds: 1));

    final current = _auth.currentUser.value;
    if (current != null) {
      _auth.currentUser.value = current.copyWith(
        name:  newName.trim(),
        email: newEmail.trim().isEmpty ? null : newEmail.trim(),
        phone: newPhone.trim().isEmpty ? current.phone : newPhone.trim(),
        city:  newCity.trim().isEmpty  ? current.city  : newCity.trim(),
      );
    }

    isSaving.value = false;
    isEditing.value = false;
    return true;
  }

  @Deprecated('Use saveProfile()')
  Future<void> saveProfileLegacy() async {
    isSaving.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isSaving.value = false;
    isEditing.value = false;
  }
}
