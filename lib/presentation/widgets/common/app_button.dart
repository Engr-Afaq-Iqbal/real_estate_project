import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? leading;
  final Widget? trailing;
  final bool isLoading;
  final bool isFullWidth;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.leading,
    this.trailing,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height,
    this.borderRadius,
    this.padding,
  });

  const AppButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.trailing,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height,
    this.borderRadius,
    this.padding,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.trailing,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height,
    this.borderRadius,
    this.padding,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.outline({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.trailing,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height,
    this.borderRadius,
    this.padding,
  }) : variant = AppButtonVariant.outline;

  const AppButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.trailing,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height,
    this.borderRadius,
    this.padding,
  }) : variant = AppButtonVariant.ghost;

  @override
  Widget build(BuildContext context) {
    final h = height ?? AppDimensions.buttonHeightLg;
    final r = borderRadius ?? AppDimensions.radiusLg;
    final disabled = onPressed == null || isLoading;

    switch (variant) {
      case AppButtonVariant.primary:
        return _PrimaryButton(
          label: label,
          onPressed: disabled ? null : onPressed,
          isLoading: isLoading,
          isFullWidth: isFullWidth,
          height: h,
          radius: r,
          padding: padding,
          leading: leading,
          trailing: trailing,
        );
      case AppButtonVariant.secondary:
        return _SecondaryButton(
          label: label,
          onPressed: disabled ? null : onPressed,
          isLoading: isLoading,
          isFullWidth: isFullWidth,
          height: h,
          radius: r,
          padding: padding,
          leading: leading,
          trailing: trailing,
        );
      case AppButtonVariant.outline:
        return _OutlineButton(
          label: label,
          onPressed: disabled ? null : onPressed,
          isLoading: isLoading,
          isFullWidth: isFullWidth,
          height: h,
          radius: r,
          padding: padding,
          leading: leading,
          trailing: trailing,
        );
      case AppButtonVariant.ghost:
        return _GhostButton(
          label: label,
          onPressed: disabled ? null : onPressed,
          isLoading: isLoading,
          height: h,
          radius: r,
          padding: padding,
          leading: leading,
          trailing: trailing,
        );
      case AppButtonVariant.danger:
        return _DangerButton(
          label: label,
          onPressed: disabled ? null : onPressed,
          isLoading: isLoading,
          isFullWidth: isFullWidth,
          height: h,
          radius: r,
          padding: padding,
        );
    }
  }
}

// ── Primary ─────────────────────────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final Widget? leading;
  final Widget? trailing;

  const _PrimaryButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    required this.height,
    required this.radius,
    this.padding,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.borderLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          elevation: 0,
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
        ),
        child: _ButtonContent(
          label: label,
          isLoading: isLoading,
          leading: leading,
          trailing: trailing,
          color: AppColors.white,
        ),
      ),
    );
  }
}

// ── Secondary ────────────────────────────────────────────────────────────────
class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final Widget? leading;
  final Widget? trailing;

  const _SecondaryButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    required this.height,
    required this.radius,
    this.padding,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          elevation: 0,
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
        ),
        child: _ButtonContent(
          label: label,
          isLoading: isLoading,
          leading: leading,
          trailing: trailing,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ── Outline ──────────────────────────────────────────────────────────────────
class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final Widget? leading;
  final Widget? trailing;

  const _OutlineButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    required this.height,
    required this.radius,
    this.padding,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
        ),
        child: _ButtonContent(
          label: label,
          isLoading: isLoading,
          leading: leading,
          trailing: trailing,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ── Ghost ────────────────────────────────────────────────────────────────────
class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final Widget? leading;
  final Widget? trailing;

  const _GhostButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    required this.height,
    required this.radius,
    this.padding,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: padding,
        ),
        child: _ButtonContent(
          label: label,
          isLoading: isLoading,
          leading: leading,
          trailing: trailing,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ── Danger ───────────────────────────────────────────────────────────────────
class _DangerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? padding;

  const _DangerButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    required this.height,
    required this.radius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          elevation: 0,
        ),
        child: _ButtonContent(
          label: label,
          isLoading: isLoading,
          color: AppColors.white,
        ),
      ),
    );
  }
}

// ── Content ──────────────────────────────────────────────────────────────────
class _ButtonContent extends StatelessWidget {
  final String label;
  final bool isLoading;
  final Widget? leading;
  final Widget? trailing;
  final Color color;

  const _ButtonContent({
    required this.label,
    required this.isLoading,
    this.leading,
    this.trailing,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 8)],
        Text(
          label,
          style: AppTextStyles.buttonLarge().copyWith(color: color),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}
