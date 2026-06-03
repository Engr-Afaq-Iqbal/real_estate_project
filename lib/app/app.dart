import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../l10n/translations/app_translations.dart';
import '../presentation/routes/app_pages.dart';
import '../presentation/routes/app_routes.dart';
import '../presentation/theme/app_theme.dart';
import '../core/constants/storage_keys.dart';
import '../core/storage/local_storage.dart';
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
        return GetMaterialApp(
          title: 'BuildOS',
          debugShowCheckedModeBanner: false,

          // ── Theme ──────────────────────────────────────────────────────
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: _resolveThemeMode(),

          // ── Localization ───────────────────────────────────────────────
          translations: AppTranslations(),
          locale: _resolveLocale(),
          fallbackLocale: const Locale('en', 'US'),

          // ── Navigation ─────────────────────────────────────────────────
          initialRoute: AppRoutes.splash,
          getPages: AppPages.pages,
          initialBinding: AppBinding(),

          // ── Default transitions ────────────────────────────────────────
          defaultTransition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 280),
        );
      },
    );
  }

  ThemeMode _resolveThemeMode() {
    final saved = LocalStorage.getString(StorageKeys.themeMode);
    switch (saved) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Locale _resolveLocale() {
    final lang = LocalStorage.getString(StorageKeys.appLanguage);
    if (lang == 'ur') return const Locale('ur', 'PK');
    return const Locale('en', 'US');
  }
}
