import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/team_controller.dart';
import '../controllers/team_attendance_controller.dart';
import '../data/models/team_model.dart';
import '../../labor/data/models/attendance_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';

const _kTeamViolet = Color(0xFF7C3AED);

Color _typeAccent(TeamType t) => switch (t) {
      TeamType.structural  => const Color(0xFFF97316),
      TeamType.finishing   => const Color(0xFF22C55E),
      TeamType.electrical  => const Color(0xFFEAB308),
      TeamType.plumbing    => const Color(0xFF3B82F6),
      TeamType.general     => const Color(0xFF6B7280),
      TeamType.specialized => const Color(0xFF8B5CF6),
    };

IconData _typeIcon(TeamType t) => switch (t) {
      TeamType.structural  => Icons.foundation_rounded,
      TeamType.finishing   => Icons.format_paint_rounded,
      TeamType.electrical  => Icons.electric_bolt_rounded,
      TeamType.plumbing    => Icons.water_drop_rounded,
      TeamType.general     => Icons.construction_rounded,
      TeamType.specialized => Icons.precision_manufacturing_rounded,
    };

Color _workerStatusColor(WorkerStatus s) => switch (s) {
      WorkerStatus.active   => const Color(0xFF16A34A),
      WorkerStatus.inactive => const Color(0xFF6B7280),
      WorkerStatus.onLeave  => const Color(0xFFF59E0B),
    };

// ── Screen ────────────────────────────────────────────────────────────────────

class TeamDetailScreen extends StatefulWidget {
  const TeamDetailScreen({super.key});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  late final TeamModel _team;
  late final Color _accent;
  late final TeamAttendanceController _attCtrl;

  @override
  void initState() {
    super.initState();
    _team   = Get.arguments as TeamModel;
    _accent = _typeAccent(_team.type);
    _attCtrl = Get.put(TeamAttendanceController(team: _team));
  }

  @override
  void dispose() {
    Get.delete<TeamAttendanceController>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            _TeamSliverHeader(team: _team, accent: _accent),
          ],
          body: Column(
            children: [
              _TabBar(accent: _accent),
              Expanded(
                child: TabBarView(
                  children: [
                    _WorkersTab(team: _team, accent: _accent),
                    _AttendanceTab(ctrl: _attCtrl, accent: _accent),
                    _AssignmentsTab(team: _team, accent: _accent),
                    _LaborCostTab(ctrl: _attCtrl, accent: _accent),
                    _ActivityTab(accent: _accent),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sliver header ─────────────────────────────────────────────────────────────

class _TeamSliverHeader extends StatelessWidget {
  final TeamModel team;
  final Color accent;

  const _TeamSliverHeader({required this.team, required this.accent});

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? AppColors.surfaceDark : cs.surface,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: cs.onSurface),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert_rounded, color: cs.onSurface),
          onPressed: () => _showTeamOptions(context),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _HeaderBackground(
            team: team, accent: accent, isDark: isDark),
      ),
    );
  }

  void _showTeamOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _TeamOptionsSheet(team: team),
    );
  }
}

class _HeaderBackground extends StatelessWidget {
  final TeamModel team;
  final Color accent;
  final bool isDark;

  const _HeaderBackground(
      {required this.team, required this.accent, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Color.lerp(cs.surface, accent, 0.25)!,
                  Color.lerp(cs.surface, accent, 0.08)!,
                ]
              : [
                  Color.lerp(Colors.white, accent, 0.12)!,
                  Color.lerp(Colors.white, accent, 0.04)!,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 52, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: accent.withValues(alpha: 0.30), width: 1.5),
                    ),
                    child: Icon(_typeIcon(team.type), size: 26, color: accent),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(team.name,
                            style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface,
                                height: 1.1)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person_rounded,
                                size: 12, color: cs.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(team.leaderName,
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      team.status.label.toUpperCase(),
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: accent,
                          letterSpacing: 0.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MiniKpi(value: '${team.workerCount}', label: 'Workers', accent: accent),
                  _vDivider(),
                  _MiniKpi(
                      value: '${team.activeWorkerCount}',
                      label: 'Active',
                      accent: const Color(0xFF16A34A)),
                  _vDivider(),
                  _MiniKpi(
                      value: '${team.assignedProjectCount}',
                      label: 'Projects',
                      accent: const Color(0xFF3B82F6)),
                  _vDivider(),
                  _MiniKpi(
                      value: CurrencyFormatter.formatCompact(team.totalMonthlyCost),
                      label: 'Monthly',
                      accent: const Color(0xFF0D9488)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1, height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        color: Colors.white.withValues(alpha: 0.20),
      );
}

class _MiniKpi extends StatelessWidget {
  final String value;
  final String label;
  final Color accent;

