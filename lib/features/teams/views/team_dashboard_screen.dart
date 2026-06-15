import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/team_controller.dart';
import '../data/models/team_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../presentation/routes/app_routes.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';

// ── Module-level constants ────────────────────────────────────────────────────

const _kTeamViolet  = Color(0xFF7C3AED);
const _kTeamIndigo  = Color(0xFF4F46E5);

Color _typeAccent(TeamType t) => switch (t) {
      TeamType.structural  => const Color(0xFFF97316), // orange
      TeamType.finishing   => const Color(0xFF22C55E), // green
      TeamType.electrical  => const Color(0xFFEAB308), // yellow
      TeamType.plumbing    => const Color(0xFF3B82F6), // blue
      TeamType.general     => const Color(0xFF6B7280), // gray
      TeamType.specialized => const Color(0xFF8B5CF6), // violet
    };

IconData _typeIcon(TeamType t) => switch (t) {
      TeamType.structural  => Icons.foundation_rounded,
      TeamType.finishing   => Icons.format_paint_rounded,
      TeamType.electrical  => Icons.electric_bolt_rounded,
      TeamType.plumbing    => Icons.water_drop_rounded,
      TeamType.general     => Icons.construction_rounded,
      TeamType.specialized => Icons.precision_manufacturing_rounded,
    };

Color _statusColor(TeamStatus s) => switch (s) {
      TeamStatus.active   => const Color(0xFF16A34A),
      TeamStatus.inactive => const Color(0xFF6B7280),
      TeamStatus.onLeave  => const Color(0xFFF59E0B),
    };

String _relativeTime(DateTime? dt) {
  if (dt == null) return '—';
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24)   return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

// ── Screen ────────────────────────────────────────────────────────────────────

class TeamDashboardScreen extends GetView<TeamController> {
  const TeamDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'create-team-fab',
        onPressed: () => Get.toNamed(AppRoutes.createTeam),
        backgroundColor: _kTeamViolet,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.group_add_rounded, size: 20),
        label: Text('New Team',
            style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Fixed page header ──────────────────────────────────────────
            _PageHeader(isDark: isDark, cs: cs),

            // ── Scrollable body ────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildSkeleton(context);
                }
                return RefreshIndicator(
                  onRefresh: controller.loadTeams,
                  color: _kTeamViolet,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.xxxl + 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // KPI strip
                        _KpiStrip(controller: controller),
                        const SizedBox(height: AppDimensions.xl),

                        // Team list
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.pagePaddingH),
                          child: _TeamListSection(
                              controller: controller, isDark: isDark),
                        ),
                      ],
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

  Widget _buildSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmer = isDark ? const Color(0xFF2D3748) : AppColors.shimmerBase;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      child: Column(
        children: [
          Container(height: 80, decoration: BoxDecoration(
              color: shimmer, borderRadius: BorderRadius.circular(12))),
          const SizedBox(height: 16),
          ...List.generate(3, (_) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 130,
            decoration: BoxDecoration(
                color: shimmer, borderRadius: BorderRadius.circular(16)),
          )),
        ],
      ),
    );
  }
}

// ── Page header ───────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const _PageHeader({required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TeamController>();
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePaddingH, 14, AppDimensions.pagePaddingH, 12),
      child: Row(
        children: [
          // Icon badge + title
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kTeamViolet, _kTeamIndigo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.groups_rounded,
                size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Team Management',
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        height: 1.1)),
                Obx(() => Text(
                      '${ctrl.totalTeams} teams · ${ctrl.totalWorkers} workers',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: cs.onSurfaceVariant),
                    )),
              ],
            ),
          ),
          // Sort / filter (placeholder — future)
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: isDark
                  ? cs.surfaceContainerHighest
                  : Theme.of(context).dividerColor.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.sort_rounded,
                size: 18, color: cs.onSurface),
          ),
        ],
      ),
    );
  }
}

// ── KPI strip ─────────────────────────────────────────────────────────────────

