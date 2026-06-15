import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/projects_controller.dart';
import '../data/models/project_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../presentation/routes/app_routes.dart';
import '../../../presentation/widgets/common/error_state_widget.dart';

// ── Status color / label / icon helpers ──────────────────────────────────────

const _kOnTrack   = Color(0xFF16A34A);
const _kAtRisk    = Color(0xFFF59E0B);
const _kLate      = Color(0xFFEF4444);
const _kOnHold    = Color(0xFF6B7280);
const _kCompleted = Color(0xFF0D9488);

Color _accent(ProjectModel p) {
  if (p.isLate)      return _kLate;
  if (p.isAtRisk)    return _kAtRisk;
  if (p.isCompleted) return _kCompleted;
  if (p.isOnHold)    return _kOnHold;
  return _kOnTrack;
}

String _statusText(ProjectModel p) {
  if (p.isLate)      return 'LATE';
  if (p.isAtRisk)    return 'AT RISK';
  if (p.isCompleted) return 'DONE';
  if (p.isOnHold)    return 'ON HOLD';
  return 'ACTIVE';
}

IconData _projectTypeIcon(String type) => switch (type) {
      'commercial'  => Icons.business_rounded,
      'renovation'  => Icons.home_repair_service_rounded,
      'apartment'   => Icons.apartment_rounded,
      _             => Icons.home_work_rounded,
    };

String _relativeTime(DateTime? dt) {
  if (dt == null) return '—';
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24)   return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

// ── Screen ────────────────────────────────────────────────────────────────────

class MyProjectsScreen extends GetView<ProjectsController> {
  const MyProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _PageHeader(controller: controller),
            _SearchBar(ctrl: controller),
            const SizedBox(height: 10),
            _FilterBar(ctrl: controller),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (controller.hasLoadError.value) {
                  return ErrorStateWidget(onRetry: controller.loadProjects);
                }
                if (controller.isLoading.value) {
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, __) => const _SkeletonProjectCard(),
                  );
                }
                final list = controller.filteredProjects;
                if (list.isEmpty) {
                  return _ProjectsEmptyState(
                    isFiltered: controller.projects.isNotEmpty,
                  );
                }
                return NotificationListener<ScrollUpdateNotification>(
                  onNotification: (note) {
                    if (note.metrics.pixels >=
                        note.metrics.maxScrollExtent - 200) {
                      controller.loadNextPage();
                    }
                    return false;
                  },
                  child: RefreshIndicator(
                    onRefresh: controller.loadProjects,
                    color: cs.primary,
                    child: Obx(() {
                      final loadingMore = controller.isLoadingMore.value;
                      final more        = controller.hasMore.value;
                      final itemCount   = list.length + 1;

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: itemCount,
                        itemBuilder: (_, i) {
                          if (i == list.length) {
                            if (loadingMore) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: SizedBox(
                                    width: 22, height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                              );
                            }
                            if (!more && list.isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20),
                                child: Center(
                                  child: Text(
                                    'All ${list.length} projects loaded',
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant
                                            .withValues(alpha: 0.6)),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ProjectCard(project: list[i]),
                          );
                        },
                      );
                    }),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-project-fab',
        onPressed: () => Get.toNamed(AppRoutes.newProjectWizard),
        tooltip: 'Add new project',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

// ── Page header ───────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  final ProjectsController controller;
  const _PageHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: cs.surface,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Projects',
                    style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        height: 1.1)),
                const SizedBox(height: 4),
                Obx(() {
                  final all       = controller.projects.length;
                  final active    = controller.projects
                      .where((p) => p.status == 'active')
                      .length;
                  final completed = controller.projects
                      .where((p) => p.status == 'completed')
                      .length;
                  final onHold   = controller.projects
                      .where((p) => p.status == 'on_hold')
                      .length;
                  if (all == 0) {
                    return Text('No projects yet',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: cs.onSurfaceVariant));
                  }
                  return Row(
                    children: [
                      _HeaderCountChip(
                          label: '$active active',
                          color: _kOnTrack,
                          isDark: isDark),
                      if (onHold > 0) ...[
                        const SizedBox(width: 6),
                        _HeaderCountChip(
                            label: '$onHold on hold',
                            color: _kOnHold,
                            isDark: isDark),
                      ],
                      if (completed > 0) ...[
                        const SizedBox(width: 6),
                        _HeaderCountChip(
                            label: '$completed done',
                            color: _kCompleted,
                            isDark: isDark),
                      ],
                    ],
                  );
                }),
              ],
            ),
          ),
          // New project icon button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Get.toNamed(AppRoutes.newProjectWizard);
            },
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCountChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;
  const _HeaderCountChip(
      {required this.label, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.20 : 0.10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: color)),
      );
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatefulWidget {
  final ProjectsController ctrl;
  const _SearchBar({required this.ctrl});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _textCtrl = TextEditingController();
  bool _hasText   = false;

  @override
  void initState() {
    super.initState();
    _textCtrl.addListener(() {
      final v = _textCtrl.text.isNotEmpty;
      if (v != _hasText) setState(() => _hasText = v);
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDark
              ? cs.surfaceContainerHighest
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.search_rounded,
                size: 18, color: cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _textCtrl,
                onChanged: widget.ctrl.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search by name, location…',
                  border: InputBorder.none,
                  hintStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: cs.onSurfaceVariant
                          .withValues(alpha: 0.65)),
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: GoogleFonts.inter(
                    fontSize: 13, color: cs.onSurface),
              ),
            ),
            if (_hasText)
              GestureDetector(
                onTap: () {
                  _textCtrl.clear();
                  widget.ctrl.setSearchQuery('');
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.cancel_rounded,
                      size: 16, color: cs.onSurfaceVariant),
                ),
              )
            else
              const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