  const _MiniKpi({required this.value, required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.w800, color: accent)),
        Text(label,
            style: GoogleFonts.inter(fontSize: 10, color: cs.onSurfaceVariant)),
      ],
    );
  }
}

// ── Tab bar ───────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final Color accent;
  const _TabBar({required this.accent});

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.surfaceDark : cs.surface,
      child: TabBar(
        indicatorColor: accent,
        indicatorWeight: 2.5,
        labelColor: accent,
        unselectedLabelColor: cs.onSurfaceVariant,
        labelStyle:
            GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: const [
          Tab(text: 'Workers'),
          Tab(text: 'Attendance'),
          Tab(text: 'Assignments'),
          Tab(text: 'Labor Cost'),
          Tab(text: 'Activity'),
        ],
      ),
    );
  }
}

// ── Workers tab ───────────────────────────────────────────────────────────────

class _WorkersTab extends StatelessWidget {
  final TeamModel team;
  final Color accent;

  const _WorkersTab({required this.team, required this.accent});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Obx(() {
      final tc      = Get.find<TeamController>();
      final current = tc.teams.firstWhereOrNull((t) => t.id == team.id) ?? team;
      final workers = current.workers;

      return ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        itemCount: workers.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.md),
              child: Row(
                children: [
                  Text('${workers.length} Workers',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.toNamed(
                      '/teams/add-worker',
                      arguments: current,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person_add_alt_1_rounded,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 5),
                          Text('Add Worker',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
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
          return _WorkerTile(
              worker: workers[i - 1], team: current, accent: accent);
        },
      );
    });
  }
}

class _WorkerTile extends StatelessWidget {
  final TeamWorkerModel worker;
  final TeamModel team;
  final Color accent;

  const _WorkerTile({
    required this.worker,
    required this.team,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sColor = _workerStatusColor(worker.status);
    final initials = worker.name.trim().split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();

    return GestureDetector(
      onTap: () => _showWorkerProfileSheet(context, worker, team, accent),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: isDark ? cs.surfaceContainerHighest : cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: sColor.withValues(alpha: isDark ? 0.20 : 0.12), width: 1),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials.isNotEmpty ? initials : '?',
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w700, color: accent),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name + skill + status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(worker.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(worker.skillType,
                            style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: accent)),
                      ),
                      const SizedBox(width: 7),
                      Container(
                          width: 5, height: 5,
                          decoration: BoxDecoration(
                              color: sColor, shape: BoxShape.circle)),
                      const SizedBox(width: 3),
                      Text(worker.status.label,
                          style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: sColor)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Daily wage + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(CurrencyFormatter.formatCompact(worker.dailyWage),
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface)),
                Text('/day',
                    style: GoogleFonts.inter(
                        fontSize: 9, color: cs.onSurfaceVariant)),
              ],
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded,
                size: 18,
                color: cs.onSurfaceVariant.withValues(alpha: 0.45)),
          ],
        ),
      ),
    );
  }
}

// ── Worker detail bottom sheet ────────────────────────────────────────────────

void _showWorkerProfileSheet(
  BuildContext context,
  TeamWorkerModel worker,
  TeamModel team,
  Color accent,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _WorkerProfileSheet(worker: worker, team: team, accent: accent),
  );
}

class _WorkerProfileSheet extends StatefulWidget {
  final TeamWorkerModel worker;
  final TeamModel team;
  final Color accent;
  const _WorkerProfileSheet({
    required this.worker,
    required this.team,
    required this.accent,
  });

  @override
  State<_WorkerProfileSheet> createState() => _WorkerProfileSheetState();
}

class _WorkerProfileSheetState extends State<_WorkerProfileSheet> {
  bool _copied = false;

