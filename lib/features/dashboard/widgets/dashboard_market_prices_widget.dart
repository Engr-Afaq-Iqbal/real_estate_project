import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/dashboard_controller.dart';
import '../../../presentation/routes/app_routes.dart';

// Light tints that stay readable on the primary-gradient background.
const _kUpTint   = Color(0xFFFECACA); // soft red — price increased
const _kDownTint = Color(0xFFBBF7D0); // soft green — price decreased

/// Cement / steel / brick price card with refresh and disclaimer.
///
/// Styled as a highlighted dashboard component on the app's primary
/// gradient (the styling previously used by the Quick Estimator section),
/// so it reads like a financial-market ticker rather than a plain card.
class DashboardMarketPricesWidget extends StatelessWidget {
  final DashboardController controller;
  const DashboardMarketPricesWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
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
        boxShadow: [
          BoxShadow(
              color: cs.primary.withValues(alpha: 0.30),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.bar_chart_rounded,
                    size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Market Prices Today',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
              // LIVE badge
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5, height: 5,
                      decoration: const BoxDecoration(
                          color: Color(0xFF4ADE80), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text('LIVE',
                        style: GoogleFonts.inter(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: Colors.white)),
                  ],
                ),
              ),
              Obx(() => controller.isRefreshingPrices.value
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Semantics(
                      label: 'Refresh market prices',
                      button: true,
                      child: GestureDetector(
                        onTap: controller.refreshMarketPrices,
                        child: Icon(Icons.refresh_rounded,
                            size: 18,
                            color: Colors.white.withValues(alpha: 0.85)),
                      ),
                    )),
            ],
          ),
          Obx(() {
            final lu = controller.marketPricesLastUpdated.value;
            if (lu == null) return const SizedBox.shrink();
            final h = lu.hour.toString().padLeft(2, '0');
            final m = lu.minute.toString().padLeft(2, '0');
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Last updated: $h:$m',
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.65))),
            );
          }),
          const SizedBox(height: 12),
          Obx(() {
            final prices = controller.marketPrices;
            if (prices.isEmpty) return const SizedBox.shrink();
            return Row(
              children: [
                for (var i = 0; i < prices.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: _PriceTile(price: prices[i])),
                ],
              ],
            );
          }),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'Prices are indicative. Verify with local suppliers.',
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  color: Colors.white.withValues(alpha: 0.55)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.toNamed('/market/prices'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bar_chart_rounded,
                            size: 14, color: cs.primary),
                        const SizedBox(width: 5),
                        Text("Today's Prices",
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: cs.primary)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.materialCalculator),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calculate_rounded,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 5),
                        Text('Calculator',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceTile extends StatelessWidget {
  final MarketPrice price;
  const _PriceTile({required this.price});

  @override
  Widget build(BuildContext context) {
    final color = price.isUp
        ? _kUpTint
        : price.isDown
            ? _kDownTint
            : Colors.white.withValues(alpha: 0.75);
    final arrow = price.isUp ? '↑' : price.isDown ? '↓' : '→';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(price.material,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.75))),
          const SizedBox(height: 4),
          Text(price.price.toStringAsFixed(0),
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(arrow,
                  style: TextStyle(
                      fontSize: 10, color: color, fontWeight: FontWeight.w700)),
              const SizedBox(width: 1),
              Text(
                price.changeToday == 0
                    ? 'Stable'
                    : price.changeToday.abs().toStringAsFixed(0),
                style: GoogleFonts.inter(
                    fontSize: 9, color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Text(price.unit,
              style: GoogleFonts.inter(
                  fontSize: 9, color: Colors.white.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}
