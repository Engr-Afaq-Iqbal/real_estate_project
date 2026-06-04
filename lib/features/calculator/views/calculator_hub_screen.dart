import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/calculator_controller.dart';
import '../controllers/calculator_hub_controller.dart';
import '../data/models/saved_calculation_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_card.dart';
import '../../../presentation/routes/app_routes.dart';

class CalculatorHubScreen extends StatelessWidget {
  const CalculatorHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use CalculatorHubController if available, fall back to legacy
    CalculatorHubController? hubCtrl;
    CalculatorController? legacyCtrl;
    try {
      hubCtrl = Get.find<CalculatorHubController>();
    } catch (_) {}
    try {
      legacyCtrl = Get.find<CalculatorController>();
    } catch (_) {}

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price freshness banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.md),
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
                    const TextSpan(
                      text: 'Plan with confidence. ',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                    const TextSpan(
                      text: 'Prices updated for Lahore market · June 2026',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.xl),
            Text('Calculators', style: AppTextStyles.overline(context)),
            const SizedBox(height: AppDimensions.md),

            // ── 4 Calculator cards ─────────────────────────────────────────
            _CalcCard(
              icon: Icons.home_work_outlined,
              color: AppColors.primary,
              bgColor: AppColors.infoLight,
              title: 'Full House Estimator',
              subtitle: 'Total cost by area, floors & quality',
              badge: 'Most Popular',
              onTap: () => Get.toNamed(AppRoutes.houseEstimator),
            ),
            const SizedBox(height: AppDimensions.md),

            _CalcCard(
              icon: Icons.layers_outlined,
              color: const Color(0xFF16A34A),
              bgColor: const Color(0xFFDCFCE7),
              title: 'Material Calculator',
              subtitle: 'Cement, steel, bricks, tiles & more',
              onTap: () => Get.toNamed(AppRoutes.materialCalculator),
            ),
            const SizedBox(height: AppDimensions.md),

            _CalcCard(
              icon: Icons.trending_up_rounded,
              color: const Color(0xFFF59E0B),
              bgColor: const Color(0xFFFEF3C7),
              title: 'What-If Scenarios',
              subtitle: 'See impact if steel or cement prices rise',
              onTap: () => Get.toNamed(AppRoutes.whatIfCalculator),
            ),
            const SizedBox(height: AppDimensions.md),

            _CalcCard(
              icon: Icons.folder_outlined,
              color: const Color(0xFF8B5CF6),
              bgColor: const Color(0xFFEDE9FE),
              title: 'Saved Calculations',
              subtitle: 'View & compare past estimates',
              onTap: () => Get.toNamed(AppRoutes.savedCalculations),
              trailing: legacyCtrl != null
                  ? Obx(() => _CountBadge('${legacyCtrl!.savedCalculations.length}'))
                  : null,
            ),

            const SizedBox(height: AppDimensions.xl),

            // ── Recent saved ───────────────────────────────────────────────
            if (legacyCtrl != null) ...[
              Text('recent_saved'.tr.isEmpty ? 'Recent' : 'Recent',
                  style: AppTextStyles.overline(context)),
              const SizedBox(height: AppDimensions.md),
              Obx(() {
                final saved = legacyCtrl!.savedCalculations.take(3).toList();
                if (saved.isEmpty) return const SizedBox.shrink();
                return Column(
                  children: saved
                      .map((c) => _SavedRow(
                            title: c.name,
                            city: c.city,
                            quality: c.quality,
                            amount: c.totalCost,
                            date: c.date,
                          ))
                      .toList(),
                );
              }),
            ],

            const SizedBox(height: AppDimensions.xxl),
          ],
        ),
      ),
    );
  }
}

class _CalcCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;
  final Widget? trailing;

  const _CalcCard({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: AppTextStyles.h4(context)),
                    if (badge != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                        ),
                        child: Text(badge!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption(context)),
              ],
            ),
          ),
          trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryLight),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final String count;
  const _CountBadge(this.count);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: Text(count,
                style: const TextStyle(
                    color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryLight),
        ],
      );
}

class _SavedRow extends StatelessWidget {
  final String title;
  final String city;
  final String quality;
  final double amount;
  final DateTime date;

  const _SavedRow({
    required this.title,
    required this.city,
    required this.quality,
    required this.amount,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: () => Get.toNamed(AppRoutes.savedCalculations),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelLarge(context)),
                  Text('$city · $quality · ${DateFormatter.formatDateShort(date)}',
                      style: AppTextStyles.caption(context)),
                ],
              ),
            ),
            Text(
              CurrencyFormatter.formatCompact(amount),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
