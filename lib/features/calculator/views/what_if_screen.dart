import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/what_if_controller.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../core/utils/currency_formatter.dart';

class WhatIfScreen extends GetView<WhatIfController> {
  const WhatIfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('What-If Scenario'),
        actions: [
          TextButton(
            onPressed: controller.resetAllSliders,
            child: const Text('Reset'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Base total input
            Text('Base Project Cost', style: AppTextStyles.h3S),
            SizedBox(height: 8.h),
            TextField(
              controller: controller.baseTotalCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: 'PKR ',
                hintText: 'Enter total project cost',
              ),
              onChanged: (_) => controller.runScenario(),
            ),
            SizedBox(height: 24.h),
            // Sliders
            Text('Adjust Price Changes (%)', style: AppTextStyles.h3S),
            SizedBox(height: 4.h),
            Text('Drag sliders to see impact on total cost',
                style: AppTextStyles.bodySmallS.copyWith(color: AppColors.textSecondaryLight)),
            SizedBox(height: 16.h),
            Obx(() => Column(
                  children: controller.sliders.map((s) => _SliderRow(
                        slider: s,
                        onChanged: (v) => controller.updateSlider(s.key, v),
                      )).toList(),
                )),
            SizedBox(height: 24.h),
            // Result card
            Obx(() {
              final r = controller.result.value;
              if (r == null) return const SizedBox.shrink();
              return _ResultCard(controller: controller);
            }),
          ],
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final dynamic slider;
  final void Function(double) onChanged;
  const _SliderRow({required this.slider, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 90.w,
                child: Text(slider.label as String, style: AppTextStyles.bodyMediumS),
              ),
              Expanded(
                child: Slider(
                  value: slider.changePct as double,
                  min: -30,
                  max: 50,
                  divisions: 80,
                  onChanged: onChanged,
                  activeColor: (slider.changePct as double) > 0
                      ? AppColors.error
                      : AppColors.success,
                ),
              ),
              SizedBox(
                width: 50.w,
                child: Text(
                  '${slider.changePct > 0 ? '+' : ''}${(slider.changePct as double).toStringAsFixed(0)}%',
                  style: AppTextStyles.bodyMediumS.copyWith(
                    color: (slider.changePct as double) > 0
                        ? AppColors.error
                        : (slider.changePct as double) < 0
                            ? AppColors.success
                            : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final WhatIfController controller;
  const _ResultCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isIncrease = controller.hasIncrease;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isIncrease
            ? AppColors.errorLight
            : AppColors.successLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: isIncrease ? AppColors.error.withOpacity(0.3) : AppColors.success.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Projected New Cost', style: AppTextStyles.bodyMediumS),
              const Spacer(),
              Text(
                controller.formattedNewTotal,
                style: AppTextStyles.h2S.copyWith(
                    color: isIncrease ? AppColors.error : AppColors.success),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text('Base Cost', style: AppTextStyles.bodySmallS),
              const Spacer(),
              Text(controller.formattedBaseTotal, style: AppTextStyles.bodySmallS),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Text('Impact', style: AppTextStyles.bodySmallS),
              const Spacer(),
              Text(
                controller.formattedImpact,
                style: AppTextStyles.bodySmallS.copyWith(
                  color: isIncrease ? AppColors.error : AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            controller.result.value?.recommendation ?? '',
            style: AppTextStyles.bodySmallS.copyWith(
                color: isIncrease ? AppColors.error : AppColors.success),
          ),
        ],
      ),
    );
  }
}