  Future<void> _copyPhone() async {
    await Clipboard.setData(ClipboardData(text: widget.worker.phone));
    HapticFeedback.lightImpact();
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final worker = widget.worker;
    final accent = widget.accent;
    final sColor = _workerStatusColor(worker.status);

    final initials = worker.name.trim().split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();

    final monthlyCost = worker.monthlySalary ?? worker.dailyWage * 26;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Avatar + name + badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.22),
                      accent.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: accent.withValues(alpha: 0.30), width: 2),
                ),
                child: Center(
                  child: Text(
                    initials.isNotEmpty ? initials : '?',
                    style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: accent),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(worker.name,
                        style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                            height: 1.1)),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        _SheetBadge(
                            label: worker.skillType,
                            bgColor: accent.withValues(alpha: 0.10),
                            textColor: accent),
                        const SizedBox(width: 7),
                        _SheetBadge(
                            label: worker.status.label,
                            bgColor: sColor.withValues(alpha: 0.10),
                            textColor: sColor,
                            dot: sColor),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),
          Divider(
              height: 1,
              color: cs.outlineVariant.withValues(alpha: 0.35)),
          const SizedBox(height: 14),

          // Info rows
          _SheetInfoRow(
            icon: Icons.groups_outlined,
            label: 'Team',
            value: widget.team.name,
            accent: accent, isDark: isDark, cs: cs,
          ),
          _SheetInfoRow(
            icon: Icons.payments_outlined,
            label: 'Daily Wage',
            value: '${CurrencyFormatter.formatPKR(worker.dailyWage)} / day',
            accent: accent, isDark: isDark, cs: cs,
          ),
          _SheetInfoRow(
            icon: Icons.calendar_month_outlined,
            label: 'Monthly Est.',
            value: '${CurrencyFormatter.formatPKR(monthlyCost)} / month',
            accent: accent, isDark: isDark, cs: cs,
          ),
          _SheetInfoRow(
            icon: Icons.event_available_outlined,
            label: 'Joined',
            value: _formatDate(worker.joiningDate),
            accent: accent, isDark: isDark, cs: cs,
          ),

          // Phone row with inline copy button
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: isDark
                  ? cs.surfaceContainerHighest.withValues(alpha: 0.4)
                  : cs.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(Icons.phone_outlined, size: 17, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phone',
                          style: GoogleFonts.inter(
                              fontSize: 10, color: cs.onSurfaceVariant)),
                      Text(worker.phone,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface)),
                    ],
                  ),
                ),
                // Inline copy chip — animates to "Copied" on success
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: Tween<double>(begin: 0.80, end: 1.0).animate(
                        CurvedAnimation(
                            parent: anim, curve: Curves.easeOutBack)),
                    child: child,
                  ),
                  child: _copied
                      ? Container(
                          key: const ValueKey('copied'),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_rounded,
                                  size: 13, color: AppColors.success),
                              const SizedBox(width: 4),
                              Text('Copied',
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success)),
                            ],
                          ),
                        )
                      : GestureDetector(
                          key: const ValueKey('copy'),
                          onTap: _copyPhone,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.copy_rounded,
                                    size: 13, color: accent),
                                const SizedBox(width: 4),
                                Text('Copy',
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: accent)),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),

          // Full-width copy button
          SizedBox(
            width: double.infinity,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              child: ElevatedButton.icon(
                onPressed: _copyPhone,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    _copied
                        ? Icons.check_rounded
                        : Icons.copy_rounded,
                    size: 18,
                    key: ValueKey(_copied),
                  ),
                ),
                label: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    _copied ? 'Number Copied!' : 'Copy Number',
                    key: ValueKey(_copied),
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _copied ? AppColors.success : accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetBadge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color? dot;
  const _SheetBadge({
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.dot,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(6)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dot != null) ...[
              Container(
                  width: 5, height: 5,
                  decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
              const SizedBox(width: 4),
            ],
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textColor)),
          ],
        ),
      );
}

class _SheetInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final bool isDark;
  final ColorScheme cs;
  const _SheetInfoRow({
    required this.icon, required this.label, required this.value,
    required this.accent, required this.isDark, required this.cs,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isDark
              ? cs.surfaceContainerHighest.withValues(alpha: 0.4)
              : cs.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 17, color: accent),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 10, color: cs.onSurfaceVariant)),
                Text(value,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface)),
              ],
            ),
          ],
        ),
      );
}

// ── Attendance tab ────────────────────────────────────────────────────────────

class _AttendanceTab extends StatelessWidget {
  final TeamAttendanceController ctrl;
  final Color accent;

