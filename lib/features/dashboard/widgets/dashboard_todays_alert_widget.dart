import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../tasks/controllers/tasks_controller.dart';
import '../../tasks/views/tasks_screen.dart'
    show taskTypeIcon, taskTypeColor, taskPriorityColor, taskDueLabel;
import '../../../presentation/routes/app_routes.dart';

/// "Today's Alert" — compact card shown directly below the dashboard header.
///
/// Shows only the most important / nearest upcoming item for today (plus a
/// "+X more" pill when more are scheduled). Tapping navigates to the Tasks
/// hub. Hidden entirely when nothing is due today.
class DashboardTodaysAlertWidget extends StatelessWidget {
  const DashboardTodaysAlertWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<TasksController>()) return const SizedBox.shrink();
    final ctrl = Get.find<TasksController>();
    final cs   = Theme.of(context).colorScheme;

    return Obx(() {
      final alert = ctrl.topTodayAlert;
      if (alert == null) return const SizedBox.shrink();

      final more      = ctrl.moreTodayCount;
      final typeColor = taskTypeColor(alert.type);
      final prColor   = taskPriorityColor(alert.priority);

      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) => Opacity(
          opacity: t,
          child:
              Transform.translate(offset: Offset(0, 10 * (1 - t)), child: child),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Semantics(
            label: "Today's alert: ${alert.title}",
            button: true,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Get.toNamed(AppRoutes.tasks);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: prColor.withValues(alpha: 0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: prColor.withValues(alpha: 0.10),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Pulsing type icon
                    _PulsingIcon(color: typeColor, icon: taskTypeIcon(alert.type)),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Eyebrow + status badge
                          Row(
                            children: [
                              Text("TODAY'S ALERT",
                                  style: GoogleFonts.inter(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      color: prColor)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: prColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                    alert.isOverdue
                                        ? 'OVERDUE'
                                        : alert.priority.toUpperCase(),
                                    style: GoogleFonts.inter(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w800,
                                        color: prColor)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(alert.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface)),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded,
                                  size: 10.5, color: cs.onSurfaceVariant),
                              const SizedBox(width: 3),
                              Text(taskDueLabel(alert),
                                  style: GoogleFonts.inter(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurfaceVariant)),
                              const SizedBox(width: 8),
                              Text('· ${alert.typeLabel}',
                                  style: GoogleFonts.inter(
                                      fontSize: 10.5,
                                      color: cs.onSurfaceVariant)),
                              if (alert.projectName != null) ...[
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text('· ${alert.projectName}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                          fontSize: 10.5,
                                          color: cs.onSurfaceVariant)),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // "+X more" pill / chevron
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (more > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('+$more more',
                                style: GoogleFonts.inter(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: cs.primary)),
                          ),
                        const SizedBox(height: 6),
                        Icon(Icons.chevron_right_rounded,
                            size: 18, color: cs.onSurfaceVariant),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// Icon chip with a soft repeating pulse to draw attention without noise.
class _PulsingIcon extends StatefulWidget {
  final Color color;
  final IconData icon;
  const _PulsingIcon({required this.color, required this.icon});

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_ctrl.value);
        return Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.10 + 0.06 * t),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: widget.color.withValues(alpha: 0.25 + 0.20 * t)),
          ),
          child: child,
        );
      },
      child: Icon(widget.icon, size: 20, color: widget.color),
    );
  }
}
