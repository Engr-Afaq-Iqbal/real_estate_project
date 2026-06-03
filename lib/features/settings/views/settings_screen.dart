import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_card.dart';
import '../../../presentation/routes/app_routes.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Obx(() {
          final user = auth.currentUser.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile summary
              AppCard(
                onTap: () => Get.toNamed(AppRoutes.profile),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          user?.initials ?? 'AK',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(user?.name ?? 'Ahmed Khan', style: AppTextStyles.h3(context)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.infoLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  (user?.role ?? 'homeowner').toUpperCase(),
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          Text(user?.email ?? 'ahmed.khan@gmail.com', style: AppTextStyles.caption(context)),
                          const SizedBox(height: 4),
                          const Text('Edit Profile ›', style: TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.xl),
              Text('appearance'.tr, style: AppTextStyles.overline(context)),
              const SizedBox(height: AppDimensions.sm),

              AppCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(width: 14, height: 14, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                        const SizedBox(width: AppDimensions.md),
                        Expanded(child: Text('theme_color'.tr, style: AppTextStyles.labelLarge(context))),
                        Text('Royal Blue', style: AppTextStyles.caption(context)),
                        const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondaryLight),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Row(
                      children: controller.themeColors.asMap().entries.map((e) {
                        return GestureDetector(
                          onTap: () => controller.selectedThemeColor.value = e.key,
                          child: Obx(() => Container(
                            width: 28,
                            height: 28,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: e.value,
                              shape: BoxShape.circle,
                              border: controller.selectedThemeColor.value == e.key
                                  ? Border.all(color: isDark ? Colors.white : Colors.black, width: 2)
                                  : null,
                            ),
                          )),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Row(
                      children: [
                        Expanded(child: Text('app_theme'.tr, style: AppTextStyles.labelLarge(context))),
                        _ThemePill(label: 'light'.tr, value: 'light', groupValue: controller.themeMode.value, onTap: () => controller.setThemeMode('light')),
                        const SizedBox(width: 4),
                        _ThemePill(label: 'dark'.tr, value: 'dark', groupValue: controller.themeMode.value, onTap: () => controller.setThemeMode('dark')),
                        const SizedBox(width: 4),
                        _ThemePill(label: 'system'.tr, value: 'system', groupValue: controller.themeMode.value, onTap: () => controller.setThemeMode('system')),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.xl),
              Text('language'.tr, style: AppTextStyles.overline(context)),
              const SizedBox(height: AppDimensions.sm),
              AppCard(
                onTap: () {},
                child: Row(
                  children: [
                    Expanded(child: Text('app_language'.tr, style: AppTextStyles.labelLarge(context))),
                    Text(controller.appLanguage.value == 'ur' ? 'اردو' : 'English', style: AppTextStyles.caption(context)),
                    const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondaryLight),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.xl),
              Text('project_settings'.tr, style: AppTextStyles.overline(context)),
              const SizedBox(height: AppDimensions.sm),
              AppCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text('default_currency'.tr, style: AppTextStyles.labelLarge(context))),
                        Text('PKR', style: AppTextStyles.caption(context)),
                        const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondaryLight),
                      ],
                    ),
                    Divider(height: AppDimensions.xl, color: AppColors.dividerLight),
                    Row(
                      children: [
                        Expanded(child: Text('measurement_units'.tr, style: AppTextStyles.labelLarge(context))),
                        _ThemePill(label: 'marla'.tr, value: 'Marla', groupValue: controller.measurementUnit.value, onTap: () => controller.setMeasurementUnit('Marla')),
                        const SizedBox(width: 4),
                        _ThemePill(label: 'sqft'.tr, value: 'Sq.ft', groupValue: controller.measurementUnit.value, onTap: () => controller.setMeasurementUnit('Sq.ft')),
                      ],
                    ),
                    Divider(height: AppDimensions.xl, color: AppColors.dividerLight),
                    Row(
                      children: [
                        Expanded(child: Text('notifications_setting'.tr, style: AppTextStyles.labelLarge(context))),
                        const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondaryLight),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.xl),
              Text('security'.tr, style: AppTextStyles.overline(context)),
              const SizedBox(height: AppDimensions.sm),
              AppCard(
                child: Column(
                  children: [
                    _SettingsRow(icon: Icons.lock_outline_rounded, label: 'Change Password'),
                    Divider(height: AppDimensions.xl, color: AppColors.dividerLight),
                    _SettingsRow(icon: Icons.fingerprint_rounded, label: 'Biometric Login'),
                    Divider(height: AppDimensions.xl, color: AppColors.dividerLight),
                    _SettingsRow(
                      icon: Icons.logout_rounded,
                      label: 'Sign Out',
                      isDestructive: true,
                      onTap: auth.logout,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.xxxl),
            ],
          );
        }),
      ),
    );
  }
}

class _ThemePill extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final VoidCallback onTap;

  const _ThemePill({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimaryLight;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: 18, color: color.withValues(alpha: 0.5)),
        ],
      ),
    );
  }
}
