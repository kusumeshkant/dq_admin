# Design System Audit — DQ Admin
**Branch**: feature/design-system-dq-admin | **Date**: 2026-05-15

---

## Architecture
- **State**: GetX (GetxController, Obx)
- **Architecture**: Clean (domain / data / presentation)
- **Material**: Material 3 (`useMaterial3: true`)
- **Theme modes**: Light (purple) only — dark mode partially referenced but NOT implemented

---

## Existing Design System Files

| File | Status |
|------|--------|
| `lib/src/theme/app_theme.dart` | Best of three — has AppColors, AppSpacing, AppSizes, AppTypography, AppResponsive |
| `lib/widgets/app_glass_card.dart` | Good — reusable |
| `lib/widgets/themed_background.dart` | Good |
| `lib/widgets/app_error_widget.dart` | Good |
| `lib/widgets/app_loading_widget.dart` | Good |

**Missing**: No semantic colors (success/warning/error/info), no shadow tokens, no ds_status_badge

---

## Existing Token Coverage

### AppColors (partial)
```dart
static const Color primary = Color(0xFF7C3AED);    // Purple
static const Color primaryDark = Color(0xFF5B21B6);
static const Color surface = Color(0xFF1E1B4B);
static const Color surfaceLight = Color(0xFF2D2A5E);
// Missing: success, warning, error, info, neutral tokens
```

### AppSpacing (partial)
```dart
static const double xs = 4.0;
static const double sm = 8.0;
static const double md = 16.0;
static const double lg = 24.0;
static const double xl = 32.0;
// Missing: xxs, xxl, border radius tokens
```

### AppTypography (partial)
```dart
static const TextStyle heading = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
static const TextStyle body = TextStyle(fontSize: 14);
// Missing: labelLarge, labelSmall, caption, display styles
```

---

## Hardcoded Colors (Remaining Issues)

### Status colors — not using AppColors
```dart
// dashboard_page.dart, orders_page.dart, products_page.dart:
Colors.orange        — pending status
Colors.green         — active/completed status
Colors.red           — cancelled/error status
Colors.blue          — info/ready status

// products_page.dart filter sheet:
Color(0xFF1A0D35)    — hardcoded dark purple (NOT AppColors.surface)
```

### signup_page.dart — off-theme
```dart
// Uses hardcoded values not in AppColors:
Color(0xFF7C3AED)    — duplicates AppColors.primary (should reference token)
Colors.white.withValues(alpha: 0.1, 0.2, 0.3)
```

---

## Hardcoded Spacing (Remaining Issues)

Despite AppSpacing tokens existing, many screens still use magic numbers:

```dart
// dashboard_page.dart, orders_page.dart, products_page.dart:
SizedBox(height: 4)   — should be AppSpacing.xs
SizedBox(height: 8)   — should be AppSpacing.sm
SizedBox(height: 16)  — should be AppSpacing.md
SizedBox(height: 24)  — should be AppSpacing.lg

// Border radius — no tokens exist:
BorderRadius.circular(8)
BorderRadius.circular(12)
BorderRadius.circular(16)
BorderRadius.circular(20)
BorderRadius.circular(24)
```

---

## Screen Inventory

| Screen | File | Hardcoding severity |
|--------|------|---------------------|
| SignupPage | `presentation/auth/signup_page.dart` | MEDIUM |
| DashboardPage | `presentation/dashboard/dashboard_page.dart` | MEDIUM |
| OrdersPage | `presentation/orders/orders_page.dart` | HIGH |
| ProductsPage | `presentation/products/products_page.dart` | HIGH |
| InventoryPage | `presentation/inventory/inventory_page.dart` | LOW |
| OnboardingPage | `presentation/onboarding/onboarding_page.dart` | LOW |
| ProfilePage | `presentation/profile/profile_page.dart` | LOW |
| StorePage | `presentation/store/store_page.dart` | LOW |

---

## Phase 2 Target Structure

```
lib/
└── design_system/
    ├── tokens/
    │   ├── app_colors.dart        # Extend AppColors with semantic tokens
    │   ├── app_typography.dart    # Complete TextStyle system
    │   ├── app_spacing.dart       # Complete spacing + border radius
    │   └── app_shadows.dart       # Shadow + elevation tokens
    ├── theme/
    │   └── app_theme.dart         # Extended ThemeData with complete TextTheme
    └── widgets/
        ├── ds_glass_card.dart     # Extended AppGlassCard
        ├── ds_button.dart         # Standardized button variants
        ├── ds_input_field.dart    # Standardized input
        ├── ds_status_badge.dart   # Centralized status badges (replaces inline)
        ├── ds_loading.dart        # Wraps existing AppLoadingWidget
        └── ds_empty_state.dart    # Wraps existing AppErrorWidget
```

---

## Migration Priority

1. **Phase 2**: Extend `AppColors` with semantic tokens (success/warning/error/info)
   Add border radius tokens to `AppSpacing`. Complete `AppTypography`.
2. **Phase 3**: Add `ds_status_badge` widget (centralize all status color logic)
   Fix `products_page.dart` hardcoded `Color(0xFF1A0D35)`
3. **Phase 5**: Migrate orders_page, products_page, dashboard_page to use tokens
4. **Phase 6**: Validate — grep confirms no raw `Color(0x`, `Colors.shade`, magic px values