  const _AttendanceTab({required this.ctrl, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return Column(
        children: [
          _AttWeekHeader(ctrl: ctrl),
          _AttSummaryRow(ctrl: ctrl, accent: accent),
          const Divider(height: 1),
          _AttBulkBar(ctrl: ctrl),
          const Divider(height: 1),
          _AttFrozenHeader(),
          const Divider(height: 1),
          Expanded(
            child: ctrl.workers.isEmpty
                ? _EmptyWorkers(accent: accent)
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: ctrl.workers.length,
                    itemBuilder: (_, i) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AttWorkerRow(
                            ctrl: ctrl, workerIndex: i, accent: accent),
                        Divider(
                            height: 1,
                            color: Theme.of(context).dividerColor),
                      ],
                    ),
                  ),
          ),
          _AttBottomBar(ctrl: ctrl, accent: accent),
        ],
      );
    });
  }
}

// ── Week header ───────────────────────────────────────────────────────────────

class _AttWeekHeader extends StatelessWidget {
  final TeamAttendanceController ctrl;
  const _AttWeekHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;
    final bg      = Theme.of(context).scaffoldBackgroundColor;

    return Obx(() {
      final start = ctrl.selectedWeekStart.value;
      final end   = ctrl.weekEnd;
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
            GestureDetector(
              onTap: ctrl.prevWeek,
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
            Expanded(
              child: Text(label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface)),
            ),
            GestureDetector(
              onTap: ctrl.canGoNext ? ctrl.nextWeek : null,
              child: Container(
                width: 44, height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ctrl.canGoNext ? surface : divider,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: divider),
                ),
                child: Icon(Icons.chevron_right_rounded,
                    size: 20,
                    color: ctrl.canGoNext
                        ? cs.onSurface
                        : cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Summary row ───────────────────────────────────────────────────────────────

class _AttSummaryRow extends StatelessWidget {
  final TeamAttendanceController ctrl;
  final Color accent;
  const _AttSummaryRow({required this.ctrl, required this.accent});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: cs.surface,
          child: Row(
            children: [
              _AttSummaryChip(
                  label: 'Workers',
                  value: '${ctrl.totalWorkers}',
                  color: accent,
                  muted: cs.onSurfaceVariant),
              const SizedBox(width: 12),
              _AttSummaryChip(
                  label: 'Present today',
                  value: '${ctrl.presentToday}',
                  color: AppColors.success,
                  muted: cs.onSurfaceVariant),
              const Spacer(),
              Text(ctrl.formattedWeeklyTotal,
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: accent)),
              const SizedBox(width: 4),
              Text('week',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: cs.onSurfaceVariant)),
            ],
          ),
        ));
  }
}

class _AttSummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color muted;
  const _AttSummaryChip({
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
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text('$value $label',
              style: GoogleFonts.inter(fontSize: 11, color: muted)),
        ],
      );
}

// ── Bulk action bar ───────────────────────────────────────────────────────────

