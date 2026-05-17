import 'package:flutter/material.dart';

/// Color tokens for DQ Admin — single source of truth.
///
/// Brand: vivid purple on dark background.
/// All colors are const — never use raw Color() literals in widgets.
abstract class AppColors {
  // ── Brand ─────────────────────────────────────────────────
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFF9F67F5);
  static const Color primaryDark = Color(0xFF5B21B6);
  static const Color primarySubtle = Color(0x1A7C3AED); // 10%

  // ── Background & Surface ──────────────────────────────────
  static const Color background = Color(0xFF12082A);
  static const Color surface = Color(0xFF1E1040);
  static const Color surface2 = Color(0xFF251A4A);
  static const Color surfaceElevated = Color(0xFF2D2060);

  // ── Glass Surface ─────────────────────────────────────────
  static const Color glassWhite04 = Color(0x0AFFFFFF);
  static const Color glassWhite07 = Color(0x12FFFFFF);
  static const Color glassWhite10 = Color(0x1AFFFFFF);
  static const Color glassWhite15 = Color(0x26FFFFFF); // cardSurface
  static const Color glassWhite20 = Color(0x33FFFFFF); // cardBorder
  static const Color glassWhite30 = Color(0x4DFFFFFF);
  static const Color glassWhite50 = Color(0x80FFFFFF);
  static const Color glassBlack05 = Color(0x0D000000);
  static const Color glassBlack10 = Color(0x1A000000);
  static const Color glassBlack30 = Color(0x4D000000);

  // ── Text ──────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFCDB4DB);
  static const Color textDisabled = Color(0xFF7A7A9D);
  static const Color textInverse = Color(0xFF12082A);

  // ── Semantic — Success ────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successSubtle = Color(0x1A22C55E); // 10%
  static const Color successBorder = Color(0x3322C55E); // 20%

  // ── Semantic — Warning ────────────────────────────────────
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSubtle = Color(0x1AF59E0B);
  static const Color warningBorder = Color(0x33F59E0B);

  // ── Semantic — Error ──────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color errorSubtle = Color(0x1AEF4444);
  static const Color errorBorder = Color(0x33EF4444);

  // ── Semantic — Info ───────────────────────────────────────
  static const Color info = Color(0xFF3B82F6);
  static const Color infoSubtle = Color(0x1A3B82F6);
  static const Color infoBorder = Color(0x333B82F6);

  // ── Semantic — Neutral ────────────────────────────────────
  static const Color neutral = Color(0xFF94A3B8);
  static const Color neutralSubtle = Color(0x1A94A3B8);
  static const Color neutralBorder = Color(0x3394A3B8);

  // ── Divider / Border ──────────────────────────────────────
  static const Color divider = Color(0x1AFFFFFF); // 10% white
  static const Color border = Color(0x26FFFFFF); // 15% white

  // ── Overlay ───────────────────────────────────────────────
  static const Color scrim = Color(0x80000000); // 50% black

  // ── Order status convenience map ──────────────────────────
  static Color statusColor(String status) => switch (status.toLowerCase()) {
        'pending' => neutral,
        'preparing' => warning,
        'ready' => info,
        'completed' => success,
        'cancelled' => error,
        _ => neutral,
      };

  static Color statusSubtle(String status) => switch (status.toLowerCase()) {
        'pending' => neutralSubtle,
        'preparing' => warningSubtle,
        'ready' => infoSubtle,
        'completed' => successSubtle,
        'cancelled' => errorSubtle,
        _ => neutralSubtle,
      };

  static Color statusBorder(String status) => switch (status.toLowerCase()) {
        'pending' => neutralBorder,
        'preparing' => warningBorder,
        'ready' => infoBorder,
        'completed' => successBorder,
        'cancelled' => errorBorder,
        _ => neutralBorder,
      };
}
