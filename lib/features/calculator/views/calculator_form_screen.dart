import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/calculator_controller.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../presentation/widgets/common/app_card.dart';

class CalculatorFormScreen extends GetView<CalculatorController> {
  const CalculatorFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stepLabels = ['Details', 'Structure', 'Materials', 'Labor', 'Summary'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cost Estimate'),
        actions: [
          Obx(() => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Step ${controller.currentStep.value + 1}/5',
                style: AppTextStyles.labelMedium(context),
              ),
            ),
          )),
        ],
      ),
      body: Column(
        children: [
          // Step progress
          Obx(() => _StepProgress(
            steps: stepLabels,
            currentStep: controller.currentStep.value,
          )),
          Expanded(
            child: Obx(() {
              if (controller.currentStep.value < 4) {
                return _InputStep(stepIndex: controller.currentStep.value);
              }
              return _SummaryStep(controller: controller);
            }),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.dividerLight)),
            ),
            child: Obx(() => Row(
              children: [
                if (controller.currentStep.value > 0) ...[
                  Expanded(
                    child: AppButton.outline(
                      label: 'Back',
                      onPressed: controller.prevStep,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                ],
                Expanded(
                  flex: 2,
                  child: AppButton(
                    label: controller.currentStep.value == 4
                        ? '📋 Use as Project Budget'
                        : 'Next →',
                    onPressed: () {
                      if (controller.currentStep.value < 4) {
                        controller.nextStep();
                      } else {
                        Get.back();
                      }
                    },
                  ),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  final List<String> steps;
  final int currentStep;

  const _StepProgress({required this.steps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
        vertical: AppDimensions.md,
      ),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == currentStep;
          final isCompleted = i < currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isCompleted || isActive ? AppColors.primary : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCompleted || isActive ? AppColors.primary : AppColors.borderLight,
                          ),
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                              : Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isActive ? Colors.white : AppColors.textTertiaryLight,
                                  ),
                                ),
                        ),
                      ),
                      Text(
                        steps[i],
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive ? AppColors.primary : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      color: i < currentStep ? AppColors.primary : AppColors.borderLight,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _InputStep extends StatelessWidget {
  final int stepIndex;
  const _InputStep({required this.stepIndex});

  @override
  Widget build(BuildContext context) {
    final titles = ['Project Details', 'Structure Type', 'Material Quality', 'Labor & Contractor'];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titles[stepIndex], style: AppTextStyles.h2(context)),
          const SizedBox(height: AppDimensions.xl),
          const Center(child: Text('Form inputs for this step')),
        ],
      ),
    );
  }
}

class _SummaryStep extends StatelessWidget {
  final CalculatorController controller;
  const _SummaryStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors.chartColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      child: Obx(() {
        final breakdown = controller.breakdown;
        final total = controller.breakdownTotal;
        final sections = breakdown.entries.toList();

        return Column(
          children: [
            // Donut chart
            Text('ESTIMATED TOTAL', style: AppTextStyles.overline(context)),
            const SizedBox(height: AppDimensions.md),
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: List.generate(sections.length, (i) {
                        final entry = sections[i];
                        return PieChartSectionData(
                          value: entry.value,
                          color: colors[i % colors.length],
                          radius: 40,
                          showTitle: false,
                        );
                      }),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Total', style: AppTextStyles.caption(context)),
                      Text(
                        CurrencyFormatter.formatLakh(total),
                        style: AppTextStyles.amountMedium(context),
                      ),
                      Text('± 4% margin', style: AppTextStyles.caption(context)),
                    ],
                  ),
                ],
              ),
            ),

            Text(
              'Valid for current Lahore prices · DHA Phase 6',
              style: AppTextStyles.caption(context),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimensions.xl),
            Text('cost_breakdown'.tr, style: AppTextStyles.overline(context)),
            const SizedBox(height: AppDimensions.md),

            ...List.generate(sections.length, (i) {
              final entry = sections[i];
              final percent = total > 0 ? (entry.value / total * 100).toStringAsFixed(0) : '0';
              return _BreakdownRow(
                label: entry.key,
                amount: entry.value,
                percent: '$percent%',
                color: colors[i % colors.length],
              );
            }),

            const SizedBox(height: AppDimensions.xl),
          ],
        );
      }),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final double amount;
  final String percent;
  final Color color;

  const _BreakdownRow({
    required this.label,
    required this.amount,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(child: Text(label, style: AppTextStyles.labelLarge(context))),
              Text(CurrencyFormatter.formatLakh(amount), style: AppTextStyles.h4(context)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  child: LinearProgressIndicator(
                    value: 0.38,
                    minHeight: 4,
                    backgroundColor: isDark ? AppColors.borderDark : AppColors.dividerLight,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Text(percent, style: AppTextStyles.labelSmall(context)),
            ],
          ),
        ],
      ),
    );
  }
}
