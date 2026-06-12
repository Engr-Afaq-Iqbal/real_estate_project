import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/dashboard_controller.dart';
import '../../projects/data/models/project_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../presentation/routes/app_routes.dart';

const _kSuccess = Color(0xFF16A34A);
const _kError   = Color(0xFFEF4444);
const _kWarning = Color(0xFFF59E0B);

/// Portfolio overview — shown when the user has 2+ active projects.
/// Contains: horizontal project-finance cards + consolidated summary card
/// + "View Full Report" button that opens an fl_chart modal.
class DashboardPortfolioWidget extends StatelessWidget {
  final DashboardController controller;
  const DashboardPortfolioWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs       = Theme.of(context).colorScheme;
    final projects = controller.activeProjects;
    if (projects.length < 2) return const SizedBox.shrink();

    final totalBudget = projects.fold(0.0, (s, p) => s + p.budgetAmount);
    final totalSpent  = projects.fold(0.0, (s, p) => s + p.actualCost);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Expanded(
              child: Text('Portfolio Overview',
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface)),
            ),
            GestureDetector(
              onTap: () => _showFullReport(context, projects),
              child: Text('View Full Report →',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: cs.primary)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal scroll of compact cards
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: projects.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) =>
                _ProjectFinanceCard(project: projects[i]),
          ),
        ),
        const SizedBox(height: 12),

        // Consolidated summary card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cs.primary,
                Color.lerp(cs.primary, const Color(0xFF1D4ED8), 0.4)!,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Active Budget',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.75))),
                    Text(CurrencyFormatter.formatPKR(totalBudget),
                        style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    Text('across ${projects.length} projects',
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.6))),
                  ],
                ),
              ),
              Container(width: 1, height: 44,
                  color: Colors.white.withValues(alpha: 0.25)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Spent',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.75))),
                    Text(CurrencyFormatter.formatPKR(totalSpent),
                        style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    Text(
                      '${totalBudget > 0 ? (totalSpent / totalBudget * 100).toStringAsFixed(0) : 0}% of budget',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Full report CTA
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showFullReport(context, projects),
            icon: const Icon(Icons.bar_chart_rounded, size: 16),
            label: const Text('View Full Financial Report'),
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.primary,
              side: BorderSide(color: cs.primary.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _showFullReport(BuildContext context, List<ProjectModel> projects) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FullReportSheet(projects: projects),
    );
  }
}

// ── Compact project finance card ──────────────────────────────────────────────

class _ProjectFinanceCard extends StatelessWidget {
  final ProjectModel project;
  const _ProjectFinanceCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;
    final pct    = project.budgetAmount > 0
        ? (project.actualCost / project.budgetAmount).clamp(0.0, 1.0)
        : 0.0;
    final barColor = pct > 0.8 ? _kError : pct > 0.6 ? _kWarning : _kSuccess;

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.projectStageTracker,
          arguments: project),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project.name.split(' — ').first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: cs.onSurface)),
            const SizedBox(height: 3),
            Text(CurrencyFormatter.formatPKR(project.budgetAmount),
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: cs.primary)),
            const Spacer(),
            Row(
              children: [
                Text('Spent',
                    style: GoogleFonts.inter(
                        fontSize: 10, color: cs.onSurfaceVariant)),
                const Spacer(),
                Text('${(pct * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: barColor)),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 5,
                backgroundColor: divider,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Full report modal with fl_chart bar chart ─────────────────────────────────

class _FullReportSheet extends StatelessWidget {
  final List<ProjectModel> projects;
  const _FullReportSheet({required this.projects});

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final height = MediaQuery.of(context).size.height * 0.88;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text('Financial Report',
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w700,
                          color: cs.onSurface)),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close_rounded,
                      size: 22, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bar chart
                  Text('Budget vs Spent per Project',
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: cs.onSurface)),
                  const SizedBox(height: 4),
                  Text('Values in PKR Lakh',
                      style: GoogleFonts.inter(
                          fontSize: 10, color: cs.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: _ProjectBarChart(projects: projects),
                  ),
                  const SizedBox(height: 8),
                  // Legend
                  Row(
                    children: [
                      _LegendDot(color: cs.primary, label: 'Budget'),
                      const SizedBox(width: 16),
                      const _LegendDot(color: _kSuccess, label: 'Spent'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Per-project detail table
                  Text('Project Breakdown',
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: cs.onSurface)),
                  const SizedBox(height: 10),
                  ...projects.map((p) => _ProjectReportRow(project: p)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 5),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      );
}

class _ProjectBarChart extends StatelessWidget {
  final List<ProjectModel> projects;
  const _ProjectBarChart({required this.projects});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Normalise to Lakh for readable axis
    final groups = projects.asMap().entries.map((e) {
      final i = e.key;
      final p = e.value;
      final budgetL = p.budgetAmount / 100000;
      final spentL  = p.actualCost   / 100000;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: budgetL,
            color: cs.primary,
            width: 14,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: spentL,
            color: _kSuccess,
            width: 14,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4)),
          ),
        ],
        barsSpace: 4,
      );
    }).toList();

    final maxY = projects.fold(0.0, (m, p) =>
        p.budgetAmount / 100000 > m ? p.budgetAmount / 100000 : m);

    return BarChart(
      BarChartData(
        maxY: (maxY * 1.25).ceilToDouble(),
        barGroups: groups,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Theme.of(context).dividerColor,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (v, _) => Text(
                '${v.toInt()}L',
                style: GoogleFonts.inter(
                    fontSize: 9, color: cs.onSurfaceVariant),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= projects.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    projects[i].name.split(' — ').first.split(' ').first,
                    style: GoogleFonts.inter(
                        fontSize: 8, color: cs.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, _, rod, rodIndex) {
              final label = rodIndex == 0 ? 'Budget' : 'Spent';
              return BarTooltipItem(
                '$label\n${rod.toY.toStringAsFixed(1)}L',
                GoogleFonts.inter(fontSize: 10, color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProjectReportRow extends StatelessWidget {
  final ProjectModel project;
  const _ProjectReportRow({required this.project});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;
    final pct = project.budgetAmount > 0
        ? (project.actualCost / project.budgetAmount * 100)
            .toStringAsFixed(0)
        : '0';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: divider),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(project.name.split(' — ').first,
                    style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: cs.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(project.currentStage,
                    style: GoogleFonts.inter(
                        fontSize: 10, color: cs.onSurfaceVariant),
                    maxLines: 1),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(CurrencyFormatter.formatPKR(project.budgetAmount),
                    style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: cs.onSurface)),
                Text('$pct% used',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        color: int.parse(pct) > 80 ? _kError : _kSuccess)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
