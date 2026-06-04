import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/material_calculator_controller.dart';
import '../engine/material_calculator.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/data/price_master_data.dart';

class MaterialCalculatorScreen extends GetView<MaterialCalculatorController> {
  const MaterialCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text('Material Calculator')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode toggle
            _ModeToggle(controller: controller),
            SizedBox(height: 20.h),

            Obx(() => controller.mode.value == MaterialCalcMode.byArea
                ? _ByAreaSection(controller: controller)
                : _ByQuantitySection(controller: controller)),
          ],
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final MaterialCalculatorController controller;
  const _ModeToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => SegmentedButton<MaterialCalcMode>(
          segments: const [
            ButtonSegment(
              value: MaterialCalcMode.byArea,
              label: Text('By Area'),
              icon: Icon(Icons.square_foot),
            ),
            ButtonSegment(
              value: MaterialCalcMode.byQuantity,
              label: Text('By Quantity'),
              icon: Icon(Icons.calculate),
            ),
          ],
          selected: {controller.mode.value},
          onSelectionChanged: (s) => controller.setMode(s.first),
        ));
  }
}

class _ByAreaSection extends StatelessWidget {
  final MaterialCalculatorController controller;
  const _ByAreaSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Construction Area', style: AppTextStyles.h3S),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: controller.areaCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'e.g. 1800'),
                onChanged: controller.onAreaChanged,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              flex: 2,
              child: Obx(() => DropdownButtonFormField<String>(
                    value: controller.areaUnit.value,
                    onChanged: (v) {
                      controller.areaUnit.value = v ?? 'sqft';
                      controller.calculateFromArea();
                    },
                    items: UnitConverter.pakistanUnits
                        .map((u) => DropdownMenuItem(
                              value: u,
                              child: Text(UnitConverter.label(u)),
                            ))
                        .toList(),
                    decoration: const InputDecoration(),
                  )),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Obx(() {
          final hint = controller.areaHintText.value;
          if (hint.isEmpty) return const SizedBox.shrink();
          return Text('= $hint', style: AppTextStyles.bodySmallS.copyWith(color: AppColors.accent));
        }),
        SizedBox(height: 16.h),
        // Floors
        Row(
          children: [
            Text('Floors', style: AppTextStyles.labelLargeS),
            const Spacer(),
            Obx(() => Row(
                  children: [1, 2, 3, 4].map((f) => Padding(
                    padding: EdgeInsets.only(left: 6.w),
                    child: GestureDetector(
                      onTap: () {
                        controller.floors.value = f;
                        controller.calculateFromArea();
                      },
                      child: Container(
                        width: 36.w, height: 36.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: controller.floors.value == f
                              ? AppColors.primary
                              : AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: controller.floors.value == f
                                ? AppColors.primary
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Text('$f',
                            style: TextStyle(
                              color: controller.floors.value == f
                                  ? AppColors.white
                                  : AppColors.textPrimaryLight,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ),
                  )).toList(),
                )),
          ],
        ),
        SizedBox(height: 20.h),
        // Results
        Obx(() {
          final est = controller.fullEstimate.value;
          if (est == null) return const SizedBox.shrink();
          return _MaterialResultCard(estimate: est);
        }),
      ],
    );
  }
}

class _MaterialResultCard extends StatelessWidget {
  final FullMaterialEstimate estimate;
  const _MaterialResultCard({required this.estimate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Material Estimate',
              style: AppTextStyles.h3S.copyWith(color: AppColors.primary)),
          Text('${estimate.totalAreaSqft.toStringAsFixed(0)} sq ft Ã— ${estimate.floors} floor(s)',
              style: AppTextStyles.bodySmallS.copyWith(color: AppColors.textSecondaryLight)),
          SizedBox(height: 12.h),
          _Row('Cement', '${estimate.cement.totalBags} bags (50kg)'),
          _Row('Steel', '${estimate.steel.kg.toStringAsFixed(0)} kg (${estimate.steel.tons.toStringAsFixed(1)} tons)'),
          _Row('Bricks', '${estimate.bricks.quantity} pieces (+5% wastage)'),
          _Row('Sand', '${estimate.sand.cft.toStringAsFixed(0)} cft'),
          _Row('Crush', '${estimate.crush.cft.toStringAsFixed(0)} cft'),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyMediumS)),
          Text(value,
              style: AppTextStyles.bodyMediumS.copyWith(
                  fontWeight: FontWeight.w600, color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _ByQuantitySection extends StatelessWidget {
  final MaterialCalculatorController controller;
  const _ByQuantitySection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category selector
        Text('Select Material', style: AppTextStyles.h3S),
        SizedBox(height: 10.h),
        SizedBox(
          height: 40.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.categories.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (_, i) {
              final cat = controller.categories[i];
              return Obx(() {
                final selected = controller.selectedCategory.value?.id == cat.id;
                return GestureDetector(
                  onTap: () => controller.selectCategory(cat),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      border: Border.all(
                          color: selected ? AppColors.primary : AppColors.borderLight),
                    ),
                    child: Text(cat.name,
                        style: TextStyle(
                          color: selected ? AppColors.white : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        )),
                  ),
                );
              });
            },
          ),
        ),
        SizedBox(height: 16.h),
        Obx(() {
          final mats = controller.materialsForCategory;
          if (mats.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Brand / Type', style: AppTextStyles.labelLargeS),
              SizedBox(height: 6.h),
              DropdownButtonFormField<MaterialPriceData>(
                value: controller.selectedMaterial.value,
                hint: const Text('Select material'),
                onChanged: (v) { if (v != null) controller.selectMaterial(v); },
                items: mats.map((m) => DropdownMenuItem(
                  value: m,
                  child: Text('${m.name}  â€“  PKR ${m.price.toStringAsFixed(0)}/${m.unit}'),
                )).toList(),
                decoration: const InputDecoration(),
              ),
            ],
          );
        }),
        SizedBox(height: 16.h),
        Text('Quantity', style: AppTextStyles.labelLargeS),
        SizedBox(height: 6.h),
        Obx(() => TextField(
              controller: controller.quantityCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: controller.selectedMaterial.value != null
                    ? 'Enter quantity in ${controller.selectedMaterial.value!.unit}s'
                    : 'Enter quantity',
                suffixText: controller.selectedMaterial.value?.unit ?? '',
              ),
            )),
        SizedBox(height: 12.h),
        Text('Unit Price (PKR)', style: AppTextStyles.labelLargeS),
        SizedBox(height: 6.h),
        TextField(
          controller: controller.priceCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Auto-filled from market price'),
        ),
        SizedBox(height: 20.h),
        AppButton.primary(
          label: 'Calculate Cost',
          onPressed: controller.calculateFromQuantity,
        ),
        SizedBox(height: 16.h),
        Obx(() {
          final r = controller.result.value;
          if (r == null) return const SizedBox.shrink();
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Total Cost', style: AppTextStyles.bodyMediumS),
                    const Spacer(),
                    Text(
                      CurrencyFormatter.formatCompact(r.totalCost),
                      style: AppTextStyles.h2S.copyWith(color: AppColors.success),
                    ),
                  ],
                ),
                Divider(height: 16.h),
                _Row('Base Quantity', '${r.baseQuantity.toStringAsFixed(0)} ${r.unit}'),
                if (r.wasteQuantity > 0)
                  _Row('Wastage (+5%)', '+${r.wasteQuantity.toStringAsFixed(0)} ${r.unit}'),
                _Row('Unit Price', 'PKR ${CurrencyFormatter.formatNumber(r.unitPrice)}'),
              ],
            ),
          );
        }),
      ],
    );
  }
}

