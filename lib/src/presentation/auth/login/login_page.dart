import 'package:dq_admin/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_theme.dart';
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                // Logo / brand
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded,
                      color: AppTheme.primary, size: 34),
                ),
                const SizedBox(height: 28),
                const Text(
                  'DQ Admin',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sign in to manage your stores',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 40),

                // Email
                TextField(
                  controller: c.emailController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                Obx(() => TextField(
                      controller: c.passwordController,
                      obscureText: c.obscurePassword.value,
                      style: const TextStyle(color: AppTheme.textPrimary),
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
                const SizedBox(height: 12),

                // Error
                Obx(() => c.errorMessage.value.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          c.errorMessage.value,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                        ),
                      )),
                const SizedBox(height: 20),

                // Sign in button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Obx(() => ElevatedButton(
                        onPressed: c.isLoading.value ? null : c.login,
                        child: c.isLoading.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : const Text('Sign In',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
