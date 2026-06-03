import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../controllers/budget_controller.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../presentation/widgets/common/app_card.dart';
import '../../../presentation/routes/app_routes.dart';

class BudgetTrackerScreen extends GetView<BudgetController> {
  const BudgetTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('budget_tracker'.tr),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.download_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary card
              AppCard(
                child: Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 48,
                      lineWidth: 6,
                      percent: controller.budgetProgress.clamp(0, 1),
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(controller.budgetProgress * 100).toStringAsFixed(0)}%',
                            style: AppTextStyles.h3(context),
                          ),
                          Text('Spent', style: AppTextStyles.caption(context)),
                        ],
                      ),
                      progressColor: AppColors.primary,
                      backgroundColor: isDark ? AppColors.borderDark : AppColors.dividerLight,
                    ),
                    const SizedBox(width: AppDimensions.base),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            CurrencyFormatter.formatLakh(controller.spentBudget.value),
                            style: AppTextStyles.amountMedium(context),
                          ),
                          Text(
                            '/ ${CurrencyFormatter.formatLakh(controller.totalBudget.value)}',
                            style: AppTextStyles.caption(context),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${CurrencyFormatter.formatLakh(controller.remainingBudget)} remaining',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.sm),
                          _buildMiniProgress('Materials', 0.64, AppColors.primary),
                          const SizedBox(height: 4),
                          _buildMiniProgress('Labor', 0.52, AppColors.success),
                          const SizedBox(height: 4),
                          _buildMiniProgress('Equipment', 0.60, AppColors.warning),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.md),

              // AI Alert
              AppCard(
                color: AppColors.warningLight,
                hasBorder: false,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            WidgetSpan(
                              child: Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 14),
                            ),
                            TextSpan(
                              text: ' AI Alert · Approvals at 90% of budget with NOC still pending. Reserve PKR 25k for contingency.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.xl),
              Text('category_breakdown'.tr, style: AppTextStyles.overline(context)),
              const SizedBox(height: AppDimensions.md),

              // Category rows
              ...controller.categoryBreakdown.entries.map(
                (entry) => _CategoryRow(
                  name: entry.key,
                  spent: entry.value['spent']!,
                  budget: entry.value['budget']!,
                ),
              ),

              const SizedBox(height: AppDimensions.xl),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.dividerLight)),
        ),
        child: AppButton(
          label: 'log_expense'.tr,
          onPressed: () => Get.toNamed(AppRoutes.logExpense),
        ),
      ),
    );
  }

  Widget _buildMiniProgress(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: const TextStyle(fontSize: 10))),
        const SizedBox(width: 4),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 3,
              backgroundColor: AppColors.dividerLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String name;
  final double spent;
  final double budget;
  const _CategoryRow({required this.name, required this.spent, required this.budget});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = budget > 0 ? spent / budget : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.md),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: AppDimensions.md),
            decoration: BoxDecoration(
              color: _categoryColor(name),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(name, style: AppTextStyles.labelLarge(context))),
                    Text(
                      '${CurrencyFormatter.formatLakh(spent)}\nof ${CurrencyFormatter.formatLakh(budget)}',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.labelMedium(context),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0, 1),
                    minHeight: AppDimensions.progressBarHeight,
                    backgroundColor: isDark ? AppColors.borderDark : AppColors.dividerLight,
                    valueColor: AlwaysStoppedAnimation<Color>(_categoryColor(name)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(String name) {
    final map = {
      'Materials & Steel': AppColors.primary,
      'Labor': AppColors.success,
      'Contractor Fee': AppColors.accent,
      'Equipment': AppColors.warning,
      'Approvals': const Color(0xFF22C55E),
      'Misc': AppColors.textSecondaryLight,
    };
    return map[name] ?? AppColors.primary;
  }
}
