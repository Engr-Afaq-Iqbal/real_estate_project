import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/routes/app_routes.dart';

class RoleSelectionScreen extends GetView<OnboardingController> {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePaddingH,
            vertical: AppDimensions.pagePaddingV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppDimensions.xxl),

              // Logo
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Build',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    TextSpan(
                      text: 'OS',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: AppDimensions.xs),
              Text(
                'app_tagline'.tr,
                style: AppTextStyles.bodySmall(context),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

              const SizedBox(height: AppDimensions.xxxl),

              // Illustration
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                ),
                child: const Icon(
                  Icons.home_work_outlined,
                  size: 80,
                  color: AppColors.primary,
                ),
              )
                  .animate()
                  .scale(delay: 200.ms, duration: 500.ms, curve: Curves.elasticOut),

              const SizedBox(height: AppDimensions.xl),

              Text(
                'get_started'.tr,
                style: AppTextStyles.h1(context),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

              const SizedBox(height: AppDimensions.sm),
              Text(
                'manage_construction'.tr,
                style: AppTextStyles.bodySmall(context),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

              const SizedBox(height: AppDimensions.xl),

              // Homeowner card
              _RoleCard(
                icon: Icons.home_outlined,
                title: 'homeowner_client'.tr,
                subtitle: 'manage_own_house'.tr,
                onTap: () => controller.selectRole('homeowner'),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 400.ms)
                  .slideX(begin: -0.1, end: 0),

              const SizedBox(height: AppDimensions.md),

              // Developer card
              _RoleCard(
                icon: Icons.business_outlined,
                title: 'developer_contractor'.tr,
                subtitle: 'manage_projects_for_clients'.tr,
                onTap: () => controller.selectRole('developer'),
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 400.ms)
                  .slideX(begin: 0.1, end: 0),

              const Spacer(),

              // Sign in link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'already_have_account'.tr,
                    style: AppTextStyles.bodySmall(context),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.login),
                    child: Text(
                      'sign_in'.tr,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: AppDimensions.base),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.base),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h4(context)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption(context),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
