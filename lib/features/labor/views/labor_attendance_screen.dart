import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/labor_controller.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../presentation/widgets/common/app_card.dart';

class LaborAttendanceScreen extends GetView<LaborController> {
  const LaborAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weekDays = List.generate(7, (i) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      return date;
    });

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            '${labor_attendance.tr} ${DateFormat('EEE, dd MMM').format(controller.selectedDate.value)}',
          ),
        ),
      ),
      body: Column(
        children: [
          // Week date picker
          Obx(
            () => Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePaddingH),
              child: Row(
                children: weekDays.map((date) {
                  final isSelected = date.day == controller.selectedDate.value.day &&
                      date.month == controller.selectedDate.value.month;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.selectedDate.value = date,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('E').format(date)[0],
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Divider(height: 1, color: AppColors.dividerLight),

          // Stats
          Obx(
            () => Padding(
              padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
              child: AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${controller.presentCount}',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.success),
                          ),
                          Text('present'.tr, style: AppTextStyles.caption(context)),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppColors.dividerLight),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${controller.absentCount}',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.error),
                          ),
                          Text('absent'.tr, style: AppTextStyles.caption(context)),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppColors.dividerLight),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${controller.workers.length}',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight),
                          ),
                          Text('total'.tr, style: AppTextStyles.caption(context)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Workers list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePaddingH),
            child: Row(
              children: [
                Expanded(child: Text('todays_workers'.tr, style: AppTextStyles.h3(context))),
                Obx(() => Text(
                  '${controller.workers.length} total',
                  style: AppTextStyles.caption(context),
                )),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.sm),

          Expanded(
            child: Obx(
              () => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePaddingH),
                itemCount: controller.workers.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.dividerLight),
                itemBuilder: (_, i) => _WorkerRow(
                  worker: controller.workers[i],
                  onToggle: () => controller.toggleAttendance(controller.workers[i].id),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.dividerLight)),
        ),
        child: Obx(
          () => AppButton(
            label: 'submit_attendance'.tr,
            isLoading: controller.isSubmitting.value,
            onPressed: controller.submitAttendance,
          ),
        ),
      ),
    );
  }
}

// ignore: non_constant_identifier_names
String get labor_attendance => 'labor_attendance';

class _WorkerRow extends StatelessWidget {
  final WorkerAttendance worker;
  final VoidCallback onToggle;

  const _WorkerRow({required this.worker, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: worker.isPresent ? AppColors.primary : AppColors.dividerLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                worker.initials,
                style: TextStyle(
                  color: worker.isPresent ? Colors.white : AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(worker.name, style: AppTextStyles.labelLarge(context)),
                Text(worker.role, style: AppTextStyles.caption(context)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Switch(
                value: worker.isPresent,
                onChanged: (_) => onToggle(),
                activeColor: AppColors.primary,
              ),
              if (worker.checkInTime != null)
                Text(
                  worker.checkInTime!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                )
              else
                Text('Absent', style: AppTextStyles.caption(context)),
            ],
          ),
        ],
      ),
    );
  }
}
