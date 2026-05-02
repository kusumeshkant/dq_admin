import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../data/model/user_model.dart';
import '../../service_core/auth/auth_router.dart';
import '../../service_core/auth/session_manager.dart';
import '../../service_core/networks/graphql_client_provider.dart';

class ProfileSetupController extends GetxController {
  final nameCtrl  = TextEditingController();
  final phoneCtrl = TextEditingController();

  final isLoading    = false.obs;
  final errorMessage = ''.obs;

  // Pre-fill email from Firebase (read-only, shown in UI)
  final String email;

  ProfileSetupController({required this.email});

  static const _updateProfileMutation = r'''
    mutation UpdateProfile($name: String, $phone: String, $email: String) {
      updateProfile(name: $name, phone: $phone, email: $email) {
        id name email phone role roles storeId
      }
    }
  ''';

  Future<void> saveProfile() async {
    final name  = nameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();

    if (name.isEmpty) {
      errorMessage.value = 'Name is required.';
      return;
    }
    if (phone.isEmpty) {
      errorMessage.value = 'Phone number is required.';
      return;
    }
    if (phone.length < 7 || phone.length > 15) {
      errorMessage.value = 'Please enter a valid phone number.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await GraphQLClientProvider.client.mutate(
        MutationOptions(
          document: gql(_updateProfileMutation),
          variables: {'name': name, 'phone': phone, 'email': email},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final data = result.data?['updateProfile'] as Map<String, dynamic>?;
      if (data != null) {
        final updated = UserModel.fromJson(data);
        final session = Get.find<SessionManager>();
        session.setUser(updated);
        await session.cacheProfile(updated);
        AuthRouter.navigateAfterLogin(updated, email);
      }
    } catch (e) {
      errorMessage.value = 'Failed to save profile. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    super.onClose();
  }
}
