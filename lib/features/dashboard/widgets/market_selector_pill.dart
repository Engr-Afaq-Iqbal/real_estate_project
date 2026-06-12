import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../market/controllers/market_controller.dart';
import 'market_selector_sheet.dart';

/// The small [🇵🇰 Pakistan ▾] chip shown in the dashboard header.
class MarketSelectorPill extends StatelessWidget {
  const MarketSelectorPill({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MarketController>()) {
      return const SizedBox.shrink();
    }
    final ctrl = Get.find<MarketController>();
    final cs   = Theme.of(context).colorScheme;

    return Obx(() {
      final m = ctrl.market;
      return GestureDetector(
        onTap: () => MarketSelectorSheet.show(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: cs.primary.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(m.flag, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 5),
              Text(
                m.name,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 3),
              Icon(Icons.keyboard_arrow_down_rounded,
                  size: 14, color: cs.primary),
            ],
          ),
        ),
      );
    });
  }
}
