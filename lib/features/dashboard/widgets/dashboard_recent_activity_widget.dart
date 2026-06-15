import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/dashboard_controller.dart';
import '../../projects/data/models/project_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../presentation/routes/app_routes.dart';
import '../../shell/controllers/shell_controller.dart';

const _kError   = Color(0xFFDC2626);
const _kWarning = Color(0xFFF59E0B);
const _kSuccess = Color(0xFF16A34A);
const _kInfo    = Color(0xFF3B82F6);

// Premium accent palette — rotates by project index.
// Each accent drives the card gradient, left border, icon, and progress bar.
const _kCardAccents = [
  Color(0xFF3B82F6), // Blue
  Color(0xFF0D9488), // Teal
  Color(0xFFD97706), // Amber / Sand
  Color(0xFF6366F1), // Indigo / Slate
  Color(0xFF16A34A), // Green
  Color(0xFF0EA5E9), // Sky / Grey-Blue
];

Color _primaryText(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Theme.of(context).colorScheme.primary;

// Switch to the Projects tab (index 1) without pushing a new route.
void _goToProjectsTab() {
  if (Get.isRegistered<ShellController>()) {
    Get.find<ShellController>().changeTab(1);
  }
}

/// Upcoming tasks, budget alerts, and recent projects list.
class DashboardRecentActivityWidget extends StatelessWidget {
  final DashboardController controller;
  const DashboardRecentActivityWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upcoming Tasks section removed — task functionality now lives in
        // the Today's Alert card and the dedicated Tasks page (/tasks).
        // Preserved for future reference (see commented classes below).
        // if (controller.upcomingTasks.isNotEmpty) ...[
        //   _UpcomingTasksSection(controller: controller),
        //   const SizedBox(height: 20),
        // ],
        // Budget Insights section removed from the dashboard.
        // Feature temporarily disabled — preserved for future implementation
        // (see the commented-out _BudgetAlertsSection below).
        // if (controller.budgetAlerts.isNotEmpty) ...[
        //   _BudgetAlertsSection(controller: controller),
        //   const SizedBox(height: 20),
        // ],
        if (controller.activeProjects.isNotEmpty)
          _RecentProjectsSection(controller: controller),
      ],
    );
  }
}

// ── Upcoming tasks ────────────────────────────────────────────────────────────
// Feature moved. Task functionality now lives in the Today's Alert card and
// the dedicated Tasks page (lib/features/tasks/). These widgets are preserved
// for future reference. DashboardController.upcomingTasks is untouched.

/*
class _UpcomingTasksSection extends StatelessWidget {
  final DashboardController controller;
  const _UpcomingTasksSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text('Upcoming Tasks',
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface)),
                  const SizedBox(width: 6),
                  if (controller.overdueTaskCount > 0)
                    _OverduePill(count: controller.overdueTaskCount),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...controller.upcomingTasks.map((t) => _TaskCard(task: t)),
      ],
    );
  }
}

class _OverduePill extends StatelessWidget {
  final int count;
  const _OverduePill({required this.count});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: _kError,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('$count overdue',
            style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      );
}

class _TaskCard extends StatelessWidget {
  final UpcomingTask task;
  const _TaskCard({required this.task});

  Color get _priorityColor => task.isOverdue
      ? _kError
      : switch (task.priority) {
          'high'   => _kError,
          'medium' => _kWarning,
          _        => _kInfo,
        };

  String get _priorityLabel => task.isOverdue
      ? 'OVERDUE'
      : task.priority.toUpperCase();

  IconData get _taskIcon => switch (task.stageName.toLowerCase()) {
        String s when s.contains('foundation') => Icons.foundation_rounded,
        String s when s.contains('gray') || s.contains('structure') =>
          Icons.apartment_rounded,
        String s when s.contains('plaster') => Icons.layers_rounded,
        String s when s.contains('finish')  => Icons.home_rounded,
        String s when s.contains('payroll') => Icons.payments_rounded,
        String s when s.contains('photo')   => Icons.photo_camera_rounded,
        _                                   => Icons.task_alt_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final now     = DateTime.now();
    final daysLeft = task.dueDate.difference(now).inDays;
    final timeLabel = task.isOverdue
        ? '${(-daysLeft)} day${(-daysLeft) == 1 ? '' : 's'} overdue'
        : daysLeft == 0
            ? 'Due today'
            : 'Due in $daysLeft day${daysLeft == 1 ? '' : 's'}';

    final priorityColor = _priorityColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: priorityColor, width: 3.5),
        ),
        boxShadow: [
          BoxShadow(
              color: cs.onSurface.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Get.toNamed(AppRoutes.myProjects),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Row(
              children: [
                // Task type icon
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_taskIcon, size: 18, color: priorityColor),
                ),
                const SizedBox(width: 12),

                // Task details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(task.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface)),
                          ),
                          const SizedBox(width: 8),
                          // Priority badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: priorityColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(_priorityLabel,
                                style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: priorityColor,
                                    letterSpacing: 0.4)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.folder_outlined,
                              size: 10, color: cs.onSurfaceVariant),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${task.projectName}  ·  ${task.stageName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  color: cs.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Due date
                      Row(
                        children: [
                          Icon(
                            task.isOverdue
                                ? Icons.warning_amber_rounded
                                : Icons.schedule_rounded,
                            size: 11,
                            color: task.isOverdue
                                ? _kError
                                : cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 3),
                          Text(timeLabel,
                              style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                  color: task.isOverdue
                                      ? _kError
                                      : cs.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/

// ── Budget alerts ─────────────────────────────────────────────────────────────
// Feature temporarily disabled. Budget Insights section preserved for future
// implementation. The DashboardController.budgetAlerts logic is untouched.
// To reactivate: uncomment these classes and the usage in the build() above.

/*
class _BudgetAlertsSection extends StatelessWidget {
  final DashboardController controller;
  const _BudgetAlertsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Budget Insights',
            style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: cs.onSurface)),
        const SizedBox(height: 10),
        ...controller.budgetAlerts.map((a) => _BudgetAlertCard(alert: a)),
      ],
    );
  }
}

class _BudgetAlertCard extends StatelessWidget {
  final BudgetAlert alert;
  const _BudgetAlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final cs        = Theme.of(context).colorScheme;
    final isWarning = alert.severity == 'warning';
    final barColor  = isWarning ? _kWarning : _kInfo;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: barColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: barColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isWarning
                      ? Icons.warning_amber_rounded
                      : Icons.trending_up_rounded,
                  size: 16, color: barColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(alert.projectName,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface)),
              ),
              Text('${(alert.budgetPct * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: barColor)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: alert.budgetPct,
              minHeight: 5,
              backgroundColor: barColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 7),
          Text(alert.message,
              style: GoogleFonts.inter(
                  fontSize: 11, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}
*/

