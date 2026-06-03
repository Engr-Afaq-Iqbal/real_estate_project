import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/budget_controller.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../presentation/widgets/common/app_text_field.dart';

class LogExpenseSheet extends GetView<BudgetController> {
  const LogExpenseSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = ['Materials', 'Labor', 'Contractor', 'Equipment', 'Approvals', 'Misc'];
    final categoryIcons = [Icons.layers_outlined, Icons.people_outlined, Icons.handshake_outlined, Icons.construction_outlined, Icons.approval_outlined, Icons.more_horiz_rounded];

    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        title: Text('log_expense_title'.tr),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('category'.tr, style: AppTextStyles.labelMedium(context)),
            const SizedBox(height: AppDimensions.sm),

            // Category chips
            Obx(
              () => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(categories.length, (i) {
                    final cat = categories[i];
                    final isSelected = controller.selectedCategory.value == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppDimensions.sm),
                      child: GestureDetector(
                        onTap: () => controller.selectedCategory.value = cat,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.borderLight,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(categoryIcons[i], size: 14, color: isSelected ? Colors.white : AppColors.textSecondaryLight),
                              const SizedBox(width: 4),
                              Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? Colors.white : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.xl),

            AppTextField(
              label: 'item_name'.tr,
              hint: 'Cement — Lucky Star 50kg',
              controller: controller.itemNameCtrl,
            ),
            const SizedBox(height: AppDimensions.md),
            AppTextField(
              label: 'amount'.tr,
              hint: '68,400',
              controller: controller.amountCtrl,
              keyboardType: TextInputType.number,
              prefixText: 'PKR  ',
            ),
            const SizedBox(height: AppDimensions.md),
            AppTextField(
              label: 'vendor_supplier'.tr,
              hint: 'Ali Hardware, DHA Y-Block',
              controller: controller.vendorCtrl,
            ),
            const SizedBox(height: AppDimensions.md),
            Obx(
              () => AppTextField(
                label: 'date'.tr,
                hint: DateFormat('EEE, dd MMM yyyy').format(controller.selectedDate.value),
                readOnly: true,
                suffix: const Icon(Icons.calendar_today_outlined, size: 18),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: controller.selectedDate.value,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) controller.selectedDate.value = picked;
                },
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            AppTextField(
              label: 'note_optional'.tr,
              hint: '120 bags · negotiated 3% below market',
              controller: controller.noteCtrl,
              maxLines: 2,
            ),
            const SizedBox(height: AppDimensions.md),

            // Receipt upload
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('receipt'.tr, style: AppTextStyles.labelMedium(context)),
                const SizedBox(height: AppDimensions.xs),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: AppColors.textSecondaryLight,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.xl),

            Obx(
              () => AppButton(
                label: 'save_expense'.tr,
                isLoading: controller.isSaving.value,
                onPressed: controller.saveExpense,
              ),
            ),
            const SizedBox(height: AppDimensions.xxl),
          ],
        ),
      ),
    );
  }
}
