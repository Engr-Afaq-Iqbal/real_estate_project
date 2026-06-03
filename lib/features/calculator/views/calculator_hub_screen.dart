import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/calculator_controller.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_card.dart';
import '../../../presentation/routes/app_routes.dart';

class CalculatorHubScreen extends GetView<CalculatorController> {
  const CalculatorHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('cost_calculator'.tr),
        actions: [
          TextButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.savedCalculations),
            icon: const Icon(Icons.history_rounded, size: 18),
            label: Text('history'.tr),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Column(
          children: [
            // Tagline
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.base),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: const Border(
                  left: BorderSide(color: AppColors.primary, width: 3),
                ),
              ),
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.bodySmall(context),
                  children: [
                    TextSpan(
                      text: 'Plan with confidence. ',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                    TextSpan(
                      text: 'Calculate full construction cost before starting — every detail covered.',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.xl),

            // New calculation CTA
            AppCard(
              onTap: () => Get.toNamed(AppRoutes.calculatorForm),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: const Icon(Icons.calculate_outlined, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('start_new_calculation'.tr, style: AppTextStyles.h4(context)),
                        Text('calculate_from_scratch'.tr, style: AppTextStyles.caption(context)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryLight),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.md),

            // Saved results
            AppCard(
              onTap: () => Get.toNamed(AppRoutes.savedCalculations),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: const Icon(Icons.folder_outlined, color: AppColors.warning, size: 22),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('my_saved_results'.tr, style: AppTextStyles.h4(context)),
                        Text('view_past_calculations'.tr, style: AppTextStyles.caption(context)),
                      ],
                    ),
                  ),
                  Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Text(
                      '${controller.savedCalculations.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  )),
                  const SizedBox(width: AppDimensions.sm),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryLight),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.xl),
            Text('quick_tools'.tr, style: AppTextStyles.overline(context)),
            const SizedBox(height: AppDimensions.md),

            // Quick tools grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppDimensions.md,
              mainAxisSpacing: AppDimensions.md,
              childAspectRatio: 1.3,
              children: const [
                _QuickTool(icon: Icons.layers_outlined, label: 'Material Estimator', color: Color(0xFF1E3A8A)),
                _QuickTool(icon: Icons.people_outlined, label: 'Labor Rates', color: Color(0xFF22C55E)),
                _QuickTool(icon: Icons.bar_chart_rounded, label: 'Stage-wise Budget', color: Color(0xFF8B5CF6)),
                _QuickTool(icon: Icons.trending_up_rounded, label: 'Price Comparison', color: Color(0xFFEF4444)),
              ],
            ),

            const SizedBox(height: AppDimensions.xl),
            Text(
              'Prices last updated · June 2025 · Lahore',
              style: AppTextStyles.caption(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.xxl),
          ],
        ),
      ),
    );
  }
}

class _QuickTool extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickTool({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {},
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: AppDimensions.iconMd),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppTextStyles.h4(context)),
              Text('Open →', style: const TextStyle(fontSize: 11, color: AppColors.accent)),
            ],
          ),
        ],
      ),
    );
  }
}
