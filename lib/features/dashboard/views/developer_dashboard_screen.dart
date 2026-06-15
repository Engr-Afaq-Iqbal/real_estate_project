import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/dashboard_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../widgets/dashboard_header_widget.dart';
import '../widgets/dashboard_portfolio_widget.dart';
import '../widgets/dashboard_estimator_widget.dart';
import '../widgets/dashboard_market_prices_widget.dart';
import '../widgets/dashboard_todays_alert_widget.dart';
import '../../projects/data/models/project_model.dart';
import '../../shell/controllers/shell_controller.dart';
import '../../tasks/controllers/tasks_controller.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_card.dart';
import '../../../presentation/widgets/common/app_loading.dart';
import '../../../presentation/routes/app_routes.dart';
import '../../../presentation/widgets/common/error_state_widget.dart';

// ── Architecture note ─────────────────────────────────────────────────────────
// Customer and Contractor dashboards are fully separate screens with separate
// navigation entry points (AppRoutes.homeownerDashboard vs .developerDashboard).
// Both currently share DashboardController and TasksController because they load
// the same mock data. In production, those controllers must accept a userId /
// role parameter and filter all queries server-side, ensuring no cross-role
// project or task leakage. The UI layer already enforces separation by rendering
// different screens for each role.

// ── Project status helpers ────────────────────────────────────────────────────

const _kOnTrack   = Color(0xFF16A34A);
const _kAtRisk    = Color(0xFFF59E0B);
const _kLate      = Color(0xFFEF4444);
const _kOnHold    = Color(0xFF6B7280);
const _kCompleted = Color(0xFF0D9488);

Color _projectAccent(ProjectModel p) {
  if (p.isLate)      return _kLate;
  if (p.isAtRisk)    return _kAtRisk;
  if (p.isCompleted) return _kCompleted;
  if (p.isOnHold)    return _kOnHold;
  return _kOnTrack;
}

String _projectStatusText(ProjectModel p) {
  if (p.isLate)      return 'LATE';
  if (p.isAtRisk)    return 'AT RISK';
  if (p.isCompleted) return 'DONE';
  if (p.isOnHold)    return 'ON HOLD';
  return 'ACTIVE';
}

IconData _projectTypeIcon(String type) => switch (type) {
      'commercial' => Icons.business_rounded,
      'renovation' => Icons.home_repair_service_rounded,
      'apartment'  => Icons.apartment_rounded,
      _            => Icons.home_work_rounded,
    };

String _relativeTime(DateTime? dt) {
  if (dt == null) return '—';
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24)   return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

void _goToProjectsTab() {
  if (Get.isRegistered<ShellController>()) {
    Get.find<ShellController>().changeTab(1);
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class DeveloperDashboardScreen extends GetView<DashboardController> {
  const DeveloperDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Fixed header — identical structure to customer dashboard ────
            DashboardHeaderWidget(auth: auth, controller: controller),

            // ── Scrollable body ────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }
                if (controller.hasLoadError.value) {
                  return ErrorStateWidget(onRetry: controller.loadDashboard);
                }
                return RefreshIndicator(
                  onRefresh: controller.loadDashboard,
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: AppDimensions.xxxl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Today's Alert — widget owns its own horizontal
                        // padding (same as customer dashboard)
                        const DashboardTodaysAlertWidget(),
                        const SizedBox(height: 16),

                        // All other sections share page-level padding
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.pagePaddingH),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Summary stats ─────────────────────────
                              _StatsRow(
                                active: controller.activeProjects.length,
                                done: controller.projects
                                    .where((p) => p.status == 'completed')
                                    .length,
                                workers: controller.projects
                                    .fold(0, (s, p) => s + p.workerCount),
                              ),
                              const SizedBox(height: AppDimensions.xl),

                              // ── Portfolio budget overview ──────────────
                              _PortfolioBudgetCard(
                                  projects: controller.projects),
                              const SizedBox(height: AppDimensions.xl),

                              // ── Per-project finance cards ──────────────
                              DashboardPortfolioWidget(
                                  controller: controller),
                              if (controller.activeProjects.length >= 2)
                                const SizedBox(height: AppDimensions.xl),

                              // ── Active projects (3 most recent) ───────
                              _buildActiveProjectsSection(context),
                              const SizedBox(height: AppDimensions.xl),

                              // ── Market rates ───────────────────────────
                              DashboardMarketPricesWidget(
                                  controller: controller),
                              const SizedBox(height: AppDimensions.xl),

                              // ── Construction cost estimator ────────────
                              const DashboardEstimatorWidget(),
                            ],
                          ),
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

  Widget _buildActiveProjectsSection(BuildContext context) {
    final cs       = Theme.of(context).colorScheme;
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
                  Text('active_projects'.tr, style: AppTextStyles.h3(context)),
                  const SizedBox(width: 8),
                  if (total > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.10),
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
                  Text('see_all'.tr,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent)),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 10, color: AppColors.accent),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.md),

        if (projects.isEmpty)
          _ActiveProjectsEmptyCard()
        else ...[
          ...projects.map((p) => _ContractorProjectCard(project: p)),
          if (total > 3) ...[
            const SizedBox(height: 4),
            _ViewAllBanner(remaining: total - 3),
          ],
        ],
      ],
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int active;
  final int done;
  final int workers;

  const _StatsRow({
    required this.active,
    required this.done,
    required this.workers,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.base),
      child: Row(
        children: [
          Expanded(
            child: _StatCell(
              value: '$active',
              label: 'active'.tr,
              color: AppColors.primary,
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.dividerLight),
          Expanded(
            child: _StatCell(
              value: '$done',
              label: 'done_label'.tr,
              color: AppColors.success,
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.dividerLight),
          Expanded(
            child: _StatCell(
              value: '$workers',
              label: 'Workers',
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCell(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: AppTextStyles.caption(context)),
      ],
    );
  }
}

// ── Portfolio budget card ─────────────────────────────────────────────────────

class _PortfolioBudgetCard extends StatelessWidget {
  final List<ProjectModel> projects;
  const _PortfolioBudgetCard({required this.projects});

  @override
  Widget build(BuildContext context) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final totalBudget = projects.fold(0.0, (s, p) => s + p.totalBudget);
    final totalSpent  = projects.fold(0.0, (s, p) => s + p.spentBudget);
    final progress    = totalBudget > 0 ? totalSpent / totalBudget : 0.0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PORTFOLIO BUDGET', style: AppTextStyles.overline(context)),
          const SizedBox(height: AppDimensions.xs),
          Row(
            children: [
              Text(CurrencyFormatter.formatCompact(totalSpent),
                  style: AppTextStyles.amountLarge(context)),
              const Spacer(),
              Text('of ${CurrencyFormatter.formatCompact(totalBudget)}',
                  style: AppTextStyles.caption(context)),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: AppDimensions.progressBarHeightLg,
              backgroundColor:
                  isDark ? AppColors.borderDark : AppColors.dividerLight,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% spent across '
            '${projects.length} project${projects.length == 1 ? '' : 's'}',
            style: AppTextStyles.caption(context),
          ),
        ],
      ),
    );
  }
}

