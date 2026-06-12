// ═════════════════════════════════════════════════════════════════════════════
// Feature temporarily disabled. Full Estimate screen preserved for future
// implementation.
//
// This screen was reachable via the "Full Estimate" button in the dashboard
// Quick Estimator section (now removed) and the deprecated CalculatorHubScreen.
// Its HouseEstimatorController is intentionally left registered in
// CalculatorBinding and untouched.
//
// To reactivate:
//   1. Uncomment this entire file (remove the /* ... */ wrapper below).
//   2. Restore the import + AppRoutes.houseEstimator GetPage entry in
//      lib/presentation/routes/app_pages.dart (commented out there).
//   3. Re-add a navigation entry point.
// ═════════════════════════════════════════════════════════════════════════════

/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/house_estimator_controller.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../projects/engine/budget_engine.dart';

class HouseEstimatorScreen extends GetView<HouseEstimatorController> {
  const HouseEstimatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text('House Cost Estimator')),
      body: Obx(() {
        return Column(
          children: [
            // Step indicator
            _StepIndicator(currentStep: controller.currentStep.value),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: _stepWidget(controller.currentStep.value),
              ),
            ),
            _BottomNav(controller: controller),
          ],
        );
      }),
    );
  }

  Widget _stepWidget(int step) => switch (step) {
        0 => _Step0Area(controller: controller),
        1 => _Step1Quality(controller: controller),
        _ => _Step2Results(controller: controller),
      };
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4.h,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: List.generate(HouseEstimatorController.totalSteps, (i) =>
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < HouseEstimatorController.totalSteps - 1 ? 4.w : 0),
              height: 4.h,
              decoration: BoxDecoration(
                color: i <= currentStep ? AppColors.primary : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final HouseEstimatorController controller;
  const _BottomNav({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Obx(() {
        final step = controller.currentStep.value;
        return Row(
          children: [
            if (step > 0)
              Expanded(
                child: AppButton.outline(
                  label: 'Back',
                  onPressed: controller.prevStep,
                ),
              ),
            if (step > 0) SizedBox(width: 12.w),
            Expanded(
              flex: 2,
              child: AppButton.primary(
                label: step == HouseEstimatorController.totalSteps - 1
                    ? 'Save Calculation'
                    : 'Next',
                isLoading: controller.isCalculating.value,
                onPressed: step == HouseEstimatorController.totalSteps - 1
                    ? () => _showSaveDialog()
                    : controller.nextStep,
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showSaveDialog() {
    final titleCtrl = TextEditingController(text: 'My Estimate');
    Get.dialog(AlertDialog(
      title: const Text('Save Calculation'),
      content: TextField(
        controller: titleCtrl,
        decoration: const InputDecoration(labelText: 'Title'),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            Get.back();
            controller.saveCalculation(titleCtrl.text);
          },
          child: const Text('Save'),
        ),
      ],
    ));
  }
}

class _Step0Area extends StatelessWidget {
  final HouseEstimatorController controller;
  const _Step0Area({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Construction Area', style: AppTextStyles.h2S),
        Text('Enter the covered area you want to build', style: AppTextStyles.bodySmallS.copyWith(color: AppColors.textSecondaryLight)),
        SizedBox(height: 20.h),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: controller.constructionCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Area', hintText: 'e.g. 4.5'),
                onChanged: controller.onConstructionAreaChanged,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              flex: 2,
              child: Obx(() => DropdownButtonFormField<String>(
                    value: controller.constructionUnit.value,
                    onChanged: (v) => controller.constructionUnit.value = v ?? 'marla',
                    items: UnitConverter.pakistanUnits
                        .map((u) => DropdownMenuItem(value: u, child: Text(UnitConverter.label(u))))
                        .toList(),
                    decoration: const InputDecoration(labelText: 'Unit'),
                  )),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Obx(() {
          // Read constructionHintText.value — always subscribes even when empty
          final hint = controller.constructionHintText.value;
          if (hint.isEmpty) return const SizedBox.shrink();
          return Text('= $hint', style: AppTextStyles.bodySmallS.copyWith(color: AppColors.accent));
        }),
        SizedBox(height: 20.h),
        Text('Number of Floors', style: AppTextStyles.labelLargeS),
        SizedBox(height: 10.h),
        Obx(() => Row(
              children: [1, 2, 3, 4].map((f) => Padding(
                    padding: EdgeInsets.only(right: 10.w),
                    child: GestureDetector(
                      onTap: () => controller.floors.value = f,
                      child: Container(
                        width: 56.w, height: 48.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: controller.floors.value == f ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                          border: Border.all(
                              color: controller.floors.value == f ? AppColors.primary : AppColors.borderLight),
                        ),
                        child: Text('$f',
                            style: TextStyle(
                              color: controller.floors.value == f ? AppColors.white : AppColors.textPrimaryLight,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ),
                  )).toList(),
            )),
      ],
    );
  }
}

class _Step1Quality extends StatelessWidget {
  final HouseEstimatorController controller;
  const _Step1Quality({required this.controller});

  static const List<Map<String, dynamic>> tiers = [
    {'key': 'economy',  'label': 'Economy',  'desc': 'Basic finishes, standard materials',          'rate': '1,500â€“1,800'},
    {'key': 'standard', 'label': 'Standard', 'desc': 'Good quality, mid-range finishes',             'rate': '2,000â€“2,500'},
    {'key': 'premium',  'label': 'Premium',  'desc': 'High quality, imported tiles & fittings',      'rate': '3,200â€“4,000'},
    {'key': 'luxury',   'label': 'Luxury',   'desc': 'Top-of-line, custom design, branded imports',  'rate': '5,500+'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Construction Quality', style: AppTextStyles.h2S),
        Text('Select the quality tier for your project', style: AppTextStyles.bodySmallS.copyWith(color: AppColors.textSecondaryLight)),
        SizedBox(height: 20.h),
        ...tiers.map((t) => Obx(() {
              final selected = controller.qualityTier.value == t['key'];
              return GestureDetector(
                onTap: () => controller.qualityTier.value = t['key'] as String,
                child: Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    border: Border.all(
                        color: selected ? AppColors.primary : AppColors.borderLight,
                        width: selected ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t['label'] as String,
                                style: AppTextStyles.bodyMediumS.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: selected ? AppColors.primary : null)),
                            Text(t['desc'] as String,
                                style: AppTextStyles.bodySmallS.copyWith(
                                    color: AppColors.textSecondaryLight)),
                          ],
                        ),
                      ),
                      Text('PKR ${t['rate']}/sqft',
                          style: AppTextStyles.labelSmallS.copyWith(
                              color: selected ? AppColors.primary : AppColors.textSecondaryLight)),
                    ],
                  ),
                ),
              );
            })),
      ],
    );
  }
}

