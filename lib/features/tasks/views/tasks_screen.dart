import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/tasks_controller.dart';
import '../data/models/task_model.dart';
import '../../../presentation/routes/app_routes.dart';

const _kError   = Color(0xFFDC2626);
const _kWarning = Color(0xFFF59E0B);
const _kSuccess = Color(0xFF16A34A);
const _kInfo    = Color(0xFF3B82F6);
const _kTeal    = Color(0xFF0D9488);
const _kPurple  = Color(0xFF7C3AED);

// ── Type → visual mapping ─────────────────────────────────────────────────────

IconData taskTypeIcon(String type) => switch (type) {
      'meeting'    => Icons.groups_rounded,
      'site_visit' => Icons.location_on_rounded,
      'alert'      => Icons.notifications_active_rounded,
      'reminder'   => Icons.alarm_rounded,
      'approval'   => Icons.fact_check_rounded,
      'deadline'   => Icons.timer_rounded,
      'follow_up'  => Icons.reply_rounded,
      _            => Icons.task_alt_rounded,
    };

Color taskTypeColor(String type) => switch (type) {
      'meeting'    => _kTeal,
      'site_visit' => _kInfo,
      'alert'      => _kWarning,
      'reminder'   => _kWarning,
      'approval'   => _kPurple,
      'deadline'   => _kError,
      'follow_up'  => _kTeal,
      _            => _kInfo,
    };

Color taskPriorityColor(String priority) => switch (priority) {
      'high'   => _kError,
      'medium' => _kWarning,
      _        => _kInfo,
    };

/// "Today, 3:00 PM" / "Tomorrow, 11:00 AM" / "Mon, 15 Jun" / "2 days overdue".
String taskDueLabel(TaskModel task) {
  final now = DateTime.now();
  if (task.isOverdue) {
    final days = now.difference(task.dueDate).inDays;
    if (days < 1) return 'Overdue today';
    return '$days day${days == 1 ? '' : 's'} overdue';
  }
  final today    = DateTime(now.year, now.month, now.day);
  final dueDay   = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
  final time     = _formatTime(task.dueDate);
  if (dueDay == today) return 'Today, $time';
  if (dueDay == today.add(const Duration(days: 1))) return 'Tomorrow, $time';
  const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const mo = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${wd[task.dueDate.weekday - 1]}, ${task.dueDate.day} ${mo[task.dueDate.month - 1]}';
}

String _formatTime(DateTime d) {
  final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m   = d.minute.toString().padLeft(2, '0');
  return '$h12:$m ${d.hour >= 12 ? 'PM' : 'AM'}';
}

// ── Screen ────────────────────────────────────────────────────────────────────

class TasksScreen extends GetView<TasksController> {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _Header(controller: controller, cs: cs),
            _TabBar(controller: controller, cs: cs),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: cs.primary),
                  );
                }
                final items = controller.filteredTasks;
                if (items.isEmpty) {
                  return _EmptyState(tab: controller.selectedTab.value);
                }
                return RefreshIndicator(
                  onRefresh: controller.loadTasks,
                  color: cs.primary,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      // Pagination: fetch the next page near the bottom.
                      if (n.metrics.pixels >
                          n.metrics.maxScrollExtent - 200) {
                        controller.loadMore();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      key: ValueKey(controller.selectedTab.value),
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                      itemCount: items.length +
                          (controller.isLoadingMore.value ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i >= items.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                                child: SizedBox(
                                    width: 20, height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))),
                          );
                        }
                        return _AnimatedTaskCard(
                          key: ValueKey(items[i].id),
                          index: i,
                          task: items[i],
                          controller: controller,
                        );
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final TasksController controller;
  final ColorScheme cs;
  const _Header({required this.controller, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary,
            Color.lerp(cs.primary, const Color(0xFF1D4ED8), 0.5)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My Tasks',
                        style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text('Tasks, meetings, alerts & approvals',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.75))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Summary chips
          Obx(() {
            final dueToday = controller.todaysAlerts.length;
            final pending  = controller.pendingCount;
            final done     = controller.countFor('completed');
            return Row(
              children: [
                _SummaryChip(
                    icon: Icons.today_rounded,
                    label: '$dueToday due today'),
                const SizedBox(width: 8),
                _SummaryChip(
                    icon: Icons.pending_actions_rounded,
                    label: '$pending pending'),
                const SizedBox(width: 8),
                _SummaryChip(
                    icon: Icons.check_circle_rounded,
                    label: '$done done'),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SummaryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.white),
            const SizedBox(width: 5),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ],
        ),
      );
}

