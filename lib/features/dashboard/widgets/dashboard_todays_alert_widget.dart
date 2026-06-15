import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../tasks/controllers/tasks_controller.dart';
import '../../tasks/views/tasks_screen.dart'
    show taskTypeIcon, taskTypeColor, taskPriorityColor, taskDueLabel;
import '../../../presentation/routes/app_routes.dart';

// Alert palette — warm red / rose tones for urgency without aggression
const _kAlertRed    = Color(0xFFEF4444);
const _kAlertRose   = Color(0xFFFB7185);
const _kAlertAmber  = Color(0xFFF59E0B);

/// Compact alert banner shown directly below the dashboard header.
/// Slim, red-tinted, immediately distinguishable from all other dashboard cards.
class DashboardTodaysAlertWidget extends StatelessWidget {
  const DashboardTodaysAlertWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<TasksController>()) return const SizedBox.shrink();
    final ctrl = Get.find<TasksController>();

    return Obx(() {
      final alert = ctrl.topTodayAlert;
      if (alert == null) return const SizedBox.shrink();

      final more     = ctrl.moreTodayCount;
      final isDark   = Theme.of(context).brightness == Brightness.dark;
      final cs       = Theme.of(context).colorScheme;
      final isOverdue = alert.isOverdue;

      // Overdue → red; high-priority today → rose-red; else → amber
      final accentColor = isOverdue
          ? _kAlertRed
          : alert.priority == 'high'
              ? _kAlertRose
              : _kAlertAmber;

      final typeColor = taskTypeColor(alert.type);

      // Gradient: alert-tinted surface — soft enough to be readable
      final bgStart = isDark
          ? Color.lerp(cs.surface, accentColor, 0.18)!
          : Color.lerp(const Color(0xFFFFF5F5), accentColor, 0.08)!;
      final bgEnd = isDark
          ? Color.lerp(cs.surface, accentColor, 0.08)!
          : Color.lerp(Colors.white, accentColor, 0.04)!;

      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) => Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, 8 * (1 - t)), child: child),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Semantics(
            label: "Today's alert: ${alert.title}",
            button: true,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Get.toNamed(AppRoutes.tasks);
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [bgStart, bgEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  // Uniform border + left accent via Stack
                  border: Border.all(
                    color: accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: isDark ? 0.20 : 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Stack(
                    children: [
                      // ── Content ──────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 9, 10, 9),
                        child: Row(
                          children: [
                            // Alert icon — compact pulsing chip
                            _AlertIcon(
                              color: accentColor,
                              typeColor: typeColor,
                              icon: taskTypeIcon(alert.type),
                              isOverdue: isOverdue,
                            ),
                            const SizedBox(width: 10),

                            // Title + metadata
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Eyebrow row
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: accentColor
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          isOverdue
                                              ? '⚠ OVERDUE'
                                              : '🔔 TODAY\'S ALERT',
                                          style: GoogleFonts.inter(
                                            fontSize: 8,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                            color: accentColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      // Priority dot
                                      Container(
                                        width: 5, height: 5,
                                        decoration: BoxDecoration(
                                          color: taskPriorityColor(
                                              alert.priority),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        alert.priority.toUpperCase(),
                                        style: GoogleFonts.inter(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w700,
                                          color: taskPriorityColor(
                                              alert.priority),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),

                                  // Alert title
                                  Text(
                                    alert.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: cs.onSurface,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),

                                  // Time + type inline
                                  Row(
                                    children: [
                                      Icon(Icons.schedule_rounded,
                                          size: 9.5,
                                          color: accentColor
                                              .withValues(alpha: 0.80)),
                                      const SizedBox(width: 3),
                                      Text(
                                        taskDueLabel(alert),
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: accentColor
                                              .withValues(alpha: 0.85),
                                        ),
                                      ),
                                      Text(
                                        '  ·  ${alert.typeLabel}',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),

                            // Right side: "+X more" + chevron
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (more > 0) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: accentColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '+$more',
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: accentColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 16,
                                  color: accentColor.withValues(alpha: 0.70),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Left accent strip
                      Positioned(
                        left: 0, top: 0, bottom: 0,
                        child: Container(
                          width: 3,
                          color: accentColor.withValues(
                              alpha: isDark ? 0.80 : 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// Compact icon chip — subtle pulse to draw attention.
class _AlertIcon extends StatefulWidget {
  final Color color;
  final Color typeColor;
  final IconData icon;
  final bool isOverdue;
  const _AlertIcon({
    required this.color,
    required this.typeColor,
    required this.icon,
    required this.isOverdue,
  });

  @override
  State<_AlertIcon> createState() => _AlertIconState();
}

class _AlertIconState extends State<_AlertIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
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
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.12 + 0.08 * t),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.30 + 0.20 * t),
              width: 1,
            ),
          ),
          child: child,
        );
      },
      child: Icon(widget.icon, size: 17, color: widget.color),
    );
  }
}