class _KpiStrip extends StatelessWidget {
  final TeamController controller;
  const _KpiStrip({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: Obx(() {
        final kpis = [
          _KpiDatum(
              label: 'Teams',
              value: '${controller.totalTeams}',
              icon: Icons.groups_rounded,
              color: _kTeamViolet),
          _KpiDatum(
              label: 'Active',
              value: '${controller.activeTeams}',
              icon: Icons.check_circle_outline_rounded,
              color: const Color(0xFF16A34A)),
          _KpiDatum(
              label: 'Workers',
              value: '${controller.totalWorkers}',
              icon: Icons.people_alt_outlined,
              color: const Color(0xFF3B82F6)),
          _KpiDatum(
              label: 'On Site',
              value: '${controller.activeWorkers}',
              icon: Icons.location_on_outlined,
              color: const Color(0xFF0D9488)),
          _KpiDatum(
              label: 'On Leave',
              value: '${controller.workersOnLeave}',
              icon: Icons.event_busy_rounded,
              color: const Color(0xFFF59E0B)),
          _KpiDatum(
              label: 'Projects',
              value: '${controller.assignedProjectCount}',
              icon: Icons.folder_open_rounded,
              color: const Color(0xFFF97316)),
        ];
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pagePaddingH),
          itemCount: kpis.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, i) => _KpiCard(datum: kpis[i]),
        );
      }),
    );
  }
}

class _KpiDatum {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _KpiDatum(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});
}

