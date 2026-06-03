import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/storage/local_storage.dart';

class SettingsController extends GetxController {
  final themeMode = 'light'.obs;
  final appLanguage = 'en'.obs;
  final defaultCurrency = 'PKR'.obs;
  final measurementUnit = 'Marla'.obs;
  final notificationsEnabled = true.obs;
  final selectedThemeColor = 0.obs;

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

  @override
  void onInit() {
    super.onInit();
    themeMode.value = LocalStorage.getString(StorageKeys.themeMode) ?? 'light';
    appLanguage.value = LocalStorage.getString(StorageKeys.appLanguage) ?? 'en';
    measurementUnit.value = LocalStorage.getString(StorageKeys.measurementUnit) ?? 'Marla';
  }

  void setThemeMode(String mode) {
    themeMode.value = mode;
    LocalStorage.setString(StorageKeys.themeMode, mode);
    switch (mode) {
      case 'light':
        Get.changeThemeMode(ThemeMode.light);
      case 'dark':
        Get.changeThemeMode(ThemeMode.dark);
      default:
        Get.changeThemeMode(ThemeMode.system);
    }
  }

  void setLanguage(String lang) {
    appLanguage.value = lang;
    LocalStorage.setString(StorageKeys.appLanguage, lang);
    if (lang == 'ur') {
      Get.updateLocale(const Locale('ur', 'PK'));
    } else {
      Get.updateLocale(const Locale('en', 'US'));
    }
  }

  void setMeasurementUnit(String unit) {
    measurementUnit.value = unit;
    LocalStorage.setString(StorageKeys.measurementUnit, unit);
  }
}
