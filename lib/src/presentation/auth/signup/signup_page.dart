import 'package:dq_admin/design_system/design_system.dart';
import 'package:dq_admin/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_theme.dart';
import 'signup_controller.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SignupController>();

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppTheme.textPrimary),
            onPressed: Get.back,
          ),
        ),
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
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xxxl),
                      child: SizedBox(
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
                                  Icons.store_rounded,
                                  color: AppTheme.primary,
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Text(
                              'Create Admin Account',
                              style: AppTypography.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Set up your store management account',
                              style: AppTypography.body
                                  .copyWith(color: AppTheme.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // ── Auth glass card ─────────────────────────────
                            DsGlassCard(
                              padding:
                                  const EdgeInsets.all(AppSpacing.xxl),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  // Full Name
                                  _Field(
                                    controller: c.nameCtrl,
                                    label: 'Full Name',
                                    icon: Icons.person_outline_rounded,
                                    textCapitalization:
                                        TextCapitalization.words,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),

                                  // Email
                                  _Field(
                                    controller: c.emailCtrl,
                                    label: 'Email Address',
                                    icon: Icons.email_outlined,
                                    keyboardType:
                                        TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),

                                  // Password
                                  Obx(() => _Field(
                                        controller: c.passwordCtrl,
                                        label: 'Password',
                                        icon: Icons.lock_outline_rounded,
                                        obscureText:
                                            c.obscurePassword.value,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            c.obscurePassword.value
                                                ? Icons
                                                    .visibility_off_outlined
                                                : Icons
                                                    .visibility_outlined,
                                            color: AppTheme.textSecondary,
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              c.obscurePassword.value =
                                                  !c.obscurePassword.value,
                                        ),
                                      )),
                                  const SizedBox(height: AppSpacing.lg),

                                  // Confirm Password
                                  Obx(() => _Field(
                                        controller: c.confirmCtrl,
                                        label: 'Confirm Password',
                                        icon: Icons.lock_outline_rounded,
                                        obscureText:
                                            c.obscureConfirm.value,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            c.obscureConfirm.value
                                                ? Icons
                                                    .visibility_off_outlined
                                                : Icons
                                                    .visibility_outlined,
                                            color: AppTheme.textSecondary,
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              c.obscureConfirm.value =
                                                  !c.obscureConfirm.value,
                                        ),
                                        onSubmitted: (_) => c.signUp(),
                                      )),
                                  const SizedBox(height: AppSpacing.md),

                                  // Error
                                  Obx(() => c.errorMessage.value.isEmpty
                                      ? const SizedBox.shrink()
                                      : Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: AppSpacing.sm),
                                          child: Text(
                                            c.errorMessage.value,
                                            style:
                                                AppTypography.bodySmall
                                                    .copyWith(
                                                        color: AppColors
                                                            .error),
                                          ),
                                        )),
                                  const SizedBox(height: AppSpacing.sm),

                                  // Create account button
                                  SizedBox(
                                    height: AppSizes.buttonLg,
                                    child: Obx(() => ElevatedButton(
                                          onPressed: c.isLoading.value
                                              ? null
                                              : c.signUp,
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
                                              : Text('Create Account',
                                                  style:
                                                      AppTypography.button),
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
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

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onSubmitted;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: AppTypography.body.copyWith(color: AppTheme.textPrimary),
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
