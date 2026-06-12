import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../projects/data/models/project_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../presentation/routes/app_routes.dart';
import '../../../presentation/widgets/common/animated_counter.dart';

Color _primaryText(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Theme.of(context).colorScheme.primary;

/// Featured/hero project card showing completion, weeks left, and spend.
class DashboardProjectHighlightCard extends StatelessWidget {
  final ProjectModel project;
  const DashboardProjectHighlightCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Active Project',
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface)),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.myProjects),
              child: Text('View All →',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _primaryText(context))),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () =>
              Get.toNamed(AppRoutes.projectStageTracker, arguments: project),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.primary,
                  Color.lerp(cs.primary, Colors.blue, 0.3) ?? cs.primary,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: Colors.white70),
                    const SizedBox(width: 3),
                    Text('${project.area}, ${project.city}',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.7))),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(project.statusLabel,
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(project.name,
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2)),
                const SizedBox(height: 4),
                Text(project.currentStage.toUpperCase(),
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: Colors.white.withValues(alpha: 0.7))),
                const SizedBox(height: 14),
                Row(
                  children: [
                    // POLISH 2: count-up animation for completion percentage
                    _AnimatedStatPill(
                        value: project.completionPct,
                        label: 'Done'),
                    const SizedBox(width: 8),
                    _StatPill(
                        value: '${project.weeksLeft} wk',
                        label: 'Left'),
                    const SizedBox(width: 8),
                    _StatPill(
                        value: CurrencyFormatter.formatLakh(
                            project.spentBudget),
                        label: 'Spent'),
                  ],
                ),
                const SizedBox(height: 14),
                // POLISH 2: animated progress bar
                AnimatedProgressBar(
                  value: project.progress,
                  minHeight: 5,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: Colors.white,
                  duration: const Duration(milliseconds: 900),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  const _StatPill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1)),
              const SizedBox(height: 1),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.7))),
            ],
          ),
        ),
      );
}

// POLISH 2: Animated stat pill that counts up from 0 to value
class _AnimatedStatPill extends StatelessWidget {
  final double value;
  final String label;
  const _AnimatedStatPill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedCounter(
                value: value,
                formatter: (v) => '${v.toInt()}%',
                duration: const Duration(milliseconds: 700),
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1),
              ),
              const SizedBox(height: 1),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.7))),
            ],
          ),
        ),
      );
}