class _KpiCard extends StatelessWidget {
  final _KpiDatum datum;
  const _KpiCard({required this.datum});

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 88,
      decoration: BoxDecoration(
        color: isDark
            ? Color.lerp(cs.surface, datum.color, 0.08)
            : cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: datum.color.withValues(alpha: isDark ? 0.25 : 0.15),
            width: 1),
        boxShadow: [
          BoxShadow(
            color: datum.color.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: datum.color.withValues(alpha: isDark ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(datum.icon, size: 16, color: datum.color),
          ),
          const SizedBox(height: 6),
          Text(datum.value,
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: datum.color,
                  height: 1.0)),
          const SizedBox(height: 2),
          Text(datum.label,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ── Team list section ─────────────────────────────────────────────────────────

class _TeamListSection extends StatelessWidget {
  final TeamController controller;
  final bool isDark;

  const _TeamListSection(
      {required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Obx(() {
      final teams = controller.filteredTeams;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Text('My Teams',
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _kTeamViolet.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${teams.length}',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _kTeamViolet)),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),

          if (teams.isEmpty)
            _EmptyTeamsCard()
          else
            ...teams.map((t) => _TeamCard(team: t, isDark: isDark)),
        ],
      );
    });
  }
}

// ── Team card ─────────────────────────────────────────────────────────────────

class _TeamCard extends StatefulWidget {
  final TeamModel team;
  final bool isDark;
  const _TeamCard({required this.team, required this.isDark});

  @override
  State<_TeamCard> createState() => _TeamCardState();
}

class _TeamCardState extends State<_TeamCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final t      = widget.team;
    final isDark = widget.isDark;
    final accent = _typeAccent(t.type);
    final sColor = _statusColor(t.status);

    final bgColor = isDark
        ? Color.lerp(cs.surface, accent, 0.05)!
        : cs.surface;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        Get.toNamed(AppRoutes.teamDetail, arguments: t);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: accent.withValues(alpha: isDark ? 0.22 : 0.14),
                width: 1),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: isDark ? 0.10 : 0.06),
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
                  padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: type icon + name + status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              color: accent.withValues(
                                  alpha: isDark ? 0.20 : 0.10),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(_typeIcon(t.type),
                                size: 20, color: accent),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: cs.onSurface,
                                        height: 1.2)),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.person_outline_rounded,
                                        size: 10,
                                        color: cs.onSurfaceVariant),
                                    const SizedBox(width: 3),
                                    Text(t.leaderName,
                                        style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: cs.onSurfaceVariant)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: sColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                    width: 5, height: 5,
                                    decoration: BoxDecoration(
                                        color: sColor,
                                        shape: BoxShape.circle)),
                                const SizedBox(width: 4),
                                Text(t.status.label.toUpperCase(),
                                    style: GoogleFonts.inter(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: sColor,
                                        letterSpacing: 0.3)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 11),

                      // Row 2: stats strip
                      Row(
                        children: [
                          _StatPill(
                            icon: Icons.people_alt_outlined,
                            label:
                                '${t.activeWorkerCount}/${t.workerCount} workers',
                            color: accent,
                          ),
                          const SizedBox(width: 8),
                          _StatPill(
                            icon: Icons.folder_open_rounded,
                            label:
                                '${t.assignedProjectCount} project${t.assignedProjectCount == 1 ? '' : 's'}',
                            color: const Color(0xFF3B82F6),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 10,
                                  color: cs.onSurfaceVariant
                                      .withValues(alpha: 0.6)),
                              const SizedBox(width: 3),
                              Text(_relativeTime(t.lastActivityAt),
                                  style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: cs.onSurfaceVariant
                                          .withValues(alpha: 0.7))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Worker presence bar
                      _WorkerPresenceBar(
                          team: t, accent: accent, isDark: isDark),
                      const SizedBox(height: 10),

                      // Quick actions — icon-only to stay within card width
                      Row(
                        children: [
                          _IconBtn(
                            icon: Icons.visibility_outlined,
                            tooltip: 'View',
                            color: accent,
                            onTap: () => Get.toNamed(
                                AppRoutes.teamDetail, arguments: t),
                          ),
                          const SizedBox(width: 8),
                          _IconBtn(
                            icon: Icons.fact_check_outlined,
                            tooltip: 'Attendance',
                            color: const Color(0xFF0D9488),
                            onTap: () => Get.toNamed(
                                AppRoutes.teamDetail, arguments: t),
                          ),
                          const SizedBox(width: 8),
                          _IconBtn(
                            icon: Icons.person_add_alt_1_outlined,
                            tooltip: 'Add Worker',
                            color: const Color(0xFF3B82F6),
                            onTap: () => Get.toNamed(
                                AppRoutes.teamDetail, arguments: t),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Text('Details',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: accent)),
                              const SizedBox(width: 2),
                              Icon(Icons.arrow_forward_rounded,
                                  size: 13, color: accent),
                            ],
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
                    width: 4,
                    color: accent
                        .withValues(alpha: isDark ? 0.70 : 0.55),
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

// ── Worker presence progress bar ──────────────────────────────────────────────

class _WorkerPresenceBar extends StatelessWidget {
  final TeamModel team;
  final Color accent;
  final bool isDark;

  const _WorkerPresenceBar(
      {required this.team, required this.accent, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs  = Theme.of(context).colorScheme;
    final pct = team.workerCount > 0
        ? team.activeWorkerCount / team.workerCount
        : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Text('Workers Active',
                style: GoogleFonts.inter(
                    fontSize: 10,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7))),
            const Spacer(),
            Text(
                '${team.activeWorkerCount} of ${team.workerCount}',
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: accent)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 5,
            backgroundColor:
                accent.withValues(alpha: isDark ? 0.18 : 0.10),
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
        ),
      ],
    );
  }
}

// ── Stat pill ─────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatPill(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}

// ── Icon-only action button (used inside cards where space is limited) ────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: color.withValues(alpha: 0.20), width: 1),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }
}

// ── Quick action button (used in empty state / detail screens) ────────────────

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 9, vertical: 5.5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: color.withValues(alpha: 0.18), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyTeamsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        color: _kTeamViolet.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: _kTeamViolet.withValues(alpha: 0.12), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: _kTeamViolet.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.groups_rounded,
                size: 28, color: _kTeamViolet),
          ),
          const SizedBox(height: 12),
          Text('No Teams Yet',
              style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface)),
          const SizedBox(height: 6),
          Text('Create your first team to start\nmanaging your workforce',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  height: 1.5,
                  color: cs.onSurfaceVariant)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.createTeam),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _kTeamViolet,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.group_add_rounded,
                      size: 16, color: Colors.white),
                  const SizedBox(width: 7),
                  Text('Create First Team',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
