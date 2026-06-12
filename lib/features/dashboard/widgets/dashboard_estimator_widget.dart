import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../presentation/routes/app_routes.dart';

/// Construction Cost Estimator — dashboard section.
///
/// Replaces the old "Estimate" quick-action (which navigated to the
/// CalculatorHubScreen) with a compact, premium-feel section embedded
/// directly on the Home Dashboard. Each mini-card opens its estimation
/// flow in one tap.
class DashboardEstimatorWidget extends StatelessWidget {
  const DashboardEstimatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: cs.onSurface.withValues(alpha: isDark ? 0.0 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.primary,
                      Color.lerp(cs.primary, const Color(0xFF1D4ED8), 0.5)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calculate_rounded,
                    size: 18, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Construction Cost Estimator',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface)),
                    Text('Estimate materials & cost in minutes',
                        style: GoogleFonts.inter(
                            fontSize: 10.5, color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              // Premium badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 10, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 3),
                    Text('SMART TOOLS',
                        style: GoogleFonts.inter(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            color: const Color(0xFFF59E0B))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Estimation options ────────────────────────────────────────
          _EstimatorOptionCard(
            index: 0,
            icon: Icons.maps_home_work_rounded,
            color: cs.primary,
            title: 'Area-Based Estimation',
            description:
                'Enter plot size, covered area, floors & rooms to estimate materials and cost.',
            ctaLabel: 'Start',
            onTap: () => Get.toNamed(AppRoutes.areaEstimator),
          ),
          const SizedBox(height: 8),
          _EstimatorOptionCard(
            index: 1,
            icon: Icons.auto_awesome_mosaic_rounded,
            color: const Color(0xFF0D9488),
            badge: 'AI',
            title: 'AI-Powered Floor Plan Estimator',
            description:
                'Upload floor plans and get intelligent material & cost estimations.',
            ctaLabel: 'Upload',
            onTap: () => Get.toNamed(AppRoutes.floorPlanEstimator),
          ),
          const SizedBox(height: 8),
          _EstimatorOptionCard(
            index: 2,
            icon: Icons.table_chart_rounded,
            color: const Color(0xFF7C3AED),
            title: 'Material Cost Calculator',
            description:
                'Total construction cost from material quantities at latest market prices.',
            ctaLabel: 'Open',
            onTap: () => Get.toNamed(AppRoutes.materialCostCalc),
          ),
        ],
      ),
    );
  }
}

/// One tappable estimation option row — icon, title, description, CTA chip.
/// Animates in with a staggered fade/slide and scales down while pressed.
class _EstimatorOptionCard extends StatefulWidget {
  final int index;
  final IconData icon;
  final Color color;
  final String? badge;
  final String title;
  final String description;
  final String ctaLabel;
  final VoidCallback onTap;

  const _EstimatorOptionCard({
    required this.index,
    required this.icon,
    required this.color,
    this.badge,
    required this.title,
    required this.description,
    required this.ctaLabel,
    required this.onTap,
  });

  @override
  State<_EstimatorOptionCard> createState() => _EstimatorOptionCardState();
}

class _EstimatorOptionCardState extends State<_EstimatorOptionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + widget.index * 120),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - t)),
          child: child,
        ),
      ),
      child: Semantics(
        label: widget.title,
        button: true,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) {
            setState(() => _pressed = false);
            HapticFeedback.lightImpact();
            widget.onTap();
          },
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: widget.color.withValues(alpha: 0.18)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(widget.icon, size: 21, color: widget.color),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(widget.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: cs.onSurface)),
                            ),
                            if (widget.badge != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: widget.color,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(widget.badge!,
                                    style: GoogleFonts.inter(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(widget.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                                fontSize: 10.5,
                                height: 1.35,
                                color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // CTA chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.ctaLabel,
                            style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        const SizedBox(width: 3),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 12, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
