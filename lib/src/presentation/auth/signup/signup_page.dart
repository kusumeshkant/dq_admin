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
            icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
            onPressed: Get.back,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.store_rounded, color: AppTheme.primary, size: 34),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Create Admin Account',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Set up your store management account',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 36),

                // Full Name
                _Field(
                  controller: c.nameCtrl,
                  label: 'Full Name',
                  icon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Email
                _Field(
                  controller: c.emailCtrl,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password
                Obx(() => _Field(
                      controller: c.passwordCtrl,
                      label: 'Password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: c.obscurePassword.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          c.obscurePassword.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppTheme.textSecondary, size: 20,
                        ),
                        onPressed: () => c.obscurePassword.value = !c.obscurePassword.value,
                      ),
                    )),
                const SizedBox(height: 16),

                // Confirm Password
                Obx(() => _Field(
                      controller: c.confirmCtrl,
                      label: 'Confirm Password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: c.obscureConfirm.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          c.obscureConfirm.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppTheme.textSecondary, size: 20,
                        ),
                        onPressed: () => c.obscureConfirm.value = !c.obscureConfirm.value,
                      ),
                      onSubmitted: (_) => c.signUp(),
                    )),
                const SizedBox(height: 12),

                // Error
                Obx(() => c.errorMessage.value.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(c.errorMessage.value,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                      )),
                const SizedBox(height: 8),

                // Sign Up button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Obx(() => ElevatedButton(
                        onPressed: c.isLoading.value ? null : c.signUp,
                        child: c.isLoading.value
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Text('Create Account',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      )),
                ),
                const SizedBox(height: 32),
              ],
            ),
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
      style: const TextStyle(color: AppTheme.textPrimary),
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
