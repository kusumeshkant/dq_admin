/// Spacing tokens — single source of truth for all padding/gap/margin values.
///
/// Usage:
///   padding: EdgeInsets.all(AppSpacing.md)
///   SizedBox(height: AppSpacing.lg)
abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double massive = 56;
}