// ── Recent projects (latest 3) ────────────────────────────────────────────────

class _RecentProjectsSection extends StatelessWidget {
  final DashboardController controller;
  const _RecentProjectsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final projects = controller.activeProjects.take(3).toList();
    final total    = controller.activeProjects.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('My Projects',
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('$total',
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: cs.primary)),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _goToProjectsTab,
              child: Row(
                children: [
                  Text('View All',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _primaryText(context))),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 10, color: _primaryText(context)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...projects.asMap().entries.map(
              (e) => _ProjectCard(project: e.value, index: e.key),
            ),
        if (total > 3) ...[
          const SizedBox(height: 4),
          _ViewAllProjectsBanner(remaining: total - 3),
        ],
      ],
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final ProjectModel project;
  final int index;
  const _ProjectCard({required this.project, required this.index});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _pressed = false;

  Color _statusColor(String status) => switch (status) {
        'active'    => _kInfo,
        'completed' => _kSuccess,
        'on_hold'   => _kWarning,
        _           => _kInfo,
      };

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final accent  = _kCardAccents[widget.index % _kCardAccents.length];
    final statusColor = _statusColor(widget.project.status);

    // Subtle tinted gradient — very low opacity to stay premium, not loud
    final gradientStart = isDark
        ? Color.lerp(cs.surface, accent, 0.10)!
        : Color.lerp(Colors.white, accent, 0.07)!;
    final gradientEnd = isDark
        ? Color.lerp(cs.surface, accent, 0.04)!
        : Color.lerp(Colors.white, accent, 0.02)!;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Get.toNamed(AppRoutes.projectStageTracker, arguments: widget.project);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gradientStart, gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            // Uniform border required when borderRadius is set
            border: Border.all(
              color: accent.withValues(alpha: isDark ? 0.18 : 0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: isDark ? 0.14 : 0.09),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Project icon tinted with card accent
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: accent.withValues(
                                  alpha: isDark ? 0.20 : 0.11),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.home_work_rounded,
                                size: 20, color: accent),
                          ),
                          const SizedBox(width: 12),

                          // Name + location
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.project.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: cs.onSurface)),
                                const SizedBox(height: 1),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined,
                                        size: 10,
                                        color: cs.onSurfaceVariant),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Text(
                                        '${widget.project.area}, ${widget.project.city}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                            fontSize: 10.5,
                                            color: cs.onSurfaceVariant),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(widget.project.statusLabel,
                                style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Progress row — bar uses card accent color
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('Progress',
                                        style: GoogleFonts.inter(
                                            fontSize: 10,
                                            color: cs.onSurfaceVariant)),
                                    const Spacer(),
                                    Text(
                                      '${widget.project.completionPct.toStringAsFixed(0)}%',
                                      style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: accent),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: LinearProgressIndicator(
                                    value: widget.project.progress,
                                    minHeight: 5,
                                    backgroundColor: accent.withValues(
                                        alpha: isDark ? 0.20 : 0.12),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        accent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Budget + stage + time left
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.account_balance_wallet_outlined,
                            label: CurrencyFormatter.formatPKR(
                                widget.project.budgetAmount),
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.construction_rounded,
                            label: widget.project.currentStage,
                            color: cs.onSurfaceVariant,
                          ),
                          const Spacer(),
                          Text('${widget.project.weeksLeft}w left',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: widget.project.isLate
                                      ? _kError
                                      : cs.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Left accent strip — separate element avoids non-uniform
                // border colors which are forbidden with borderRadius
                Positioned(
                  left: 0, top: 0, bottom: 0,
                  child: Container(
                    width: 3.5,
                    decoration: BoxDecoration(
                      color: accent.withValues(
                          alpha: isDark ? 0.65 : 0.50),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: GoogleFonts.inter(fontSize: 10.5, color: color)),
        ],
      );
}

class _ViewAllProjectsBanner extends StatelessWidget {
  final int remaining;
  const _ViewAllProjectsBanner({required this.remaining});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: _goToProjectsTab,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: cs.primary.withValues(alpha: 0.15), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_view_rounded, size: 14, color: cs.primary),
            const SizedBox(width: 7),
            Text(
              '+$remaining more project${remaining == 1 ? '' : 's'} — View All',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.primary),
            ),
          ],
        ),
      ),
    );
  }
}
