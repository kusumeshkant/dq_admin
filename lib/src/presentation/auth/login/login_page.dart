import 'package:dq_admin/design_system/design_system.dart';
import 'package:dq_admin/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/responsive/app_responsive.dart';
import '../../../core/responsive/app_spacing.dart';
import '../../../core/responsive/app_sizes.dart';
import '../../../core/responsive/app_typography.dart';
import '../../../theme/app_theme.dart';
import '../signup/signup_binding.dart';
import '../signup/signup_page.dart';
import 'login_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LoginController>();
    final hPadding = context.responsive(
      AppSpacing.xl + AppSpacing.sm, // 28 mobile
      tablet: AppSpacing.xxxl,       // 32 tablet
    );

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: AppSpacing.huge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.responsive(AppSpacing.xxxl, tablet: AppSpacing.huge)),
                    // Logo / brand
                    Container(
                      width: AppSizes.avatarLg,
                      height: AppSizes.avatarLg,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSizes.radiusXxl - 2),
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.admin_panel_settings_rounded,
                          color: AppTheme.primary, size: 34),
                    ),
                    const SizedBox(height: AppSpacing.xl + AppSpacing.sm),
                    Text('DQ Admin', style: AppTypography.displayMedium),
                    const SizedBox(height: AppSpacing.xs + 2),
                    Text(
                      'Sign in to manage your stores',
                      style: AppTypography.body.copyWith(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.huge),

                    // Email
                    TextField(
                      controller: c.emailController,
                      style: AppTypography.body,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Password
                    Obx(() => TextField(
                          controller: c.passwordController,
                          obscureText: c.obscurePassword.value,
                          style: AppTypography.body,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded,
                                color: AppTheme.textSecondary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                c.obscurePassword.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppTheme.textSecondary,
                              ),
                              onPressed: () =>
                                  c.obscurePassword.value = !c.obscurePassword.value,
                            ),
                          ),
                          onSubmitted: (_) => c.login(),
                        )),
                    const SizedBox(height: AppSpacing.md),

                    // Error
                    Obx(() => c.errorMessage.value.isEmpty
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                            child: Text(
                              c.errorMessage.value,
                              style: AppTypography.bodySmall
                                  .copyWith(color: AppColors.error),
                            ),
                          )),
                    const SizedBox(height: AppSpacing.xl),

                    // Sign in button
                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonLg,
                      child: Obx(() => ElevatedButton(
                            onPressed: c.isLoading.value ? null : c.login,
                            child: c.isLoading.value
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5))
                                : Text('Sign In', style: AppTypography.button),
                          )),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "New store owner? ",
                          style: AppTypography.body
                              .copyWith(color: AppTheme.textSecondary),
                        ),
                        GestureDetector(
                          onTap: () => Get.to(
                            () => const SignupPage(),
                            binding: SignupBinding(),
                          ),
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
      ),
    );
  }
}
