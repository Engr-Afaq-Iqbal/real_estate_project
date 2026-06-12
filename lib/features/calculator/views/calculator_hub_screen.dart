// ═════════════════════════════════════════════════════════════════════════════
// DEPRECATED — for current release. Cost Calculator functionality has been
// moved to the Home Dashboard estimator section (DashboardEstimatorWidget in
// lib/features/dashboard/widgets/dashboard_estimator_widget.dart).
//
// Preserve this screen for future enhancements and possible reactivation.
//
// To reactivate:
//   1. Uncomment this entire file (remove the /* ... */ wrapper below).
//   2. Restore the import and the AppRoutes.calculatorHub GetPage entry in
//      lib/presentation/routes/app_pages.dart (both are commented out there).
//   3. Re-add a navigation entry point (e.g. the "Estimate" quick-action tile
//      in lib/features/dashboard/widgets/dashboard_quick_actions_widget.dart).
// ═════════════════════════════════════════════════════════════════════════════

/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../presentation/routes/app_routes.dart';
import '../../../presentation/theme/app_colors.dart';

class CalculatorHubScreen extends StatelessWidget {
  const CalculatorHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroHeader(cs: cs),
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section label
                    Row(
                      children: [
                        Container(
                          width: 3, height: 16,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Choose Estimation Method',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurfaceVariant,
                                letterSpacing: 0.3)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Option 1: Area-Based ───────────────────────────────
                    _BigOptionCard(
                      gradient: LinearGradient(
                        colors: [cs.primary, Color.lerp(cs.primary, const Color(0xFF1D4ED8), 0.5)!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      icon: Icons.apartment_rounded,
                      badge: 'MOST POPULAR',
                      badgeColor: Colors.white.withValues(alpha: 0.25),
                      title: 'Area-Based Estimator',
                      subtitle: 'Fill in your floor plan room by room — bedrooms, kitchens, washrooms, height — and get a full material & cost breakdown.',
                      features: const [
                        '🏙️  Select your city for accurate prices',
                        '🏢  Floor-by-floor room details',
                        '📐  Covers area, height & extras',
                        '💰  Full material & labour cost report',
                      ],
                      buttonLabel: 'Start Estimation →',
                      onTap: () => Get.toNamed(AppRoutes.areaEstimator),
                    ),
                    const SizedBox(height: 14),

                    // ── Option 2: Floor Plan Upload ────────────────────────
                    _BigOptionCard(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      icon: Icons.upload_file_rounded,
                      badge: 'AI-POWERED',
                      badgeColor: Colors.white.withValues(alpha: 0.25),
                      title: 'Floor Plan Upload',
                      subtitle: 'Upload your architectural drawings (PDF/JPG/PNG) and let the system analyze and estimate materials automatically.',
                      features: const [
                        '📄  Supports PDF, JPG, PNG plans',
                        '🔄  Upload multiple floor plans',
                        '🤖  Auto-analysis & estimation',
                        '📊  Floor-wise cost breakdown',
                      ],
                      buttonLabel: 'Upload Floor Plans →',
                      onTap: () => Get.toNamed(AppRoutes.floorPlanEstimator),
                    ),
                    const SizedBox(height: 14),

                    // ── Option 3: Material Cost Calculator ────────────────
                    _BigOptionCard(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      icon: Icons.table_chart_rounded,
                      badge: 'SIMPLEST',
                      badgeColor: Colors.white.withValues(alpha: 0.25),
                      title: 'Material Cost Calculator',
                      subtitle: 'Spreadsheet-style calculator. Enter quantities for any material, prices auto-fill from today\'s market, totals calculate instantly.',
                      features: const [
                        '📋  20+ materials pre-loaded',
                        '🏙️  City-wise live prices',
                        '⚡  Instant live total calculation',
                        '➕  Add your own custom materials',
                      ],
                      buttonLabel: 'Open Calculator →',
                      onTap: () => Get.toNamed(AppRoutes.materialCostCalc),
                    ),
                    const SizedBox(height: 24),

                    // ── Market prices link ─────────────────────────────────
                    _MarketPricesBanner(cs: cs),
                    const SizedBox(height: 14),

                    // ── Other tools ────────────────────────────────────────
                    Text("Other Tools",
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurfaceVariant)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _SmallToolCard(
                            icon: Icons.trending_up_rounded,
                            color: const Color(0xFFF59E0B),
                            label: 'What-If\nScenarios',
                            onTap: () => Get.toNamed(AppRoutes.whatIfCalculator),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SmallToolCard(
                            icon: Icons.home_work_outlined,
                            color: AppColors.primary,
                            label: 'Quick\nEstimator',
                            onTap: () => Get.toNamed(AppRoutes.houseEstimator),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SmallToolCard(
                            icon: Icons.bookmark_rounded,
                            color: const Color(0xFF16A34A),
                            label: 'Saved\nEstimates',
                            onTap: () => Get.toNamed(AppRoutes.savedCalculations),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
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

// ── Hero header ───────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final ColorScheme cs;
  const _HeroHeader({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary,
            Color.lerp(cs.primary, const Color(0xFF0EA5E9), 0.4)!,
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
                child: Text('Cost Calculator',
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.marketPrices),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bar_chart_rounded, size: 13, color: Colors.white),
                      const SizedBox(width: 4),
                      Text("Prices",
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
          const SizedBox(height: 20),
          Text('Build smarter,\nnot harder.',
              style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2)),
          const SizedBox(height: 8),
          Text('3 ways to estimate your construction cost.\nChoose what works best for you.',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.5)),
          const SizedBox(height: 16),
          // 3 step pills
          Row(
            children: [
              _StepPill(number: '1', label: 'Area-Based'),
              const SizedBox(width: 8),
              _StepPill(number: '2', label: 'Floor Plan'),
              const SizedBox(width: 8),
              _StepPill(number: '3', label: 'Materials'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  final String number;
  final String label;
  const _StepPill({required this.number, required this.label});

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
            Container(
              width: 16, height: 16,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(number,
                    style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E3A8A))),
              ),
            ),
            const SizedBox(width: 5),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ],
        ),
      );
}

// ── Big option card ───────────────────────────────────────────────────────────

class _BigOptionCard extends StatelessWidget {
  final LinearGradient gradient;
  final IconData icon;
  final String badge;
  final Color badgeColor;
  final String title;
  final String subtitle;
  final List<String> features;
  final String buttonLabel;
  final VoidCallback onTap;

  const _BigOptionCard({
    required this.gradient,
    required this.icon,
    required this.badge,
    required this.badgeColor,
    required this.title,
    required this.subtitle,
    required this.features,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circle
            Positioned(
              top: -20, right: -20,
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -30, right: 30,
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(icon, size: 26, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: badgeColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(badge,
                                  style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.5)),
                            ),
                            const SizedBox(height: 4),
                            Text(title,
                                style: GoogleFonts.inter(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.1)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.5)),
                  const SizedBox(height: 14),
                  // Feature bullets
                  ...features.map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(f,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.3)),
                      )),
                  const SizedBox(height: 16),
                  // CTA button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(buttonLabel,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: gradient.colors.first)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Market prices banner ──────────────────────────────────────────────────────

class _MarketPricesBanner extends StatelessWidget {
  final ColorScheme cs;
  const _MarketPricesBanner({required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.marketPrices),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bar_chart_rounded,
                  size: 20, color: Color(0xFFF59E0B)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Today's Market Prices",
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface)),
                  Text('Live cement, steel, sand & 17 more materials',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Color(0xFFF59E0B)),
          ],
        ),
      ),
    );
  }
}

// ── Small tool card ───────────────────────────────────────────────────────────

class _SmallToolCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _SmallToolCard(
      {required this.icon,
      required this.color,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
                color: cs.onSurface.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                    height: 1.3)),
          ],
        ),
      ),
    );
  }
}
*/