// ── Filter bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final ProjectsController ctrl;
  const _FilterBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final all       = ctrl.projects.length;
      final active    = ctrl.projects.where((p) => p.status == 'active').length;
      final completed = ctrl.projects
          .where((p) => p.status == 'completed')
          .length;
      final onHold    = ctrl.projects
          .where((p) => p.status == 'on_hold')
          .length;
      final current   = ctrl.selectedFilter.value;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _FilterPill(
              icon: Icons.grid_view_rounded,
              label: 'All',
              count: all,
              selected: current == 'all',
              onTap: () => ctrl.selectedFilter.value = 'all',
            ),
            const SizedBox(width: 8),
            _FilterPill(
              icon: Icons.play_circle_outline_rounded,
              label: 'Active',
              count: active,
              selected: current == 'active',
              onTap: () => ctrl.selectedFilter.value = 'active',
            ),
            const SizedBox(width: 8),
            _FilterPill(
              icon: Icons.check_circle_outline_rounded,
              label: 'Completed',
              count: completed,
              selected: current == 'completed',
              onTap: () => ctrl.selectedFilter.value = 'completed',
            ),
            const SizedBox(width: 8),
            _FilterPill(
              icon: Icons.pause_circle_outline_rounded,
              label: 'On Hold',
              count: onHold,
              selected: current == 'on_hold',
              onTap: () => ctrl.selectedFilter.value = 'on_hold',
            ),
          ],
        ),
      );
    });
  }
}

class _FilterPill extends StatelessWidget {
  final IconData icon;
  final String   label;
  final int      count;
  final bool     selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.icon,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? cs.primary
              : isDark
                  ? cs.surfaceContainerHighest
                  : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? null
              : Border.all(
                  color: Theme.of(context)
                      .dividerColor
                      .withValues(alpha: 0.5),
                  width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 13,
                color: selected
                    ? Colors.white
                    : cs.onSurfaceVariant),
            const SizedBox(width: 5),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? Colors.white
                        : cs.onSurfaceVariant)),
            if (count > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.25)
                      : cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$count',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? Colors.white
                            : cs.primary)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Project card ──────────────────────────────────────────────────────────────

