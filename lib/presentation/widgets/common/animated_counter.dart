import 'package:flutter/material.dart';

/// Counts from 0 to [value] over [duration] with an ease-out curve.
/// Drop-in replacement for a Text displaying a number.
class AnimatedCounter extends StatelessWidget {
  final double value;
  final Duration duration;
  final String Function(double v) formatter;
  final TextStyle? style;

  const AnimatedCounter({
    super.key,
    required this.value,
    required this.formatter,
    this.duration = const Duration(milliseconds: 600),
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOut,
      builder: (_, v, __) => Text(formatter(v), style: style),
    );
  }
}

/// Progress bar that animates from 0 to [value] over [duration].
class AnimatedProgressBar extends StatelessWidget {
  final double value;          // 0.0 – 1.0
  final double minHeight;
  final Color? backgroundColor;
  final Color? valueColor;
  final Duration duration;
  final BorderRadius? borderRadius;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.minHeight = 6,
    this.backgroundColor,
    this.valueColor,
    this.duration = const Duration(milliseconds: 800),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: duration,
      curve: Curves.easeOut,
      builder: (_, v, __) => ClipRRect(
        borderRadius: borderRadius ??
            BorderRadius.circular(minHeight / 2),
        child: LinearProgressIndicator(
          value: v,
          minHeight: minHeight,
          backgroundColor: backgroundColor ?? Theme.of(context).dividerColor,
          valueColor: AlwaysStoppedAnimation<Color>(
              valueColor ?? cs.primary),
        ),
      ),
    );
  }
}
