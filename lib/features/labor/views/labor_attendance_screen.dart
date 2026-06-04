import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/attendance_controller.dart';
import '../data/models/attendance_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../presentation/routes/app_routes.dart';

class LaborAttendanceScreen extends GetView<AttendanceController> {
  const LaborAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          TextButton(
            onPressed: () => Get.toNamed(AppRoutes.payroll),
            child: const Text('Payroll →'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            // ── Week navigator ──────────────────────────────────────────────
            _WeekHeader(controller: controller),
            // ── Summary row ─────────────────────────────────────────────────
            _SummaryRow(controller: controller),
            const Divider(height: 1),
            // ── Grid header: day labels ──────────────────────────────────────
            _GridDayHeader(controller: controller),
            const Divider(height: 1),
            // ── Worker rows ──────────────────────────────────────────────────
            Expanded(
              child: controller.laborList.isEmpty
                  ? _EmptyLabor()
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: controller.laborList.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Color(0xFFF0F2F5)),
                      itemBuilder: (_, i) => _WorkerGridRow(
                        controller: controller,
                        laborIndex: i,
                      ),
                    ),
            ),
          ],
        );
      }),
      bottomNavigationBar: _BottomBar(controller: controller),
    );
  }
}

// ── Week navigator ────────────────────────────────────────────────────────────

class _WeekHeader extends StatelessWidget {
  final AttendanceController controller;
  const _WeekHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final start = controller.selectedWeekStart.value;
      final end   = controller.weekEnd;
      final months = ['Jan','Feb','Mar','Apr','May','Jun',
                      'Jul','Aug','Sep','Oct','Nov','Dec'];
      String label;
      if (start.month == end.month) {
        label = '${start.day}–${end.day} ${months[start.month - 1]} ${start.year}';
      } else {
        label = '${start.day} ${months[start.month - 1]} – ${end.day} ${months[end.month - 1]}';
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: const Color(0xFFF8F9FC),
        child: Row(
          children: [
            GestureDetector(
              onTap: controller.prevWeek,
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: const Icon(Icons.chevron_left_rounded, size: 20),
              ),
            ),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.h4S.copyWith(color: AppColors.textPrimaryLight),
              ),
            ),
            GestureDetector(
              onTap: controller.canGoNext ? controller.nextWeek : null,
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: controller.canGoNext ? Colors.white : const Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Icon(Icons.chevron_right_rounded, size: 20,
                    color: controller.canGoNext
                        ? AppColors.textPrimaryLight
                        : AppColors.textTertiaryLight),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Summary row ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final AttendanceController controller;
  const _SummaryRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              _SummaryChip(
                  label: 'Workers',
                  value: '${controller.totalWorkers}',
                  color: AppColors.primary),
              const SizedBox(width: 12),
              _SummaryChip(
                  label: 'Present today',
                  value: '${controller.presentToday}',
                  color: AppColors.success),
              const Spacer(),
              Text(
                controller.formattedWeeklyTotal,
                style: AppTextStyles.h3S.copyWith(color: AppColors.primary),
              ),
              const SizedBox(width: 4),
              Text('week',
                  style: AppTextStyles.labelSmallS
                      .copyWith(color: AppColors.textSecondaryLight)),
            ],
          ),
        ));
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text('$value $label',
              style: AppTextStyles.labelSmallS
                  .copyWith(color: AppColors.textSecondaryLight)),
        ],
      );
}

// ── Day header row ────────────────────────────────────────────────────────────

class _GridDayHeader extends StatelessWidget {
  final AttendanceController controller;
  const _GridDayHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FC),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SizedBox(width: 120), // worker name column
          ...AttendanceController.dayHeaders
              .map((d) => Expanded(
                    child: Text(d,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelSmallS
                            .copyWith(color: AppColors.textSecondaryLight)),
                  ))
              .toList(),
          const SizedBox(width: 60), // wage column
        ],
      ),
    );
  }
}

// ── Worker row (one row per worker, 6 day cells) ──────────────────────────────

class _WorkerGridRow extends StatelessWidget {
  final AttendanceController controller;
  final int laborIndex;
  const _WorkerGridRow({required this.controller, required this.laborIndex});

  @override
  Widget build(BuildContext context) {
    final labor = controller.laborList[laborIndex];

    return Obx(() {
      // Calculate weekly wage for this worker
      double effectiveDays = 0;
      double otHours = 0;
      for (final day in controller.weekDays) {
        final rec = controller.getRecord(labor.id, day);
        effectiveDays += rec.effectiveDays;
        otHours += rec.overtimeHours;
      }
      final wage = labor.dailyWage * effectiveDays +
          labor.effectiveOvertimeRate * otHours;

      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Worker name + role
            SizedBox(
              width: 120,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      labor.fullName.split(' ').first,
                      style: AppTextStyles.labelLargeS,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      labor.role,
                      style: AppTextStyles.labelSmallS.copyWith(
                          color: AppColors.textSecondaryLight),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            // 6 day cells
            ...controller.weekDays.map((day) {
              final rec = controller.getRecord(labor.id, day);
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controller.cycleStatus(labor.id, day);
                  },
                  child: Center(
                    child: _StatusCell(status: rec.status),
                  ),
                ),
              );
            }).toList(),
            // Weekly wage
            SizedBox(
              width: 60,
              child: Text(
                CurrencyFormatter.formatNumberCompact(wage),
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSmallS.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Status cell ───────────────────────────────────────────────────────────────

class _StatusCell extends StatelessWidget {
  final AttendanceStatus status;
  const _StatusCell({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      AttendanceStatus.present  => ('P',  const Color(0xFFDCFCE7), AppColors.success),
      AttendanceStatus.absent   => ('A',  const Color(0xFFFEE2E2), AppColors.error),
      AttendanceStatus.halfDay  => ('½',  const Color(0xFFFEF3C7), AppColors.warning),
      AttendanceStatus.overtime => ('OT', const Color(0xFFEDE9FE), const Color(0xFF7C3AED)),
      AttendanceStatus.leave    => ('L',  const Color(0xFFF3F4F6), AppColors.textSecondaryLight),
    };

    return Container(
      width: 30, height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyLabor extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline, size: 48, color: AppColors.textTertiaryLight),
            const SizedBox(height: 12),
            Text('No workers added yet',
                style: AppTextStyles.h4S.copyWith(
                    color: AppColors.textSecondaryLight)),
            const SizedBox(height: 6),
            Text('Go to Workers tab to add site workers',
                style: AppTextStyles.bodySmallS.copyWith(
                    color: AppColors.textTertiaryLight)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.laborList),
              child: const Text('Add Workers →'),
            ),
          ],
        ),
      );
}

// ── Bottom bar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final AttendanceController controller;
  const _BottomBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Weekly Total',
                        style: AppTextStyles.labelSmallS.copyWith(
                            color: AppColors.textSecondaryLight)),
                    Text(
                      controller.formattedWeeklyTotal,
                      style: AppTextStyles.h3S
                          .copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: AppButton.primary(
                  label: controller.isSubmitting.value
                      ? 'Saving...'
                      : 'Save Attendance',
                  isLoading: controller.isSubmitting.value,
                  onPressed: controller.submitAttendance,
                ),
              ),
            ],
          )),
    );
  }
}