class _AttBulkBar extends StatelessWidget {
  final TeamAttendanceController ctrl;
  const _AttBulkBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Text("Today's bulk action:",
              style: GoogleFonts.inter(
                  fontSize: 11, color: cs.onSurfaceVariant)),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () {
              ctrl.markAllPresent();
              Get.snackbar(
                'Done', 'All workers marked present for today',
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
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
                ctrl.markAllAbsent();
                Get.snackbar(
                  'Done', 'All workers marked absent for today',
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

// ── Frozen column header ──────────────────────────────────────────────────────

class _AttFrozenHeader extends StatelessWidget {
  const _AttFrozenHeader();

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
          ...TeamAttendanceController.dayHeaders.map(
            (d) => Expanded(
              child: Text(d,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: cs.onSurfaceVariant)),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Fri',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.4))),
                Text('Off',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF59E0B)
                            .withValues(alpha: 0.8))),
              ],
            ),
          ),
          SizedBox(
            width: 60,
            child: Text('Wage',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 11, color: cs.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}

// ── Worker grid row ───────────────────────────────────────────────────────────

class _AttWorkerRow extends StatelessWidget {
  final TeamAttendanceController ctrl;
  final int workerIndex;
  final Color accent;

  const _AttWorkerRow({
    required this.ctrl,
    required this.workerIndex,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final worker = ctrl.workers[workerIndex];

    return Obx(() {
      final wage = ctrl.workerWeeklyEarnings(worker);
      return Container(
        color: cs.surface,
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // Worker name — tappable → worker detail sheet
            GestureDetector(
              onTap: () => _showWorkerDetail(context, ctrl, worker, accent),
              child: SizedBox(
                width: 120,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        worker.name.split(' ').first,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: accent),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        worker.skillType,
                        style: GoogleFonts.inter(
                            fontSize: 10, color: cs.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Day cells (tap to cycle, long-press for OT hours)
            ...ctrl.weekDays.map((day) {
              final rec = ctrl.getRecord(worker.id, day);
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ctrl.cycleStatus(worker.id, day);
                  },
                  onLongPress: () {
                    if (rec.status == AttendanceStatus.overtime) {
                      _showOtDialog(
                          context, ctrl, worker.id, day, rec.overtimeHours);
                    }
                  },
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: 44, minHeight: 44),
                    child: Center(
                      child: _AttStatusCell(
                          status: rec.status, otHours: rec.overtimeHours),
                    ),
                  ),
                ),
              );
            }),
            // Friday Off cell (non-interactive)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .dividerColor
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Off',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF59E0B)
                            .withValues(alpha: 0.7))),
              ),
            ),
            // Weekly wage
            SizedBox(
              width: 60,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  CurrencyFormatter.formatPKR(wage),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accent),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Status cell ───────────────────────────────────────────────────────────────

class _AttStatusCell extends StatelessWidget {
  final AttendanceStatus status;
  final double otHours;
  const _AttStatusCell({required this.status, this.otHours = 0});

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
      AttendanceStatus.leave    => (
          'L',
          Theme.of(context).dividerColor,
          Theme.of(context).colorScheme.onSurfaceVariant,
        ),
    };
    return Container(
      width: 30, height: 30,
      alignment: Alignment.center,
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: TextStyle(
              fontSize: status == AttendanceStatus.overtime && otHours > 0
                  ? 8
                  : 10,
              fontWeight: FontWeight.w700,
              color: fg)),
    );
  }
}

// ── Overtime hours dialog ─────────────────────────────────────────────────────

void _showOtDialog(
  BuildContext context,
  TeamAttendanceController ctrl,
  String workerId,
  DateTime date,
  double currentHours,
) {
  final textCtrl = TextEditingController(
      text: currentHours.toStringAsFixed(0));
  final errorObs = RxnString();

  showDialog<void>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: const Text('Set Overtime Hours'),
      content: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: textCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Hours (max 12)',
                  suffixText: 'hrs',
                  border: const OutlineInputBorder(),
                  errorText: errorObs.value,
                ),
                onChanged: (_) => errorObs.value = null,
              ),
              const SizedBox(height: 6),
              Text('Long-press any OT cell to edit hours.',
                  style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(dialogCtx)
                          .colorScheme
                          .onSurfaceVariant)),
            ],
          )),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogCtx).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final val = double.tryParse(textCtrl.text.trim());
            if (val == null || val < 0) {
              errorObs.value = 'Enter a valid number';
              return;
            }
            if (val > TeamAttendanceController.kMaxOvertimeHoursPerDay) {
              errorObs.value = 'Max 12 hours';
              return;
            }
            ctrl.setOvertimeHours(workerId, date, val);
            Navigator.of(dialogCtx).pop();
          },
          child: const Text('Set'),
        ),
      ],
    ),
  );
}

// ── Attendance bottom bar ─────────────────────────────────────────────────────

