import 'package:dq_admin/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import 'profile_setup_controller.dart';

class ProfileSetupPage extends StatelessWidget {
  const ProfileSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProfileSetupController>();

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: AppTheme.primary, size: 30),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Complete Your Profile',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We need a few more details before you continue.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 36),

                // Email — pre-filled, read-only
                _label('Email'),
                const SizedBox(height: 6),
                TextField(
                  controller: TextEditingController(text: c.email),
                  readOnly: true,
                  style: const TextStyle(color: AppTheme.textSecondary),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.cardSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 20),

                // Name
                _label('Full Name'),
                const SizedBox(height: 6),
                TextField(
                  controller: c.nameCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Your full name',
                    prefixIcon: Icon(Icons.badge_outlined,
                        color: AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(height: 20),

                // Phone
                _label('Phone Number'),
                const SizedBox(height: 6),
                TextField(
                  controller: c.phoneCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: '10-digit mobile number',
                    prefixIcon: Icon(Icons.phone_outlined,
                        color: AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(height: 12),

                // Error
                Obx(() => c.errorMessage.value.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(c.errorMessage.value,
                            style: const TextStyle(
                                color: Colors.redAccent, fontSize: 13)),
                      )),

                const SizedBox(height: 16),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Obx(() => ElevatedButton(
                        onPressed: c.isLoading.value ? null : c.saveProfile,
                        child: c.isLoading.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : const Text('Save & Continue',
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

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5));
}
