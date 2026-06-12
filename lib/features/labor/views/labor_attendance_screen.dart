import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/attendance_controller.dart';
import '../data/models/attendance_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../presentation/routes/app_routes.dart';

class LaborAttendanceScreen extends GetView<AttendanceController> {
  const LaborAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        // Fix 5: RepaintBoundary isolates the grid's repaints from the rest of
        // the Scaffold. The frozen-column layout keeps the worker-name column
        // pinned while the day-cells area scrolls horizontally.
        return RepaintBoundary(
          child: Column(
            children: [
              _WeekHeader(controller: controller),
              _SummaryRow(controller: controller),
              const Divider(height: 1),
              // Frozen header + scrollable day headers share one widget tree
              // F4: Bulk attendance action bar
              _BulkAttendanceBar(controller: controller),
              const Divider(height: 1),
              _FrozenGridHeader(controller: controller),
              const Divider(height: 1),
              Expanded(
                child: controller.laborList.isEmpty
                    ? const _EmptyLabor()
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: controller.laborList.length,
                        itemBuilder: (_, i) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _WorkerGridRow(
                              controller: controller,
                              laborIndex: i,
                            ),
                            Divider(
                              height: 1,
                              color: Theme.of(context).dividerColor,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
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
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;
    final bg      = Theme.of(context).scaffoldBackgroundColor;

    return Obx(() {
      final start  = controller.selectedWeekStart.value;
      final end    = controller.weekEnd;
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      final label = start.month == end.month
          ? '${start.day}–${end.day} ${months[start.month - 1]} ${start.year}'
          : '${start.day} ${months[start.month - 1]} – ${end.day} ${months[end.month - 1]}';

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: bg,
        child: Row(
          children: [
            Semantics(
              label: 'Previous week',
              button: true,
              child: GestureDetector(
                onTap: controller.prevWeek,
                child: Container(
                  width: 44, height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: divider),
                  ),
                  child: Icon(Icons.chevron_left_rounded,
                      size: 20, color: cs.onSurface),
                ),
              ),
            ),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.h4S.copyWith(color: cs.onSurface),
              ),
            ),
            Semantics(
              label: 'Next week',
              button: true,
              enabled: controller.canGoNext,
              child: GestureDetector(
                onTap: controller.canGoNext ? controller.nextWeek : null,
                child: Container(
                  width: 44, height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: controller.canGoNext ? surface : divider,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: divider),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: controller.canGoNext
                        ? cs.onSurface
                        : cs.onSurfaceVariant,
                  ),
                ),
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
    final cs = Theme.of(context).colorScheme;
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: cs.surface,
          child: Row(
            children: [
              _SummaryChip(
                  label: 'Workers',
                  value: '${controller.totalWorkers}',
                  color: cs.primary,
                  muted: cs.onSurfaceVariant),
              const SizedBox(width: 12),
              _SummaryChip(
                  label: 'Present today',
                  value: '${controller.presentToday}',
                  color: AppColors.success,
                  muted: cs.onSurfaceVariant),
              const Spacer(),
              Text(
                controller.formattedWeeklyTotal,
                style: AppTextStyles.h3S.copyWith(color: cs.primary),
              ),
              const SizedBox(width: 4),
              Text('week',
                  style: AppTextStyles.labelSmallS
                      .copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ));
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color muted;
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text('$value $label',
              style: AppTextStyles.labelSmallS.copyWith(color: muted)),
        ],
      );
}

// ── F4: Bulk attendance action bar ───────────────────────────────────────────

class _BulkAttendanceBar extends StatelessWidget {
  final AttendanceController controller;
  const _BulkAttendanceBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Text("Today's bulk action:",
              style: AppTextStyles.labelSmallS
                  .copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () {
              controller.markAllPresent();
              Get.snackbar(
                'Done',
                'All workers marked present for today',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 2),
                backgroundColor: AppColors.success.withValues(alpha: 0.9),
                colorText: Colors.white,
                icon: const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 18),
              );
            },
            icon: const Icon(Icons.people_rounded, size: 14),
            label: const Text('Mark All Present'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              textStyle: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 6),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded,
                size: 18, color: cs.onSurfaceVariant),
            tooltip: 'More options',
            padding: EdgeInsets.zero,
            onSelected: (val) {
              if (val == 'absent') {
                controller.markAllAbsent();
                Get.snackbar(
                  'Done',
                  'All workers marked absent for today',
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 2),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'absent',
                child: Row(children: [
                  Icon(Icons.person_off_rounded, size: 16),
                  SizedBox(width: 8),
                  Text('Mark All Absent'),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Frozen day-header row (Fix 5) ─────────────────────────────────────────────
// Mirrors the exact column layout of _WorkerGridRow so headers stay aligned.

class _FrozenGridHeader extends StatelessWidget {
  final AttendanceController controller;
  const _FrozenGridHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SizedBox(width: 120),
          ...AttendanceController.dayHeaders.map(
            (d) => Expanded(
              child: Text(
                d,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSmallS
                    .copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ),
          // PK7: Friday "Off" column — visual indicator, not a working day
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Fri',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelSmallS.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.4))),
                Text('Off',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.8))),
              ],
            ),
          ),
          SizedBox(
            width: 60,
            child: Text('Wage',
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSmallS
                    .copyWith(color: cs.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}

// ── Worker row ────────────────────────────────────────────────────────────────

class _WorkerGridRow extends StatelessWidget {
  final AttendanceController controller;
  final int laborIndex;
  const _WorkerGridRow(
      {required this.controller, required this.laborIndex});

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final labor = controller.laborList[laborIndex];

    return Obx(() {
      double effectiveDays = 0;
      double otHours = 0;
      for (final day in controller.weekDays) {
        final rec = controller.getRecord(labor.id, day);
        effectiveDays += rec.effectiveDays;
        otHours += rec.overtimeHours;
      }
      final wage = labor.dailyWage * effectiveDays +
          labor.effectiveOvertimeRate * otHours;

      // Fix 2: Row height ≥ 52 ensures each cell tap target is at least 44dp tall.
      // Expanded cells fill the available width (≥ 44dp on standard screens).
      return Container(
        color: cs.surface,
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
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
                      style: AppTextStyles.labelLargeS
                          .copyWith(color: cs.onSurface),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      labor.role,
                      style: AppTextStyles.labelSmallS
                          .copyWith(color: cs.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            ...controller.weekDays.map((day) {
              final rec = controller.getRecord(labor.id, day);
              return Expanded(
                child: Semantics(
                  label: '${AttendanceController.dayHeaders[controller.weekDays.indexOf(day)]}: ${rec.status.name}',
                  button: true,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      controller.cycleStatus(labor.id, day);
                    },
                    onLongPress: () {
                      if (rec.status == AttendanceStatus.overtime) {
                        _showOtHoursDialog(context, controller, labor.id, day, rec.overtimeHours);
                      }
                    },
                    // ConstrainedBox guarantees a 44×44 minimum touch target
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                          minWidth: 44, minHeight: 44),
                      child: Center(
                        child: _StatusCell(
                          status: rec.status,
                          otHours: rec.overtimeHours,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
            // PK7: Friday Off cell — greyed out, non-interactive
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Off',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.7))),
              ),
            ),
            SizedBox(
              width: 60,
              // PK4: show PKR symbol in wage column
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  CurrencyFormatter.formatPKR(wage),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSmallS.copyWith(
                      color: cs.primary, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── OT hours dialog ───────────────────────────────────────────────────────────

void _showOtHoursDialog(
  BuildContext context,
  AttendanceController controller,
  String laborId,
  DateTime date,
  double currentHours,
) {
  final ctrl = TextEditingController(text: currentHours.toStringAsFixed(0));
  final errorObs = RxnString();

  showDialog<void>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: const Text('Set Overtime Hours'),
      content: Obx(() {
        final err = errorObs.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Hours (max 12)',
                suffixText: 'hrs',
                border: const OutlineInputBorder(),
                errorText: err,
              ),
              onChanged: (_) => errorObs.value = null,
            ),
            const SizedBox(height: 8),
            Text('Long-press any OT cell to edit hours.',
                style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(dialogCtx).colorScheme.onSurfaceVariant)),
          ],
        );
      }),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogCtx).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final val = double.tryParse(ctrl.text.trim());
            if (val == null || val < 0) {
              errorObs.value = 'Please enter a valid number';
              return;
            }
            if (val > AttendanceController.kMaxOvertimeHoursPerDay) {
              errorObs.value = 'Overtime cannot exceed 12 hours per day';
              return;
            }
            controller.setOvertimeHours(laborId, date, val);
            Navigator.of(dialogCtx).pop();
          },
          child: const Text('Set'),
        ),
      ],
    ),
  );
}

// ── Status cell — semantic colors stay fixed regardless of theme ──────────────

class _StatusCell extends StatelessWidget {
  final AttendanceStatus status;
  final double otHours;
  const _StatusCell({required this.status, this.otHours = 0});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      AttendanceStatus.present  => ('P',  const Color(0xFFDCFCE7), AppColors.success),
      AttendanceStatus.absent   => ('A',  const Color(0xFFFEE2E2), AppColors.error),
      AttendanceStatus.halfDay  => ('½',  const Color(0xFFFEF3C7), AppColors.warning),
      AttendanceStatus.overtime => (
          otHours > 0 ? '${otHours.toStringAsFixed(0)}h' : 'OT',
          const Color(0xFFEDE9FE),
          const Color(0xFF7C3AED),
        ),
      AttendanceStatus.leave    => ('L',  Theme.of(context).dividerColor,
                                          Theme.of(context).colorScheme.onSurfaceVariant),
    };

    return Container(
      width: 30, height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: TextStyle(
              fontSize: status == AttendanceStatus.overtime && otHours > 0 ? 8 : 10,
              fontWeight: FontWeight.w700,
              color: fg)),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyLabor extends StatelessWidget {
  const _EmptyLabor();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 48, color: cs.onSurfaceVariant),
          const SizedBox(height: 12),
          Text('No workers added yet',
              style:
                  AppTextStyles.h4S.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 6),
          Text('Go to Workers tab to add site workers',
              style: AppTextStyles.bodySmallS
                  .copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Get.toNamed(AppRoutes.laborList),
            child: const Text('Add Workers →'),
          ),
        ],
      ),
    );
  }
}

// ── Bottom bar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final AttendanceController controller;
  const _BottomBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: divider)),
      ),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Weekly Total',
                        style: AppTextStyles.labelSmallS
                            .copyWith(color: cs.onSurfaceVariant)),
                    Text(
                      controller.formattedWeeklyTotal,
                      style: AppTextStyles.h3S.copyWith(color: cs.primary),
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
