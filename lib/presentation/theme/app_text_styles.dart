import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Display ───────────────────────────────────────────────────────────────
  static TextStyle displayLarge(BuildContext context) =>
      GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w800, height: 1.1, color: _textColor(context));

  static TextStyle displayMedium(BuildContext context) =>
      GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w700, height: 1.2, color: _textColor(context));

  static TextStyle displaySmall(BuildContext context) =>
      GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2, color: _textColor(context));

  // ── Headings ──────────────────────────────────────────────────────────────
  static TextStyle h1(BuildContext context) =>
      GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, height: 1.3, color: _textColor(context));

  static TextStyle h2(BuildContext context) =>
      GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3, color: _textColor(context));

  static TextStyle h3(BuildContext context) =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4, color: _textColor(context));

  static TextStyle h4(BuildContext context) =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4, color: _textColor(context));

  // ── Body ──────────────────────────────────────────────────────────────────
  static TextStyle bodyLarge(BuildContext context) =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: _textColor(context));

  static TextStyle bodyMedium(BuildContext context) =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: _textColor(context));

  static TextStyle bodySmall(BuildContext context) =>
      GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, height: 1.5, color: _textSecondaryColor(context));

  // ── Label ─────────────────────────────────────────────────────────────────
  static TextStyle labelLarge(BuildContext context) =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4, color: _textColor(context));

  static TextStyle labelMedium(BuildContext context) =>
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, height: 1.4, color: _textSecondaryColor(context));

  static TextStyle labelSmall(BuildContext context) =>
      GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, height: 1.4, color: _textSecondaryColor(context), letterSpacing: 0.5);

  // ── Caption ───────────────────────────────────────────────────────────────
  static TextStyle caption(BuildContext context) =>
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4, color: _textTertiaryColor(context));

  // ── Currency / Amount ─────────────────────────────────────────────────────
  static TextStyle amountLarge(BuildContext context) =>
      GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2, color: _textColor(context));

  static TextStyle amountMedium(BuildContext context) =>
      GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, height: 1.2, color: _textColor(context));

  static TextStyle amountSmall(BuildContext context) =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, height: 1.3, color: _textColor(context));

  // ── Button ────────────────────────────────────────────────────────────────
  static TextStyle buttonLarge() =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, height: 1.0, color: AppColors.white);

  static TextStyle buttonMedium() =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, height: 1.0, color: AppColors.white);

  static TextStyle buttonSmall() =>
      GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, height: 1.0, color: AppColors.white);

  // ── Special ───────────────────────────────────────────────────────────────
  static TextStyle overline(BuildContext context) =>
      GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, height: 1.4, letterSpacing: 1.2, color: _textSecondaryColor(context));

  static TextStyle link(BuildContext context) =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, height: 1.5, color: AppColors.accent, decoration: TextDecoration.underline);

  // ── Helpers ───────────────────────────────────────────────────────────────
  static Color _textColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.textPrimaryDark
          : AppColors.textPrimaryLight;

  static Color _textSecondaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.textSecondaryDark
          : AppColors.textSecondaryLight;

  static Color _textTertiaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.textTertiaryDark
          : AppColors.textTertiaryLight;

  // ── Static (no context) — use in widgets without BuildContext ────────────
  static TextStyle get headingLargeStatic =>
      GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.textPrimaryLight);

  static TextStyle get bodyStatic =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textPrimaryLight);

  // Context-free aliases — suffixed with 'S' to avoid conflicting with
  // the BuildContext-taking methods above. Use these in new screens.
  static TextStyle get displayS =>
      GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w800, height: 1.1, color: AppColors.textPrimaryLight);

  static TextStyle get displayMediumS =>
      GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w700, height: 1.2, color: AppColors.textPrimaryLight);

  static TextStyle get h1S =>
      GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.textPrimaryLight);

  static TextStyle get h2S =>
      GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3, color: AppColors.textPrimaryLight);

  static TextStyle get h3S =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4, color: AppColors.textPrimaryLight);

  static TextStyle get h4S =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4, color: AppColors.textPrimaryLight);

  static TextStyle get bodyLargeS =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textPrimaryLight);

  static TextStyle get bodyMediumS =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textPrimaryLight);

  static TextStyle get bodySmallS =>
      GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textSecondaryLight);

  static TextStyle get labelLargeS =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4, color: AppColors.textPrimaryLight);

  static TextStyle get labelMediumS =>
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, height: 1.4, color: AppColors.textSecondaryLight);

  static TextStyle get labelSmallS =>
      GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, height: 1.4, color: AppColors.textSecondaryLight, letterSpacing: 0.5);

  static TextStyle get captionS =>
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4, color: AppColors.textTertiaryLight);

  static TextStyle get amountLargeS =>
      GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2, color: AppColors.textPrimaryLight);

  static TextStyle get amountMediumS =>
      GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, height: 1.2, color: AppColors.textPrimaryLight);

  static TextStyle get amountSmallS =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, height: 1.3, color: AppColors.textPrimaryLight);
}
