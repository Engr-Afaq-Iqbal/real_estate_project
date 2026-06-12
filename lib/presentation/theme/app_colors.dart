import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1E3A8A);
  static const Color primaryDark = Color(0xFF1E2F6E);
  static const Color primaryLight = Color(0xFF2D4EAF);
  static const Color accent = Color(0xFF3B82F6);
  static const Color accentLight = Color(0xFF60A5FA);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ── Light theme ────────────────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFCBD5E1);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF4B5563); // was #64748B — darkened for WCAG AA 4.5:1
  static const Color textTertiaryLight = Color(0xFF6B7280); // was #94A3B8 (2.5:1 fail) — 4.8:1 on white
  static const Color iconLight = Color(0xFF475569);

  // ── Dark theme ─────────────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color dividerDark = Color(0xFF334155);
  static const Color borderDark = Color(0xFF475569);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);
  static const Color iconDark = Color(0xFF94A3B8);

  // ── Status chips ───────────────────────────────────────────────────────────
  static const Color onTrack = Color(0xFF22C55E);
  static const Color onTrackBg = Color(0xFFDCFCE7);
  static const Color atRisk = Color(0xFFF59E0B);
  static const Color atRiskBg = Color(0xFFFEF3C7);
  static const Color late = Color(0xFFEF4444);
  static const Color lateBg = Color(0xFFFEE2E2);
  static const Color inProgress = Color(0xFF3B82F6);
  static const Color inProgressBg = Color(0xFFDBEAFE);
  static const Color completed = Color(0xFF22C55E);
  static const Color completedBg = Color(0xFFDCFCE7);
  static const Color onHold = Color(0xFF8B5CF6);
  static const Color onHoldBg = Color(0xFFEDE9FE);

  // ── Stage badge colors ─────────────────────────────────────────────────────
  static const Color stageGrayStructure = Color(0xFFF59E0B);
  static const Color stagePlastering = Color(0xFF3B82F6);
  static const Color stageFinishing = Color(0xFF22C55E);
  static const Color stageFoundation = Color(0xFF8B5CF6);

  // ── Chart colors ───────────────────────────────────────────────────────────
  static const List<Color> chartColors = [
    Color(0xFF1E3A8A),
    Color(0xFF3B82F6),
    Color(0xFF22C55E),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFFEF4444),
    Color(0xFF64748B),
  ];

  // ── Gradient ───────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF2D4EAF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Misc ───────────────────────────────────────────────────────────────────
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);
  static const Color overlayDark = Color(0x80000000);
  static const Color transparent = Colors.transparent;
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
