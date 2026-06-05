import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../controllers/project_wizard_controller.dart';
import '../../../config/wizard_step_config.dart';

class Step1ProjectType extends GetView<ProjectWizardController> {
  const Step1ProjectType({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.92,
      ),
      itemCount: kProjectTypeConfigs.length,
      itemBuilder: (_, i) {
        final cfg = kProjectTypeConfigs[i];
        return _TypeCard(config: cfg, index: i)
            .animate(delay: Duration(milliseconds: i * 35))
            .fadeIn(duration: 280.ms, curve: Curves.easeOut)
            .slideY(begin: 0.12, end: 0, duration: 280.ms,
                curve: Curves.easeOutCubic);
      },
    );
  }
}

class _TypeCard extends GetView<ProjectWizardController> {
  final ProjectTypeConfig config;
  final int index;
  const _TypeCard({required this.config, required this.index});

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final divider = Theme.of(context).dividerColor;
    // Inactive icon bg — subtle tint that works in both modes
    final inactiveBg = cs.onSurface.withValues(alpha: 0.06);

    return Obx(() {
      final isSelected = controller.selectedTypeKey.value == config.key;

      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          controller.selectType(config.key);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected
                ? cs.primary.withValues(alpha: 0.06)
                : surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? cs.primary : divider,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: cs.primary.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]
                : [
                    BoxShadow(
                        color: cs.onSurface.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ],
          ),
          child: AnimatedScale(
            scale: isSelected ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cs.primary.withValues(alpha: 0.1)
                          : inactiveBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(config.icon,
                          style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    config.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? cs.primary : cs.onSurface,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
