import 'package:flutter/material.dart';
import '../../../src/theme/app_theme.dart';

/// Typography tokens — all text styles in one place.
///
/// Styles scale subtly across breakpoints but are device-agnostic by default.
/// For responsive variants, use the BuildContext extension in app_responsive.dart
/// or pass [scale] manually.
///
/// Usage:
///   style: AppTypography.titleLarge
///   style: AppTypography.body
abstract class AppTypography {
  // ── Display ───────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    color: AppTheme.textPrimary,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    color: AppTheme.textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  // ── Title ─────────────────────────────────────────────────
  static const TextStyle titleLarge = TextStyle(
    color: AppTheme.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleMedium = TextStyle(
    color: AppTheme.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleSmall = TextStyle(
    color: AppTheme.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // ── Body ──────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    color: AppTheme.textPrimary,
    fontSize: 15,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle body = TextStyle(
    color: AppTheme.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodySmall = TextStyle(
    color: AppTheme.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.normal,
  );

  // ── Label ─────────────────────────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    color: AppTheme.textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle label = TextStyle(
    color: AppTheme.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle labelSmall = TextStyle(
    color: AppTheme.textSecondary,
    fontSize: 11,
    fontWeight: FontWeight.normal,
  );

  // ── Caption / hint ────────────────────────────────────────
  static const TextStyle caption = TextStyle(
    color: AppTheme.textSecondary,
    fontSize: 11,
    fontWeight: FontWeight.normal,
  );

  // ── Button ────────────────────────────────────────────────
  static const TextStyle button = TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  // ── Stat / KPI numbers ────────────────────────────────────
  static const TextStyle statLarge = TextStyle(
    color: AppTheme.textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle statMedium = TextStyle(
    color: AppTheme.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle statSmall = TextStyle(
    color: AppTheme.textPrimary,
    fontSize: 17,
    fontWeight: FontWeight.bold,
  );

  // ── App bar ───────────────────────────────────────────────
  static const TextStyle appBar = TextStyle(
    color: AppTheme.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
}