class _AttBottomBar extends StatelessWidget {
  final TeamAttendanceController ctrl;
  final Color accent;
  const _AttBottomBar({required this.ctrl, required this.accent});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: cs.surface,
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
                        style: GoogleFonts.inter(
                            fontSize: 11, color: cs.onSurfaceVariant)),
                    Text(ctrl.formattedWeeklyTotal,
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: accent)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: ctrl.isSubmitting.value
                      ? null
                      : ctrl.submitAttendance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        accent.withValues(alpha: 0.5),
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    ctrl.isSubmitting.value
                        ? 'Saving...'
                        : 'Save Attendance',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyWorkers extends StatelessWidget {
  final Color accent;
  const _EmptyWorkers({required this.accent});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 48, color: cs.onSurfaceVariant),
          const SizedBox(height: 12),
          Text('No active workers',
              style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant)),
          const SizedBox(height: 6),
          Text('Add workers in the Workers tab',
              style: GoogleFonts.inter(
                  fontSize: 12, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ── Worker detail bottom sheet (tap on name in attendance grid) ───────────────

void _showWorkerDetail(
  BuildContext context,
  TeamAttendanceController ctrl,
  TeamWorkerModel worker,
  Color accent,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _WorkerDetailSheet(ctrl: ctrl, worker: worker, accent: accent),
  );
}

class _WorkerDetailSheet extends StatelessWidget {
  final TeamAttendanceController ctrl;
  final TeamWorkerModel worker;
  final Color accent;
  const _WorkerDetailSheet({
    required this.ctrl,
    required this.worker,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final initials = worker.name
        .trim()
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Avatar + name + today's status
          Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: accent.withValues(alpha: 0.3), width: 2),
                ),
                child: Center(
                  child: Text(initials,
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: accent)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(worker.name,
                        style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface)),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(worker.skillType,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: accent)),
                    ),
                  ],
                ),
              ),
              // Today's status cell
              Obx(() {
                final today = DateTime.now();
                final rec = ctrl.getRecord(worker.id, today);
                return _AttStatusCell(
                    status: rec.status, otHours: rec.overtimeHours);
              }),
            ],
          ),
          const SizedBox(height: 16),
          // Info cells
          Row(
            children: [
              _InfoCell(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: worker.phone,
                accent: accent,
              ),
              const SizedBox(width: 12),
              _InfoCell(
                icon: Icons.payments_outlined,
                label: 'Daily Wage',
                value: CurrencyFormatter.formatPKR(worker.dailyWage),
                accent: accent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // This week summary
          Obx(() {
            final present = ctrl.workerPresentDays(worker);
            final absent  = ctrl.workerAbsentDays(worker);
            final half    = ctrl.workerHalfDays(worker);
            final earned  = ctrl.workerWeeklyEarnings(worker);
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? cs.surfaceContainerHighest
                    : accent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: accent.withValues(alpha: 0.14), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('This Week',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _WeekStatChip('$present', 'Present',
                          AppColors.success),
                      const SizedBox(width: 10),
                      _WeekStatChip('$absent', 'Absent', AppColors.error),
                      const SizedBox(width: 10),
                      _WeekStatChip(
                          '$half', 'Half Day', AppColors.warning),
                      const Spacer(),
                      Text(CurrencyFormatter.formatPKR(earned),
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: accent)),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  const _InfoCell({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? cs.surfaceContainerHighest : cs.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: accent),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.inter(
                          fontSize: 9, color: cs.onSurfaceVariant)),
                  Text(value,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekStatChip extends StatelessWidget {
  final String count;
  final String label;
  final Color color;
  const _WeekStatChip(this.count, this.label, this.color);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(count,
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 9,
                  color:
                      Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      );
}

// ── Assignments tab ───────────────────────────────────────────────────────────

class _AssignmentsTab extends StatelessWidget {
  final TeamModel team;
  final Color accent;
  const _AssignmentsTab({required this.team, required this.accent});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (team.assignedProjectIds.isEmpty) {
      return _ComingSoonTab(
          icon: Icons.assignment_outlined,
          title: 'No Assignments',
          body: 'This team has not been assigned to any project yet.',
          accent: accent);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      itemCount: team.assignedProjectIds.length,
      itemBuilder: (context, i) {
        final pid = team.assignedProjectIds[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: accent.withValues(alpha: 0.14), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.folder_rounded, size: 18, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Project ${pid.toUpperCase()}',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface)),
                    Text('Active Assignment',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('ASSIGNED',
                    style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF16A34A))),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Labor Cost tab ────────────────────────────────────────────────────────────

class _LaborCostTab extends StatelessWidget {
  final TeamAttendanceController ctrl;
  final Color accent;
  const _LaborCostTab({required this.ctrl, required this.accent});

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      final start     = ctrl.selectedWeekStart.value;
      final end       = ctrl.weekEnd;
      final weekLabel = start.month == end.month
          ? '${start.day}–${end.day} ${months[start.month - 1]} ${start.year}'
          : '${start.day} ${months[start.month - 1]} – ${end.day} ${months[end.month - 1]}';

      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period label + week nav
            Row(
              children: [
                const _AttWeekNavBtn(isPrev: true),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month_outlined,
                          size: 14, color: cs.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(weekLabel,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                _AttWeekNavBtn(isPrev: false, ctrl: ctrl),
              ],
            ),
            const SizedBox(height: 14),

            // 3 summary cards
            Row(
              children: [
                Expanded(
                  child: _LaborSummaryCard(
                    label: 'Total Cost',
                    value: ctrl.formattedWeeklyTotal,
                    icon: Icons.account_balance_wallet_rounded,
                    color: accent,
                    isDark: isDark, cs: cs,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _LaborSummaryCard(
                    label: 'Present',
                    value: '${ctrl.totalPresentDays} days',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.success,
                    isDark: isDark, cs: cs,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _LaborSummaryCard(
                    label: 'Absent',
                    value: '${ctrl.totalAbsentDays} days',
                    icon: Icons.cancel_rounded,
                    color: AppColors.error,
                    isDark: isDark, cs: cs,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section header
            Row(
              children: [
                Text('Per Worker Breakdown',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface)),
                const Spacer(),
                Text('Tap for date details',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: cs.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 10),

            if (ctrl.workers.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text('No active workers',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: cs.onSurfaceVariant)),
                ),
              )
            else
              ...ctrl.workers.map((w) => _LaborWorkerRow(
                    ctrl: ctrl,
                    worker: w,
                    accent: accent,
                    isDark: isDark,
                    cs: cs,
                  )),

            const SizedBox(height: 8),
            // Estimated payroll footer
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? Color.lerp(cs.surface, accent, 0.08)
                    : accent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: accent.withValues(alpha: 0.20), width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.summarize_rounded, size: 18, color: accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Estimated Weekly Payroll',
                            style: GoogleFonts.inter(
                                fontSize: 11, color: cs.onSurfaceVariant)),
                        Text(ctrl.formattedWeeklyTotal,
                            style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: accent)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${ctrl.totalWorkers} workers',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: cs.onSurfaceVariant)),
                      Text(
                          '${ctrl.totalPresentDays + ctrl.totalHalfDays} effective days',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// Inline week navigation buttons reused inside Labor Cost tab
class _AttWeekNavBtn extends StatelessWidget {
  final bool isPrev;
  final TeamAttendanceController? ctrl;
  const _AttWeekNavBtn({required this.isPrev, this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    if (ctrl == null) {
      // prev button — always enabled
      final c = Get.find<TeamAttendanceController>();
      return GestureDetector(
        onTap: c.prevWeek,
        child: Container(
          width: 36, height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: divider),
          ),
          child: Icon(Icons.chevron_left_rounded,
              size: 18, color: cs.onSurface),
        ),
      );
    }

    return Obx(() => GestureDetector(
          onTap: ctrl!.canGoNext ? ctrl!.nextWeek : null,
          child: Container(
            width: 36, height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ctrl!.canGoNext ? cs.surface : divider,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: divider),
            ),
            child: Icon(Icons.chevron_right_rounded,
                size: 18,
                color: ctrl!.canGoNext
                    ? cs.onSurface
                    : cs.onSurfaceVariant),
          ),
        ));
  }
}

class _LaborSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final ColorScheme cs;
  const _LaborSummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? Color.lerp(cs.surface, color, 0.08)
              : cs.surface,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: color.withValues(alpha: 0.18), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 8),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 9, color: cs.onSurfaceVariant),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      );
}

class _LaborWorkerRow extends StatelessWidget {
  final TeamAttendanceController ctrl;
  final TeamWorkerModel worker;
  final Color accent;
  final bool isDark;
  final ColorScheme cs;
  const _LaborWorkerRow({
    required this.ctrl,
    required this.worker,
    required this.accent,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          _showWorkerCostDetail(context, ctrl, worker, accent),
      child: Obx(() {
        final present = ctrl.workerPresentDays(worker);
        final absent  = ctrl.workerAbsentDays(worker);
        final half    = ctrl.workerHalfDays(worker);
        final earned  = ctrl.workerWeeklyEarnings(worker);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? cs.surfaceContainerHighest.withValues(alpha: 0.5)
                : cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.5),
                width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    worker.name
                        .split(' ')
                        .where((s) => s.isNotEmpty)
                        .take(2)
                        .map((s) => s[0])
                        .join()
                        .toUpperCase(),
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: accent),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(worker.name,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface)),
                    Text(worker.skillType,
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Row(
                children: [
                  _AttBadge('$present', 'P', AppColors.success),
                  const SizedBox(width: 4),
                  _AttBadge('$absent', 'A', AppColors.error),
                  const SizedBox(width: 4),
                  _AttBadge('$half', '½', AppColors.warning),
                ],
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(CurrencyFormatter.formatCompact(earned),
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: accent)),
                  Icon(Icons.chevron_right_rounded,
                      size: 14, color: cs.onSurfaceVariant),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _AttBadge extends StatelessWidget {
  final String count;
  final String label;
  final Color color;
  const _AttBadge(this.count, this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text('$count$label',
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: color)),
      );
}

// ── Worker cost detail sheet (tap on worker row in Labor Cost tab) ─────────────

void _showWorkerCostDetail(
  BuildContext context,
  TeamAttendanceController ctrl,
  TeamWorkerModel worker,
  Color accent,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _WorkerCostDetailSheet(
        ctrl: ctrl, worker: worker, accent: accent),
  );
}

class _WorkerCostDetailSheet extends StatelessWidget {
  final TeamAttendanceController ctrl;
  final TeamWorkerModel worker;
  final Color accent;
  const _WorkerCostDetailSheet({
    required this.ctrl,
    required this.worker,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const dayNames = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu'];

    final initials = worker.name
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0])
        .join()
        .toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Worker header
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(initials,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: accent)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(worker.name,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface)),
                    Text(
                        '${CurrencyFormatter.formatPKR(worker.dailyWage)} / day  ·  ${worker.skillType}',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Obx(() => Text(
                    CurrencyFormatter.formatPKR(
                        ctrl.workerWeeklyEarnings(worker)),
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: accent),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Day-wise breakdown
          Obx(() {
            final days = ctrl.weekDays;
            return Column(
              children: List.generate(days.length, (i) {
                final day    = days[i];
                final rec    = ctrl.getRecord(worker.id, day);
                final otRate = (worker.dailyWage / 8) * 1.5;
                final dayEarned = worker.dailyWage * rec.effectiveDays +
                    otRate * rec.overtimeHours;
                final dayName = dayNames[i];
                final dayDate = '${day.day} ${months[day.month - 1]}';

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? cs.surfaceContainerHighest
                            .withValues(alpha: 0.4)
                        : cs.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 42,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dayName,
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface)),
                            Text(dayDate,
                                style: GoogleFonts.inter(
                                    fontSize: 9,
                                    color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _AttStatusCell(
                          status: rec.status,
                          otHours: rec.overtimeHours),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(rec.statusFullLabel,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: cs.onSurfaceVariant)),
                      ),
                      Text(
                        dayEarned > 0
                            ? CurrencyFormatter.formatPKR(dayEarned)
                            : '—',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: dayEarned > 0
                                ? accent
                                : cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}

// ── Activity tab ──────────────────────────────────────────────────────────────

class _ActivityTab extends StatelessWidget {
  final Color accent;
  const _ActivityTab({required this.accent});

  @override
  Widget build(BuildContext context) => _ComingSoonTab(
      icon: Icons.history_rounded,
      title: 'Activity Log',
      body: 'Team activities, changes, and updates will be tracked here.',
      accent: accent);
}

// ── Coming-soon placeholder ───────────────────────────────────────────────────

class _ComingSoonTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color accent;

  const _ComingSoonTab({
    required this.icon,
    required this.title,
    required this.body,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: accent),
            ),
            const SizedBox(height: 14),
            Text(title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface)),
            const SizedBox(height: 8),
            Text(body,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 12, height: 1.6, color: cs.onSurfaceVariant)),
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: accent.withValues(alpha: 0.20), width: 1),
              ),
              child: Text('Coming Soon',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: accent)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Team options bottom sheet ─────────────────────────────────────────────────

class _TeamOptionsSheet extends StatelessWidget {
  final TeamModel team;
  const _TeamOptionsSheet({required this.team});

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final accent = _typeAccent(team.type);
    final options = [
      (Icons.person_add_alt_1_rounded, 'Add Worker', accent),
      (Icons.assignment_add, 'Assign to Project',
          const Color(0xFF3B82F6)),
      (Icons.edit_outlined, 'Edit Team', cs.onSurfaceVariant),
      (Icons.delete_outline_rounded, 'Delete Team',
          const Color(0xFFEF4444)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ...options.map((opt) {
            final (icon, label, color) = opt;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              title: Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: label == 'Delete Team'
                          ? const Color(0xFFEF4444)
                          : cs.onSurface)),
              onTap: () {
                Get.back();
                if (label == 'Add Worker') {
                  Get.toNamed('/teams/add-worker', arguments: team);
                } else if (label == 'Delete Team') {
                  _confirmDelete(context);
                }
              },
            );
          }),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Team',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to delete "${team.name}"? This action cannot be undone.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.find<TeamController>().deleteTeam(team.id);
              Get.back();
              Get.back();
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }
}
