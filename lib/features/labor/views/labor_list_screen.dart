import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/labor_list_controller.dart';
import '../data/models/labor_model.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../presentation/widgets/common/app_empty_state.dart';
import '../../../presentation/widgets/common/app_loading.dart';
import '../../../presentation/routes/app_routes.dart';
import '../../../core/utils/currency_formatter.dart';

class LaborListScreen extends GetView<LaborListController> {
  const LaborListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Labor Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Payroll',
            onPressed: () => Get.toNamed(AppRoutes.payroll),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: 'Attendance',
            onPressed: () => Get.toNamed(AppRoutes.laborAttendance),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLaborSheet(context),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add Worker'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppFullScreenLoader();
        }
        if (controller.activeLabor.isEmpty) {
          return AppEmptyState(
            icon: Icons.people_outline,
            title: 'No Workers Added',
            subtitle: 'Add your site workers to start tracking attendance',
            buttonLabel: 'Add Worker',
            onAction: () => _showAddLaborSheet(context),
          );
        }
        return Column(
          children: [
            _SummaryBar(controller: controller),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 100.h),
                itemCount: controller.activeLabor.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (_, i) =>
                    _LaborTile(labor: controller.activeLabor[i]),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showAddLaborSheet(BuildContext context) {
    Get.bottomSheet(
      _AddLaborSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final LaborListController controller;
  const _SummaryBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          _StatItem(
            label: 'Active Workers',
            value: '${controller.totalWorkers}',
            icon: Icons.people,
          ),
          _Divider(),
          _StatItem(
            label: 'Daily Total',
            value: controller.formattedDailyTotal,
            icon: Icons.payments_outlined,
          ),
          _Divider(),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.laborAttendance),
            child: _StatItem(
              label: 'Attendance',
              value: 'Mark â†’',
              icon: Icons.checklist,
              highlight: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 32.h, width: 1,
        color: AppColors.primary.withOpacity(0.2),
        margin: EdgeInsets.symmetric(horizontal: 12.w),
      );
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool highlight;
  const _StatItem({required this.label, required this.value, required this.icon, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18.sp, color: highlight ? AppColors.accent : AppColors.primary),
          SizedBox(height: 4.h),
          Text(value,
              style: AppTextStyles.h4S.copyWith(
                color: highlight ? AppColors.accent : AppColors.primary,
                fontWeight: FontWeight.w700,
              )),
          Text(label, style: AppTextStyles.labelSmallS.copyWith(color: AppColors.textSecondaryLight)),
        ],
      ),
    );
  }
}

class _LaborTile extends StatelessWidget {
  final LaborModel labor;
  const _LaborTile({required this.labor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: AppColors.primary.withOpacity(0.12),
            child: Text(
              labor.initials,
              style: AppTextStyles.h4S.copyWith(color: AppColors.primary),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(labor.fullName, style: AppTextStyles.bodyMediumS.copyWith(fontWeight: FontWeight.w600)),
                SizedBox(height: 2.h),
                Text(labor.role, style: AppTextStyles.bodySmallS.copyWith(color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.formatCompact(labor.dailyWage),
                style: AppTextStyles.labelLargeS.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
              Text('/day', style: AppTextStyles.labelSmallS.copyWith(color: AppColors.textSecondaryLight)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddLaborSheet extends StatelessWidget {
  final LaborListController controller;
  const _AddLaborSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.w, right: 20.w, top: 16.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36.w, height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text('Add Worker', style: AppTextStyles.h2S),
          SizedBox(height: 16.h),
          _Field(ctrl: controller.nameCtrl,      label: 'Full Name',   hint: 'e.g. Bashir Ahmed'),
          SizedBox(height: 12.h),
          _Field(ctrl: controller.phoneCtrl,     label: 'Phone',       hint: '03XX-XXXXXXX', keyboardType: TextInputType.phone),
          SizedBox(height: 12.h),
          _RoleDropdown(controller: controller),
          SizedBox(height: 12.h),
          _Field(ctrl: controller.dailyWageCtrl, label: 'Daily Wage (PKR)', hint: 'e.g. 2500', keyboardType: TextInputType.number),
          SizedBox(height: 24.h),
          Obx(() => AppButton.primary(
            label: controller.isSaving.value ? 'Adding...' : 'Add Worker',
            isLoading: controller.isSaving.value,
            onPressed: controller.addLabor,
          )),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  const _Field({required this.ctrl, required this.label, required this.hint, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLargeS),
        SizedBox(height: 4.h),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

class _RoleDropdown extends StatelessWidget {
  final LaborListController controller;
  const _RoleDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Role / Trade', style: AppTextStyles.labelLargeS),
        SizedBox(height: 4.h),
        Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedRole.value,
              onChanged: (v) => controller.selectedRole.value = v ?? 'Mason',
              items: LaborModel.roles
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              decoration: const InputDecoration(),
            )),
      ],
    );
  }
}