class _ProjectCard extends StatefulWidget {
  final ProjectModel project;
  const _ProjectCard({required this.project});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _pressed = false;

  void _open() {
    Get.find<ProjectsController>().selectProject(widget.project);
    Get.toNamed(AppRoutes.projectStageTracker, arguments: widget.project);
  }

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final p       = widget.project;
    final accent  = _accent(p);
    final pct     = p.progress.clamp(0.0, 1.0);

    // Budget health
    final budgetPct     = p.budgetAmount > 0 ? p.actualCost / p.budgetAmount : 0.0;
    final budgetColor   = budgetPct > 0.9 ? _kLate : budgetPct > 0.75 ? _kAtRisk : _kOnTrack;

    // Days left / over
    final daysLeft      = p.targetEndDate
        ?.difference(DateTime.now())
        .inDays;
    final timelineColor = (daysLeft != null && daysLeft < 0)
        ? _kLate
        : (daysLeft != null && daysLeft <= 14)
            ? _kAtRisk
            : _kOnTrack;

    final bgColor = isDark
        ? Color.lerp(cs.surface, accent, 0.05)!
        : cs.surface;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        _open();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accent.withValues(alpha: isDark ? 0.22 : 0.14),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: isDark ? 0.12 : 0.07),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Row 1: Icon + Name + Status badge ─────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: accent.withValues(
                                  alpha: isDark ? 0.20 : 0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                                _projectTypeIcon(p.type),
                                size: 22, color: accent),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: cs.onSurface,
                                        height: 1.2)),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined,
                                        size: 10,
                                        color: cs.onSurfaceVariant),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Text(
                                        '${p.area}, ${p.city}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: cs.onSurfaceVariant),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5, height: 5,
                                  decoration: BoxDecoration(
                                    color: accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(_statusText(p),
                                    style: GoogleFonts.inter(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: accent,
                                        letterSpacing: 0.3)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── Row 2: Current stage + last update ────────────────
                      Row(
                        children: [
                          Icon(Icons.construction_rounded,
                              size: 12,
                              color: cs.onSurfaceVariant
                                  .withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              p.currentStage.isNotEmpty
                                  ? p.currentStage
                                  : 'No active stage',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: cs.onSurfaceVariant),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.update_rounded,
                                  size: 10,
                                  color: cs.onSurfaceVariant
                                      .withValues(alpha: 0.6)),
                              const SizedBox(width: 3),
                              Text(_relativeTime(p.lastUpdated),
                                  style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: cs.onSurfaceVariant
                                          .withValues(alpha: 0.7))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ── Row 3: Progress bar ───────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 7,
                                backgroundColor: accent
                                    .withValues(alpha: isDark ? 0.18 : 0.10),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(accent),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${(pct * 100).toStringAsFixed(0)}%',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: accent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── Row 4: Stats grid ─────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? cs.surfaceContainerHighest
                                  .withValues(alpha: 0.5)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            _StatCell(
                              icon: Icons.account_balance_wallet_outlined,
                              value: CurrencyFormatter.formatCompact(
                                  p.actualCost,
                                  currency: p.currencyCode),
                              sub: 'of ${CurrencyFormatter.formatCompact(p.budgetAmount, currency: p.currencyCode)}',
                              color: budgetColor,
                            ),
                            _vDivider(context),
                            _StatCell(
                              icon: Icons.people_alt_outlined,
                              value: '${p.workerCount}',
                              sub: 'workers',
                              color: cs.onSurfaceVariant,
                            ),
                            _vDivider(context),
                            _StatCell(
                              icon: Icons.photo_camera_outlined,
                              value: '${p.photoCount}',
                              sub: 'photos',
                              color: cs.onSurfaceVariant,
                            ),
                            _vDivider(context),
                            _StatCell(
                              icon: Icons.calendar_today_rounded,
                              value: daysLeft == null
                                  ? '—'
                                  : daysLeft < 0
                                      ? '${(-daysLeft)}d'
                                      : '${daysLeft}d',
                              sub: daysLeft != null && daysLeft < 0
                                  ? 'overdue'
                                  : 'left',
                              color: timelineColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Row 5: Quick action footer ────────────────────────
                      Row(
                        children: [
                          _QuickActionBtn(
                            icon: Icons.layers_rounded,
                            label: 'Stages',
                            onTap: _open,
                          ),
                          const SizedBox(width: 6),
                          _QuickActionBtn(
                            icon: Icons.account_balance_wallet_rounded,
                            label: 'Budget',
                            onTap: _open,
                          ),
                          const SizedBox(width: 6),
                          _QuickActionBtn(
                            icon: Icons.photo_library_outlined,
                            label: 'Photos',
                            onTap: _open,
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _open,
                            child: Row(
                              children: [
                                Text('View',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: accent)),
                                const SizedBox(width: 2),
                                Icon(Icons.arrow_forward_rounded,
                                    size: 13, color: accent),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                // Left accent strip
                Positioned(
                  left: 0, top: 0, bottom: 0,
                  child: Container(
                    width: 4,
                    color: accent.withValues(
                        alpha: isDark ? 0.70 : 0.55),
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

Widget _vDivider(BuildContext context) => Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
    );

class _StatCell extends StatelessWidget {
  final IconData icon;
  final String value;
  final String sub;
  final Color color;

  const _StatCell({
    required this.icon,
    required this.value,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(height: 3),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color)),
          Text(sub,
              style: GoogleFonts.inter(
                  fontSize: 9,
                  color: cs.onSurfaceVariant
                      .withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: isDark
              ? cs.surfaceContainerHighest.withValues(alpha: 0.6)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: cs.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _ProjectsEmptyState extends StatelessWidget {
  final bool isFiltered;
  const _ProjectsEmptyState({required this.isFiltered});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (isFiltered) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.search_off_rounded,
                    size: 34,
                    color: cs.onSurfaceVariant
                        .withValues(alpha: 0.40)),
              ),
              const SizedBox(height: 16),
              Text('No matching projects',
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface),
                  textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text('Try a different search or filter',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.construction_rounded,
                  size: 46, color: cs.primary.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 24),
            Text('No Projects Yet',
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              'Start by creating your first construction project.\nTrack stages, budget, and team from one place.',
              style: GoogleFonts.inter(
                  fontSize: 13, color: cs.onSurfaceVariant, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.newProjectWizard),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Create Project'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _SkeletonProjectCard extends StatelessWidget {
  const _SkeletonProjectCard();

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final base       = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE4E7EC);
    final highlight  = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F7FA);
    final surface    = Theme.of(context).colorScheme.surface;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Theme.of(context).dividerColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                _Block(width: 44, height: 44, radius: 12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Block(height: 14, radius: 6),
                      const SizedBox(height: 6),
                      _Block(width: 120, height: 10, radius: 4),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _Block(width: 58, height: 22, radius: 20),
              ],
            ),
            const SizedBox(height: 12),
            _Block(width: 150, height: 10, radius: 4),
            const SizedBox(height: 10),
            _Block(height: 7, radius: 100),
            const SizedBox(height: 12),
            // Stats row
            _Block(height: 52, radius: 10),
            const SizedBox(height: 10),
            // Actions row
            Row(
              children: [
                _Block(width: 68, height: 28, radius: 8),
                const SizedBox(width: 6),
                _Block(width: 68, height: 28, radius: 8),
                const SizedBox(width: 6),
                _Block(width: 68, height: 28, radius: 8),
              ],
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  final double? width;
  final double  height;
  final double  radius;
  const _Block({this.width, required this.height, this.radius = 4});

  @override
  Widget build(BuildContext context) => Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}