// ── Segmented tab bar ─────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final TasksController controller;
  final ColorScheme cs;
  const _TabBar({required this.controller, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Obx(() {
        final selected = controller.selectedTab.value;
        return ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: TasksController.tabs.map((tab) {
            final key      = tab['key']!;
            final isActive = key == selected;
            final count    = controller.countFor(key);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  controller.selectedTab.value = key;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isActive ? cs.primary : cs.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? cs.primary
                          : cs.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tab['label']!,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isActive ? Colors.white : cs.onSurface)),
                      if (count > 0) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white.withValues(alpha: 0.25)
                                : cs.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('$count',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isActive
                                      ? Colors.white
                                      : cs.primary)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }
}

// ── Task card with swipe actions ──────────────────────────────────────────────

class _AnimatedTaskCard extends StatelessWidget {
  final int index;
  final TaskModel task;
  final TasksController controller;
  const _AnimatedTaskCard({
    super.key,
    required this.index,
    required this.task,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Staggered entrance (capped so long lists don't lag).
    final delay = (index < 8 ? index : 8) * 60;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 280 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 14 * (1 - t)), child: child),
      ),
      child: _SwipeableTaskCard(task: task, controller: controller),
    );
  }
}

class _SwipeableTaskCard extends StatelessWidget {
  final TaskModel task;
  final TasksController controller;
  const _SwipeableTaskCard({required this.task, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Dismissible(
          key: ValueKey('dismiss_${task.id}'),
          // Completed items can only be deleted.
          direction: task.isCompleted
              ? DismissDirection.endToStart
              : DismissDirection.horizontal,
          dismissThresholds: const {
            DismissDirection.startToEnd: 0.35,
            DismissDirection.endToStart: 0.45,
          },
          background: const _SwipeBackground(
            alignment: Alignment.centerLeft,
            color: _kSuccess,
            icon: Icons.check_circle_rounded,
            label: 'Complete',
          ),
          secondaryBackground: const _SwipeBackground(
            alignment: Alignment.centerRight,
            color: _kError,
            icon: Icons.delete_rounded,
            label: 'Delete',
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              HapticFeedback.mediumImpact();
              return true;
            }
            // Delete — confirm first.
            HapticFeedback.heavyImpact();
            return await _confirmDelete(context) ?? false;
          },
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              controller.markCompleted(task);
              _showFeedback(
                icon: Icons.check_circle_rounded,
                color: _kSuccess,
                message: 'Task completed',
                onUndo: () => controller.markPending(task),
              );
            } else {
              controller.deleteTask(task);
              _showFeedback(
                icon: Icons.delete_rounded,
                color: _kError,
                message: 'Task deleted',
                onUndo: () => controller.restoreTask(task),
              );
            }
          },
          child: _TaskCardBody(task: task, controller: controller),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Delete this task?',
            style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(task.title,
            style: GoogleFonts.inter(
                fontSize: 13, color: cs.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, color: _kError)),
          ),
        ],
      ),
    );
  }

  void _showFeedback({
    required IconData icon,
    required Color color,
    required String message,
    required VoidCallback onUndo,
  }) {
    Get.snackbar(
      '', '',
      titleText: const SizedBox.shrink(),
      messageText: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
          GestureDetector(
            onTap: () {
              onUndo();
              if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
            },
            child: Text('UNDO',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5)),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1F2937),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 300),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;
  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.white),
          const SizedBox(height: 3),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ],
      ),
    );
  }
}