// ── Contractor project card (premium) ────────────────────────────────────────

class _ContractorProjectCard extends StatefulWidget {
  final ProjectModel project;
  const _ContractorProjectCard({required this.project});

  @override
  State<_ContractorProjectCard> createState() => _ContractorProjectCardState();
}

class _ContractorProjectCardState extends State<_ContractorProjectCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p      = widget.project;
    final accent = _projectAccent(p);
    final pct    = p.progress.clamp(0.0, 1.0);

    final budgetPct   = p.totalBudget > 0 ? p.spentBudget / p.totalBudget : 0.0;
    final budgetColor = budgetPct > 0.90
        ? _kLate
        : budgetPct > 0.75
            ? _kAtRisk
            : _kOnTrack;

    final daysLeft  = p.targetEndDate?.difference(DateTime.now()).inDays;
    final timeColor = (daysLeft != null && daysLeft < 0)
        ? _kLate
        : (daysLeft != null && daysLeft <= 14)
            ? _kAtRisk
            : _kOnTrack;

    final bgColor =
        isDark ? Color.lerp(cs.surface, accent, 0.05)! : cs.surface;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Get.toNamed(AppRoutes.projectStageTracker, arguments: p);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: accent.withValues(alpha: isDark ? 0.22 : 0.14),
                width: 1),
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
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: icon + name + status badge
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
                            child: Icon(_projectTypeIcon(p.type),
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
                                        shape: BoxShape.circle)),
                                const SizedBox(width: 4),
                                Text(_projectStatusText(p),
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
                      const SizedBox(height: 10),

                      // Row 2: stage + last updated
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
                      const SizedBox(height: 10),

                      // Row 3: progress bar
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 7,
                                backgroundColor: accent.withValues(
                                    alpha: isDark ? 0.18 : 0.10),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(accent),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('${(pct * 100).toStringAsFixed(0)}%',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: accent)),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Row 4: stats + view link
                      Row(
                        children: [
                          _CardStat(
                            icon: Icons.account_balance_wallet_outlined,
                            value: CurrencyFormatter.formatCompact(
                                p.spentBudget,
                                currency: p.currencyCode),
                            sub: '/ ${CurrencyFormatter.formatCompact(p.totalBudget, currency: p.currencyCode)}',
                            color: budgetColor,
                          ),
                          _vDivider(context),
                          _CardStat(
                            icon: Icons.people_alt_outlined,
                            value: '${p.workerCount}',
                            sub: 'workers',
                            color: cs.onSurfaceVariant,
                          ),
                          _vDivider(context),
                          _CardStat(
                            icon: Icons.calendar_today_rounded,
                            value: daysLeft == null
                                ? '—'
                                : daysLeft < 0
                                    ? '${(-daysLeft)}d'
                                    : '${daysLeft}d',
                            sub: daysLeft != null && daysLeft < 0
                                ? 'overdue'
                                : 'left',
                            color: timeColor,
                          ),
                          const Spacer(),
                          Row(
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
      height: 26,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
    );

class _CardStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String sub;
  final Color color;

  const _CardStat({
    required this.icon,
    required this.value,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(height: 2),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        Text(sub,
            style: GoogleFonts.inter(
                fontSize: 9,
                color: cs.onSurfaceVariant.withValues(alpha: 0.65))),
      ],
    );
  }
}

// ── Empty state for active projects ──────────────────────────────────────────

class _ActiveProjectsEmptyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: cs.primary.withValues(alpha: 0.10), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.construction_rounded,
              size: 32, color: cs.primary.withValues(alpha: 0.45)),
          const SizedBox(height: 8),
          Text('No active projects',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text('Projects in progress will appear here',
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}

// ── View all banner ───────────────────────────────────────────────────────────

class _ViewAllBanner extends StatelessWidget {
  final int remaining;
  const _ViewAllBanner({required this.remaining});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _goToProjectsTab();
      },
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
            Icon(Icons.grid_view_rounded, size: 13, color: cs.primary),
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
