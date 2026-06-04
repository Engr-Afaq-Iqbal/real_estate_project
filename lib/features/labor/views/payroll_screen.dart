import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/payroll_controller.dart';
import '../data/models/payroll_model.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../presentation/widgets/common/app_empty_state.dart';
import '../../../presentation/widgets/common/app_loading.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';

class PayrollScreen extends GetView<PayrollController> {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text('Payroll')),
      body: Obx(() {
        if (controller.isLoading.value) return const AppFullScreenLoader();

        return Column(
          children: [
            // Summary
            Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Paid', style: AppTextStyles.labelMediumS.copyWith(color: AppColors.white.withOpacity(0.8))),
                        Text(controller.formattedTotalPaid,
                            style: AppTextStyles.h2S.copyWith(color: AppColors.white)),
                      ],
                    ),
                  ),
                  if (controller.unpaidWeeksCount > 0)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      ),
                      child: Text('${controller.unpaidWeeksCount} unpaid',
                          style: AppTextStyles.labelSmallS.copyWith(color: AppColors.white)),
                    ),
                ],
              ),
            ),

            // Generate current week button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Obx(() => AppButton.primary(
                    label: controller.isGenerating.value
                        ? 'Generating...'
                        : 'Generate This Week\'s Payroll',
                    isLoading: controller.isGenerating.value,
                    onPressed: () => controller.generateCurrentWeek(),
                  )),
            ),
            SizedBox(height: 16.h),

            // Payroll weeks list
            if (controller.payrollWeeks.isEmpty)
              Expanded(
                child: AppEmptyState(
                  icon: Icons.payments_outlined,
                  title: 'No Payroll Generated',
                  subtitle: 'Generate payroll for the current week after marking attendance',
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                  itemCount: controller.payrollWeeks.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (_, i) =>
                      _PayrollWeekCard(week: controller.payrollWeeks[i], controller: controller),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _PayrollWeekCard extends StatelessWidget {
  final PayrollWeekModel week;
  final PayrollController controller;
  const _PayrollWeekCard({required this.week, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = week.isPaid ? AppColors.success
        : week.isApproved ? AppColors.info
        : AppColors.warning;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(week.weekLabel,
                    style: AppTextStyles.bodyMediumS.copyWith(fontWeight: FontWeight.w600)),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                ),
                child: Text(
                  week.status.name.toUpperCase(),
                  style: AppTextStyles.labelSmallS.copyWith(color: statusColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text('${week.lineItems.length} workers',
                  style: AppTextStyles.bodySmallS.copyWith(color: AppColors.textSecondaryLight)),
              const Spacer(),
              Text(
                CurrencyFormatter.formatCompact(week.totalAmount),
                style: AppTextStyles.h3S.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          if (!week.isPaid) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                if (week.isDraft) Expanded(
                  child: AppButton.outline(
                    label: 'Approve',
                    onPressed: () => controller.approveWeek(week.id),
                  ),
                ),
                if (!week.isDraft) SizedBox(width: 8.w),
                if (week.isApproved) Expanded(
                  child: AppButton.primary(
                    label: 'Mark as Paid',
                    onPressed: () => controller.markAsPaid(week.id, 'cash'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}


