import 'package:dq_admin/design_system/design_system.dart';
import 'package:dq_admin/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import 'login_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LoginController>();

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Compute card width explicitly so SizedBox provides a TIGHT
              // constraint — avoids Column(stretch) misinterpreting loose bounds.
              const double kCard = 480.0;
              final double cardW =
                  (constraints.maxWidth - 48.0).clamp(240.0, kCard);

              return SingleChildScrollView(
                child: ConstrainedBox(
                  // minHeight keeps content vertically centred on tall viewports.
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xxxl),
                      child: SizedBox(
                        // TIGHT width — no constraint negotiation downstream.
                        width: cardW,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── Brand mark ─────────────────────────────────
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(
                                      AppSizes.radiusXxl),
                                  border: Border.all(
                                    color: AppTheme.primary
                                        .withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.admin_panel_settings_rounded,
                                  color: AppTheme.primary,
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Text(
                              'DQ Admin',
                              style: AppTypography.displayMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xs + 2),
                            Text(
                              'Sign in to manage your stores',
                              style: AppTypography.body
                                  .copyWith(color: AppTheme.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xxl),

                            // ── Auth glass card ─────────────────────────────
                            DsGlassCard(
                              padding:
                                  const EdgeInsets.all(AppSpacing.xxl),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  // Email
                                  TextField(
                                    controller: c.emailController,
                                    style: AppTypography.body,
                                    keyboardType:
                                        TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      prefixIcon: Icon(
                                          Icons.email_outlined,
                                          color: AppTheme.textSecondary),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),

                                  // Password
                                  Obx(() => TextField(
                                        controller: c.passwordController,
                                        obscureText:
                                            c.obscurePassword.value,
                                        style: AppTypography.body,
                                        decoration: InputDecoration(
                                          labelText: 'Password',
                                          prefixIcon: const Icon(
                                              Icons.lock_outline_rounded,
                                              color:
                                                  AppTheme.textSecondary),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              c.obscurePassword.value
                                                  ? Icons
                                                      .visibility_off_outlined
                                                  : Icons
                                                      .visibility_outlined,
                                              color:
                                                  AppTheme.textSecondary,
                                            ),
                                            onPressed: () =>
                                                c.obscurePassword.value =
                                                    !c.obscurePassword
                                                        .value,
                                          ),
                                        ),
                                        onSubmitted: (_) => c.login(),
                                      )),
                                  const SizedBox(height: AppSpacing.md),

                                  // Error
                                  Obx(() => c.errorMessage.value.isEmpty
                                      ? const SizedBox.shrink()
                                      : Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: AppSpacing.xs),
                                          child: Text(
                                            c.errorMessage.value,
                                            style:
                                                AppTypography.bodySmall
                                                    .copyWith(
                                                        color: AppColors
                                                            .error),
                                          ),
                                        )),
                                  const SizedBox(height: AppSpacing.xl),

                                  // Sign in button
                                  SizedBox(
                                    height: AppSizes.buttonLg,
                                    child: Obx(() => ElevatedButton(
                                          onPressed: c.isLoading.value
                                              ? null
                                              : c.login,
                                          child: c.isLoading.value
                                              ? const SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2.5,
                                                  ),
                                                )
                                              : Text('Sign In',
                                                  style:
                                                      AppTypography.button),
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxl),

                            // ── Create account link ─────────────────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'New store owner? ',
                                  style: AppTypography.body.copyWith(
                                      color: AppTheme.textSecondary),
                                ),
                                GestureDetector(
                                  onTap: () => Get.toNamed(AppRoutes.signup),
                                  child: Text(
                                    'Create Account',
                                    style: AppTypography.body.copyWith(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
