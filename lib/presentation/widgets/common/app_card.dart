import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? color;
  final VoidCallback? onTap;
  final bool hasBorder;
  final double elevation;
  final Gradient? gradient;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.color,
    this.onTap,
    this.hasBorder = true,
    this.elevation = 0,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? AppDimensions.cardRadius;
    final bg = color ?? (isDark ? AppColors.cardDark : AppColors.cardLight);

    final decoration = BoxDecoration(
      color: gradient == null ? bg : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      border: hasBorder
          ? Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            )
          : null,
      boxShadow: elevation > 0
          ? [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.06),
                blurRadius: elevation * 2,
                offset: Offset(0, elevation),
              ),
            ]
          : null,
    );

    final inner = Container(
      decoration: decoration,
      padding: padding ?? const EdgeInsets.all(AppDimensions.cardPadding),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: inner,
        ),
      );
    }
    return inner;
  }
}

// ── Gradient hero card (used in dashboards) ──────────────────────────────────
class AppGradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const AppGradientCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: AppColors.cardGradient,
      hasBorder: false,
      padding: padding,
      onTap: onTap,
      child: child,
    );
  }
}
