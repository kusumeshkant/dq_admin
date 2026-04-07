import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../service_core/networks/graphql_client_provider.dart';
import '../../../service_core/auth/session_manager.dart';
import '../../../data/model/user_model.dart';
import '../../profile_setup/profile_setup_binding.dart';
import '../../profile_setup/profile_setup_page.dart';

class SignupController extends GetxController {
  final nameCtrl     = TextEditingController();
  final emailCtrl    = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl  = TextEditingController();

  final isLoading       = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirm  = true.obs;
  final errorMessage    = ''.obs;

  static const _registerAdminMutation = r'''
    mutation RegisterAdmin {
      registerAdmin {
        id name email role roles storeId
      }
    }
  ''';

  Future<void> signUp() async {
    final name     = nameCtrl.text.trim();
    final email    = emailCtrl.text.trim();
    final password = passwordCtrl.text;
    final confirm  = confirmCtrl.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please fill in all fields.';
      return;
    }
    if (password != confirm) {
      errorMessage.value = 'Passwords do not match.';
      return;
    }
    if (password.length < 8) {
      errorMessage.value = 'Password must be at least 8 characters.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // 1. Create Firebase account
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.updateDisplayName(name);

      // 2. Init GraphQL client with the new token
      await GraphQLClientProvider.reinitWithToken();

      // 3. Register as admin in MongoDB
      final result = await GraphQLClientProvider.client.mutate(
        MutationOptions(document: gql(_registerAdminMutation)),
      );
      if (result.hasException) throw Exception(result.exception.toString());

      final data = result.data?['registerAdmin'] as Map<String, dynamic>?;
      if (data != null) {
        Get.find<SessionManager>().setUser(UserModel.fromJson(data));
      }

      // 4. Go to profile setup (collect phone)
      Get.offAll(
        () => const ProfileSetupPage(),
        binding: ProfileSetupBinding(email: email),
      );
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _firebaseError(e.code);
    } catch (e) {
      errorMessage.value = 'Sign up failed. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  String _firebaseError(String code) {
    switch (code) {
      case 'email-already-in-use': return 'An account with this email already exists.';
      case 'invalid-email':        return 'Please enter a valid email address.';
      case 'weak-password':        return 'Password is too weak. Use at least 8 characters.';
      default:                     return 'Sign up failed. Please try again.';
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.onClose();
  }
}
