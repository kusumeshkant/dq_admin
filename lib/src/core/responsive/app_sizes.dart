/// Size tokens — icons, avatars, touch targets, radii, buttons.
///
/// Usage:
///   SizedBox(width: AppSizes.iconMd, height: AppSizes.iconMd)
///   borderRadius: BorderRadius.circular(AppSizes.radiusMd)
abstract class AppSizes {
  // ── Icon sizes ────────────────────────────────────────────
  static const double iconSm = 18;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 44;

  // ── Avatar / thumbnail ────────────────────────────────────
  static const double avatarSm = 32;
  static const double avatarMd = 44;
  static const double avatarLg = 56;

  // ── Touch targets (minimum 48 per accessibility) ──────────
  static const double touchTarget = 48;

  // ── Button heights ────────────────────────────────────────
  static const double buttonSm = 40;
  static const double buttonMd = 48;
  static const double buttonLg = 52;

  // ── Border radii ──────────────────────────────────────────
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 14;
  static const double radiusXl = 16;
  static const double radiusXxl = 20;
  static const double radiusFull = 999;

  // ── App bar ───────────────────────────────────────────────
  static const double appBarHeight = 56;

  // ── Elevation ─────────────────────────────────────────────
  static const double elevationCard = 4;
}
