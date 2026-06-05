import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../l10n/translations/app_translations.dart';
import '../presentation/routes/app_pages.dart';
import '../presentation/routes/app_routes.dart';
import '../presentation/theme/app_theme.dart';
import '../core/constants/storage_keys.dart';
import '../core/storage/local_storage.dart';
import '../features/settings/controllers/settings_controller.dart';
import 'app_binding.dart';

class BuildOSApp extends StatelessWidget {
  const BuildOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        // GetBuilder listens to update(['app_theme']) calls in SettingsController.
        // This rebuilds GetMaterialApp with the new primary color applied to BOTH
        // theme and darkTheme — the only reliable way in GetX 4.x to make
        // darkTheme reactive (Get.changeTheme() only updates the light theme).
        return GetBuilder<SettingsController>(
          id: 'app_theme',
          init: Get.find<SettingsController>(), // already registered in main.dart
          builder: (settings) => GetMaterialApp(
            title: 'BuildOS',
            debugShowCheckedModeBanner: false,

            // ── Theme — both driven by SettingsController ─────────────────
            theme:     AppTheme.lightWith(settings.currentPrimary),
            darkTheme: AppTheme.darkWith(settings.currentPrimary),
            themeMode: settings.currentThemeMode,

            // ── Localization ──────────────────────────────────────────────
            translations: AppTranslations(),
            locale: _resolveLocale(),
            fallbackLocale: const Locale('en', 'US'),

            // ── Navigation ────────────────────────────────────────────────
            initialRoute: AppRoutes.splash,
            getPages: AppPages.pages,
            initialBinding: AppBinding(),

            // ── Default transitions ───────────────────────────────────────
            defaultTransition: Transition.rightToLeft,
            transitionDuration: const Duration(milliseconds: 280),
          ),
        );
      },
    );
  }

  Locale _resolveLocale() {
    final lang = LocalStorage.getString(StorageKeys.appLanguage);
    if (lang == 'ur') return const Locale('ur', 'PK');
    return const Locale('en', 'US');
  }
}