class _TaskCardBody extends StatelessWidget {
  final TaskModel task;
  final TasksController controller;
  const _TaskCardBody({required this.task, required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs        = Theme.of(context).colorScheme;
    final typeColor = taskTypeColor(task.type);
    final prColor   = taskPriorityColor(task.priority);
    final done      = task.isCompleted;
    final project   = controller.projectFor(task);

    return Material(
      color: cs.surface,
      child: InkWell(
        onTap: project == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                Get.toNamed(AppRoutes.projectStageTracker,
                    arguments: project);
              },
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(
                  color: done ? _kSuccess : prColor, width: 3.5),
            ),
          ),
          child: Opacity(
            opacity: done ? 0.6 : 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type icon
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(taskTypeIcon(task.type),
                      size: 19, color: typeColor),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + priority badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(task.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    decoration: done
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: cs.onSurface)),
                          ),
                          const SizedBox(width: 8),
                          if (done)
                            const _Badge(
                                label: 'DONE', color: _kSuccess)
                          else if (task.isOverdue)
                            const _Badge(
                                label: 'OVERDUE', color: _kError)
                          else
                            _Badge(
                                label: task.priority.toUpperCase(),
                                color: prColor),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Type + project
                      Row(
                        children: [
                          _Badge(
                              label: task.typeLabel,
                              color: typeColor,
                              subtle: true),
                          if (task.projectName != null) ...[
                            const SizedBox(width: 6),
                            Icon(Icons.folder_outlined,
                                size: 10, color: cs.onSurfaceVariant),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(task.projectName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                      fontSize: 10.5,
                                      color: cs.onSurfaceVariant)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Due time + assigned by
                      Row(
                        children: [
                          Icon(
                            task.isOverdue && !done
                                ? Icons.warning_amber_rounded
                                : Icons.schedule_rounded,
                            size: 11,
                            color: task.isOverdue && !done
                                ? _kError
                                : cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 3),
                          Text(taskDueLabel(task),
                              style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: task.isOverdue && !done
                                      ? _kError
                                      : cs.onSurfaceVariant)),
                          const SizedBox(width: 10),
                          Icon(Icons.person_outline_rounded,
                              size: 11, color: cs.onSurfaceVariant),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(task.assignedBy,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    color: cs.onSurfaceVariant)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (project != null) ...[
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Icon(Icons.chevron_right_rounded,
                        size: 18, color: cs.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool subtle;
  const _Badge({required this.label, required this.color, this.subtle = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: subtle ? 0.08 : 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: color)),
      );
}

// ── Empty states ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String tab;
  const _EmptyState({required this.tab});

  ({IconData icon, String title, String subtitle}) get _content =>
      switch (tab) {
        'tasks'     => (
            icon: Icons.task_alt_rounded,
            title: 'No tasks scheduled',
            subtitle: 'Project tasks you create or receive will appear here.'
          ),
        'meetings'  => (
            icon: Icons.groups_rounded,
            title: 'No meetings today',
            subtitle: 'Site visits and meetings will show up here.'
          ),
        'alerts'    => (
            icon: Icons.notifications_off_rounded,
            title: 'No alerts right now',
            subtitle: 'Warnings and reminders will appear here.'
          ),
        'completed' => (
            icon: Icons.emoji_events_rounded,
            title: 'Nothing completed yet',
            subtitle: 'Swipe a task right to mark it done.'
          ),
        _           => (
            icon: Icons.celebration_rounded,
            title: "You're all caught up!",
            subtitle: 'No pending tasks, meetings or alerts.'
          ),
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c  = _content;
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutBack,
        builder: (context, t, child) =>
            Transform.scale(scale: 0.8 + 0.2 * t, child: Opacity(opacity: t.clamp(0, 1), child: child)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(c.icon, size: 40, color: cs.primary),
            ),
            const SizedBox(height: 18),
            Text(c.title,
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface)),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(c.subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 12.5,
                      height: 1.5,
                      color: cs.onSurfaceVariant)),
            ),
          ],
        ),
      ),
    );
  }
}
