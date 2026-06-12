import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/storage/local_storage.dart';

class SettingsController extends GetxController {
  // ── Appearance ────────────────────────────────────────────────────────────
  final themeMode          = 'light'.obs;
  final selectedThemeColor = 0.obs;
  final appLanguage        = 'en'.obs;

  // ── Project ───────────────────────────────────────────────────────────────
  final defaultCurrency    = 'PKR'.obs;
  final measurementUnit    = 'Marla'.obs;

  // ── Notifications (POLISH 4 — persisted to LocalStorage) ─────────────────
  final notificationsEnabled   = true.obs;
  final emailNotifications     = false.obs;
  final projectUpdateAlerts    = true.obs;
  final smsAlerts              = false.obs;

  // ── Security ──────────────────────────────────────────────────────────────
  final biometricEnabled       = false.obs;
  final twoFactorEnabled       = false.obs;

  // ── Danger zone ───────────────────────────────────────────────────────────
  final deleteConfirmText      = ''.obs;
  final isDeleting             = false.obs;

  // ── Color palette ─────────────────────────────────────────────────────────
  final List<Color> themeColors = const [
    Color(0xFF1E3A8A), // Royal Blue (default)
    Color(0xFF1D4ED8), // Blue
    Color(0xFF16A34A), // Green
    Color(0xFF15803D), // Dark Green
    Color(0xFF7C3AED), // Purple
    Color(0xFFBE185D), // Pink
    Color(0xFF374151), // Dark Gray
    Color(0xFFEA580C), // Orange
  ];

  static const _colorNames = [
    'Royal Blue', 'Blue', 'Green', 'Dark Green',
    'Purple', 'Pink', 'Dark Gray', 'Orange',
  ];

  // ── Computed ──────────────────────────────────────────────────────────────

  String get selectedColorName =>
      _colorNames[selectedThemeColor.value.clamp(0, _colorNames.length - 1)];

  bool get canConfirmDelete =>
      deleteConfirmText.value.trim() == 'DELETE';

  Color get currentPrimary =>
      themeColors[selectedThemeColor.value.clamp(0, themeColors.length - 1)];

  // currentThemeMode used by GetMaterialApp's themeMode parameter
  ThemeMode get currentThemeMode => switch (themeMode.value) {
        'dark'   => ThemeMode.dark,
        'system' => ThemeMode.system,
        _        => ThemeMode.light,
      };

  // ── Init ──────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    themeMode.value =
        LocalStorage.getString(StorageKeys.themeMode) ?? 'light';
    appLanguage.value =
        LocalStorage.getString(StorageKeys.appLanguage) ?? 'en';
    measurementUnit.value =
        LocalStorage.getString(StorageKeys.measurementUnit) ?? 'Marla';
    selectedThemeColor.value =
        LocalStorage.getInt(StorageKeys.themeColor) ?? 0;
    // POLISH 4: restore notification toggle states
    notificationsEnabled.value =
        LocalStorage.getBool('notif_enabled') ?? true;
    emailNotifications.value  =
        LocalStorage.getBool('notif_email') ?? false;
    projectUpdateAlerts.value =
        LocalStorage.getBool('notif_project') ?? true;
    smsAlerts.value           =
        LocalStorage.getBool('notif_sms') ?? false;
  }

  // ── POLISH 4: Notification helpers ────────────────────────────────────────

  void setNotificationsEnabled(bool v) {
    notificationsEnabled.value = v;
    LocalStorage.setBool('notif_enabled', v);
  }

  void setEmailNotifications(bool v) {
    emailNotifications.value = v;
    LocalStorage.setBool('notif_email', v);
  }

  void setProjectUpdateAlerts(bool v) {
    projectUpdateAlerts.value = v;
    LocalStorage.setBool('notif_project', v);
  }

  void setSmsAlerts(bool v) {
    smsAlerts.value = v;
    LocalStorage.setBool('notif_sms', v);
  }

  // ── Theme mode ────────────────────────────────────────────────────────────

  void setThemeMode(String mode) {
    themeMode.value = mode;
    LocalStorage.setString(StorageKeys.themeMode, mode);
    // Trigger GetBuilder<SettingsController>(id:'app_theme') in app.dart
    // to rebuild GetMaterialApp with the new themeMode.
    update(['app_theme']);
  }

  // ── Primary color ─────────────────────────────────────────────────────────

  void setThemeColor(int index) {
    selectedThemeColor.value = index;
    LocalStorage.setInt(StorageKeys.themeColor, index);
    // Trigger GetBuilder<SettingsController>(id:'app_theme') in app.dart
    // to rebuild GetMaterialApp with new theme + darkTheme.
    // This is the ONLY way to update darkTheme reactively in GetX 4.x —
    // Get.changeTheme() only updates the light theme variable internally.
    update(['app_theme']);
  }

  // ── Language ──────────────────────────────────────────────────────────────

  void setLanguage(String lang) {
    appLanguage.value = lang;
    LocalStorage.setString(StorageKeys.appLanguage, lang);
    Get.updateLocale(lang == 'ur'
        ? const Locale('ur', 'PK')
        : const Locale('en', 'US'));
  }

  // ── Measurement unit ──────────────────────────────────────────────────────

  void setMeasurementUnit(String unit) {
    measurementUnit.value = unit;
    LocalStorage.setString(StorageKeys.measurementUnit, unit);
  }

  // ── Delete account ────────────────────────────────────────────────────────

  Future<void> deleteAccount() async {
    if (!canConfirmDelete) return;
    isDeleting.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isDeleting.value = false;
    Get.back();
    Get.offAllNamed('/');
  }
}
