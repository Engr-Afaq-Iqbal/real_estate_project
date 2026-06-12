// ═════════════════════════════════════════════════════════════════════════════
// Feature temporarily disabled. Quick Estimator widget preserved for future
// implementation.
//
// This section (including its "Full Estimate" button → HouseEstimatorScreen)
// was removed from the Home Dashboard. The related DashboardController logic
// (calcExpanded, runQuickEstimate, etc.) is intentionally untouched.
//
// To reactivate:
//   1. Uncomment this entire file (remove the /* ... */ wrapper below).
//   2. Restore the import + usage in homeowner_dashboard_screen.dart.
//   3. If the "Full Estimate" button is needed, also restore the
//      AppRoutes.houseEstimator GetPage in app_pages.dart and the
//      HouseEstimatorScreen (both commented out).
// ═════════════════════════════════════════════════════════════════════════════

/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/dashboard_controller.dart';
import '../../market/controllers/market_controller.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../presentation/routes/app_routes.dart';

/// Quick Estimator / calculator panel (gradient card with expandable form).
/// Mapped to "QuickStatsWidget" in the spec — it shows live cost estimates.
class DashboardQuickStatsWidget extends StatelessWidget {
  final DashboardController controller;
  const DashboardQuickStatsWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Obx(() {
      final expanded = controller.calcExpanded.value;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primary,
              Color.lerp(cs.primary, Colors.blue, 0.3) ?? cs.primary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.calculate_outlined,
                      size: 16, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Quick Estimator',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
                GestureDetector(
                  onTap: () {
                    controller.toggleCalcWidget();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(expanded ? 'Close' : 'Calculate',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
            if (!expanded) ...[
              const SizedBox(height: 10),
              Text('Estimate any construction cost instantly.',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7))),
              const SizedBox(height: 10),
              Row(
                children: const [
                  _MiniPricePill('Steel', '262/kg'),
                  SizedBox(width: 8),
                  _MiniPricePill('Cement', '1,280/bag'),
                  SizedBox(width: 8),
                  _MiniPricePill('Sand', '55/cft'),
                ],
              ),
            ],
            if (expanded) ...[
              const SizedBox(height: 16),
              // Market-aware input unit label
              Builder(builder: (ctx) {
                final inputLabel = Get.isRegistered<MarketController>()
                    ? Get.find<MarketController>().estimatorInputLabel
                    : 'Marla';
                return _CalcInputRow(
                  label: 'Area ($inputLabel)',
                  hint: 'e.g. 5',
                  suffix: inputLabel,
                  onChanged: (v) {
                    controller.calcAreaCtrl.value = v;
                    controller.runQuickEstimate(v);
                  },
                );
              }),      // end Builder
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Floors',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8))),
                  const SizedBox(width: 12),
                  ...List.generate(3, (i) {
                    final f = i + 1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          controller.calcFloors.value = f;
                          controller.runQuickEstimate(
                              controller.calcAreaCtrl.value);
                        },
                        child: Obx(() => Container(
                              width: 32, height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: controller.calcFloors.value == f
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('$f',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: controller.calcFloors.value == f
                                        ? cs.primary
                                        : Colors.white,
                                  )),
                            )),
                      ),
                    );
                  }),
                  const Spacer(),
                  Obx(() => GestureDetector(
                        onTap: () {
                          final tiers = ['economy', 'standard', 'premium'];
                          final idx = tiers.indexOf(
                              controller.calcQuality.value);
                          controller.calcQuality.value =
                              tiers[(idx + 1) % tiers.length];
                          controller.runQuickEstimate(
                              controller.calcAreaCtrl.value);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _qualityLabel(controller.calcQuality.value),
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.swap_horiz_rounded,
                                  size: 14, color: Colors.white70),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 14),
              Obx(() {
                final est = controller.quickEstimate.value;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: est != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Estimated Cost',
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.7))),
                            const SizedBox(height: 4),
                            Text(
                              // Use market-aware format if controller available
                              Get.isRegistered<MarketController>()
                                  ? Get.find<MarketController>().formatAmount(est)
                                  : CurrencyFormatter.formatPKR(est),
                              style: GoogleFonts.inter(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white),
                            ),
                          ],
                        )
                      : Text('Enter plot size above to see estimate',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.6))),
                );
              }),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.houseEstimator),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('Full Estimate',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.newProjectWizard),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('Create Project',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: cs.primary)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  static String _qualityLabel(String tier) => switch (tier) {
        'economy' => 'Economy',
        'premium' => 'Premium',
        _         => 'Standard',
      };
}

class _MiniPricePill extends StatelessWidget {
  final String label;
  final String value;
  const _MiniPricePill(this.label, this.value);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text('$label: $value',
            style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.8))),
      );
}

class _CalcInputRow extends StatelessWidget {
  final String label;
  final String hint;
  final String suffix;
  final void Function(String) onChanged;

  const _CalcInputRow({
    required this.label,
    required this.hint,
    required this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: onChanged,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.4)),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Text(suffix,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
*/
