import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

enum BadgeVariant { onTrack, atRisk, late, inProgress, completed, onHold, custom }

class AppBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final Color? customColor;
  final Color? customBgColor;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.inProgress,
    this.customColor,
    this.customBgColor,
  });

  @override
  Widget build(BuildContext context) {
    final (color, bg) = _colors();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  (Color, Color) _colors() {
    switch (variant) {
      case BadgeVariant.onTrack:
        return (AppColors.onTrack, AppColors.onTrackBg);
      case BadgeVariant.atRisk:
        return (AppColors.atRisk, AppColors.atRiskBg);
      case BadgeVariant.late:
        return (AppColors.late, AppColors.lateBg);
      case BadgeVariant.inProgress:
        return (AppColors.inProgress, AppColors.inProgressBg);
      case BadgeVariant.completed:
        return (AppColors.completed, AppColors.completedBg);
      case BadgeVariant.onHold:
        return (AppColors.onHold, AppColors.onHoldBg);
      case BadgeVariant.custom:
        return (customColor ?? AppColors.primary, customBgColor ?? AppColors.infoLight);
    }
  }
}

// ── Stage badge (colored pill used in project cards) ─────────────────────────
class StageBadge extends StatelessWidget {
  final String stage;

  const StageBadge({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    final color = _stageColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
      ),
      child: Text(
        stage.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _stageColor() {
    final s = stage.toLowerCase();
    if (s.contains('gray') || s.contains('grey')) return AppColors.stageGrayStructure;
    if (s.contains('plaster')) return AppColors.stagePlastering;
    if (s.contains('finish')) return AppColors.stageFinishing;
    if (s.contains('foundation')) return AppColors.stageFoundation;
    if (s.contains('complete') || s.contains('handover')) return AppColors.success;
    return AppColors.primary;
  }
}

// ── Notification dot ─────────────────────────────────────────────────────────
class NotificationDot extends StatelessWidget {
  final int count;

  const NotificationDot({super.key, this.count = 0});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: const BoxDecoration(
        color: AppColors.error,
        shape: BoxShape.circle,
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