class _Step2Results extends StatelessWidget {
  final HouseEstimatorController controller;
  const _Step2Results({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isCalculating.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final est = controller.estimate.value;
      if (est == null) {
        return const Center(child: Text('Could not calculate. Check inputs.'));
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero total
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Estimated Cost',
                    style: AppTextStyles.bodyMediumS.copyWith(color: AppColors.white.withOpacity(0.8))),
                Text(CurrencyFormatter.format(est.total),
                    style: AppTextStyles.displayMediumS.copyWith(color: AppColors.white)),
                SizedBox(height: 4.h),
                Text('${controller.ratePerSqft}  Â·  ${est.totalAreaSqft.toStringAsFixed(0)} sq ft',
                    style: AppTextStyles.bodySmallS.copyWith(color: AppColors.white.withOpacity(0.7))),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Text('Cost Breakdown', style: AppTextStyles.h3S),
          SizedBox(height: 12.h),
          ...est.components.entries.map((e) {
            final pct = est.subtotal > 0 ? (e.value / est.subtotal * 100) : 0.0;
            return _ComponentRow(
              label: HouseEstimatorController.componentLabel(e.key),
              amount: e.value,
              pct: pct,
            );
          }),
          Divider(height: 20.h),
          _ComponentRow(label: 'Subtotal', amount: est.subtotal, pct: 100, bold: true),
          _ComponentRow(label: 'Contingency (10%)', amount: est.contingency, pct: 10),
          _ComponentRow(label: 'Total', amount: est.total, pct: 0, bold: true, highlight: true),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _InfoChip(label: 'Materials', value: CurrencyFormatter.formatCompact(est.materialsOnly)),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _InfoChip(label: 'Labor', value: CurrencyFormatter.formatCompact(est.laborOnly)),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text('Price basis: ${est.priceDate}',
              style: AppTextStyles.labelSmallS.copyWith(color: AppColors.textSecondaryLight)),
        ],
      );
    });
  }
}

class _ComponentRow extends StatelessWidget {
  final String label;
  final double amount;
  final double pct;
  final bool bold;
  final bool highlight;
  const _ComponentRow({required this.label, required this.amount, required this.pct, this.bold = false, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: AppTextStyles.bodyMediumS.copyWith(
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                    color: highlight ? AppColors.primary : null)),
          ),
          Text(
            CurrencyFormatter.formatCompact(amount),
            style: AppTextStyles.bodyMediumS.copyWith(
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                color: highlight ? AppColors.primary : null),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelSmallS.copyWith(color: AppColors.textSecondaryLight)),
          Text(value, style: AppTextStyles.bodyMediumS.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
*/

