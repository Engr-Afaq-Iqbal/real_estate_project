import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../presentation/routes/app_routes.dart';

const _kSuccess = Color(0xFF16A34A);
const _kWarning = Color(0xFFF59E0B);

/// Quick-action tiles: New Project, Add Update, Projects.
///
/// NOTE: The "Estimate" tile (→ CalculatorHubScreen) was removed in favor of
/// the DashboardEstimatorWidget section rendered directly on the dashboard.
class DashboardQuickActionsWidget extends StatelessWidget {
  const DashboardQuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _QuickAction(
            icon: Icons.add_circle_outline_rounded,
            label: 'New Project',
            color: Theme.of(context).colorScheme.primary,
            bg: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            onTap: () => Get.toNamed(AppRoutes.newProjectWizard),
          ),
          const SizedBox(width: 10),
          _QuickAction(
            icon: Icons.camera_alt_outlined,
            label: 'Add Update',
            color: _kSuccess,
            bg: _kSuccess.withValues(alpha: 0.1),
            onTap: () => Get.toNamed(AppRoutes.photoVideoFeed),
          ),
          const SizedBox(width: 10),
          // "Estimate" tile removed — estimator tools now live directly on
          // the dashboard (see DashboardEstimatorWidget).
          // _QuickAction(
          //   icon: Icons.calculate_outlined,
          //   label: 'Estimate',
          //   color: const Color(0xFF7C3AED),
          //   bg: const Color(0xFF7C3AED).withValues(alpha: 0.1),
          //   onTap: () => Get.toNamed(AppRoutes.calculatorHub),
          // ),
          // const SizedBox(width: 10),
          _QuickAction(
            icon: Icons.folder_open_outlined,
            label: 'Projects',
            color: _kWarning,
            bg: _kWarning.withValues(alpha: 0.1),
            onTap: () => Get.toNamed(AppRoutes.myProjects),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: label,
        button: true,
        child: GestureDetector(
          onTap: () { HapticFeedback.lightImpact(); onTap(); },
          child: ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Icon(icon, size: 22, color: color),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                        fontSize: 10, fontWeight: FontWeight.w600, color: color),
                    textAlign: TextAlign.center,
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
