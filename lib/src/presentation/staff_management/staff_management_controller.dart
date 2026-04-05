import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../domain/entity/user_entity.dart';
import '../../data/model/user_model.dart';
import '../../service_core/auth/session_manager.dart';
import '../../service_core/networks/graphql_client_provider.dart';

class PendingInvite {
  final String id;
  final String email;
  final String name;
  final String token;
  final String expiresAt;

  const PendingInvite({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
    required this.expiresAt,
  });

  factory PendingInvite.fromJson(Map<String, dynamic> j) => PendingInvite(
        id: j['id'] as String,
        email: j['email'] as String,
        name: j['name'] as String,
        token: j['token'] as String,
        expiresAt: j['expiresAt'] as String,
      );
}

class StaffManagementController extends GetxController {
  final nameCtrl  = TextEditingController();
  final emailCtrl = TextEditingController();

  final isLoading       = false.obs;
  final isInviting      = false.obs;
  final staff           = <UserEntity>[].obs;
  final pendingInvites  = <PendingInvite>[].obs;
  final errorMessage    = ''.obs;

  GraphQLClient get _client => GraphQLClientProvider.client;
  String? get _storeId => Get.find<SessionManager>().storeId;

  static const _storeStaffQuery = r'''
    query StoreStaff($storeId: ID!) {
      storeStaff(storeId: $storeId) { id name email phone role }
    }
  ''';

  static const _pendingInvitesQuery = r'''
    query PendingInvites($storeId: ID!) {
      pendingInvites(storeId: $storeId) { id email name token expiresAt }
    }
  ''';

  static const _inviteStaffMutation = r'''
    mutation InviteStaff($email: String!, $name: String!, $storeId: ID!) {
      inviteStaff(email: $email, name: $name, storeId: $storeId) {
        id email name token expiresAt
      }
    }
  ''';

  static const _cancelInviteMutation = r'''
    mutation CancelInvite($inviteId: ID!) {
      cancelInvite(inviteId: $inviteId)
    }
  ''';

  static const _removeStaffMutation = r'''
    mutation RemoveStaff($userId: ID!) {
      removeStaff(userId: $userId)
    }
  ''';

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await Future.wait([_loadStaff(), _loadPendingInvites()]);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadStaff() async {
    final result = await _client.query(QueryOptions(
      document: gql(_storeStaffQuery),
      variables: {'storeId': _storeId},
      fetchPolicy: FetchPolicy.networkOnly,
    ));
    if (result.hasException) throw Exception(result.exception.toString());
    final list = result.data?['storeStaff'] as List? ?? [];
    staff.value = list.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _loadPendingInvites() async {
    final result = await _client.query(QueryOptions(
      document: gql(_pendingInvitesQuery),
      variables: {'storeId': _storeId},
      fetchPolicy: FetchPolicy.networkOnly,
    ));
    if (result.hasException) throw Exception(result.exception.toString());
    final list = result.data?['pendingInvites'] as List? ?? [];
    pendingInvites.value = list.map((e) => PendingInvite.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> inviteStaff() async {
    final name  = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    debugPrint('DQ_INVITE: tapped — name="$name" email="$email" storeId=$_storeId');
    if (name.isEmpty) {
      Get.snackbar('Missing Name', 'Please enter the staff member\'s name.',
          backgroundColor: Colors.red.withValues(alpha: 0.85), colorText: Colors.white);
      return;
    }
    if (email.isEmpty) {
      Get.snackbar('Missing Email', 'Please enter an email address.',
          backgroundColor: Colors.red.withValues(alpha: 0.85), colorText: Colors.white);
      return;
    }

    isInviting.value = true;
    try {
      final result = await _client.mutate(MutationOptions(
        document: gql(_inviteStaffMutation),
        variables: {'email': email, 'name': name, 'storeId': _storeId},
      ));
      if (result.hasException) {
        debugPrint('DQ_INVITE: exception=${result.exception}');
        final msg = result.exception?.graphqlErrors.firstOrNull?.message ?? 'Invite failed';
        throw Exception(msg);
      }
      debugPrint('DQ_INVITE: success data=${result.data}');
      final invite = PendingInvite.fromJson(result.data!['inviteStaff'] as Map<String, dynamic>);
      pendingInvites.insert(0, invite);
      nameCtrl.clear();
      emailCtrl.clear();
      Get.back();
      Get.snackbar('Invite Sent', 'Invite sent to $email',
          backgroundColor: Colors.green.withValues(alpha: 0.85), colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red.withValues(alpha: 0.85), colorText: Colors.white);
    } finally {
      isInviting.value = false;
    }
  }

  Future<void> cancelInvite(PendingInvite invite) async {
    final confirm = await Get.dialog<bool>(AlertDialog(
      backgroundColor: const Color(0xFF1A0D35),
      title: const Text('Cancel Invite', style: TextStyle(color: Colors.white)),
      content: Text('Cancel the invite for ${invite.email}?',
          style: const TextStyle(color: Color(0xFFCDB4DB))),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('No')),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: const Text('Yes, Cancel', style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    ));
    if (confirm != true) return;

    final result = await _client.mutate(MutationOptions(
      document: gql(_cancelInviteMutation),
      variables: {'inviteId': invite.id},
    ));
    if (result.hasException) return;
    pendingInvites.removeWhere((i) => i.id == invite.id);
    Get.snackbar('Cancelled', 'Invite for ${invite.email} cancelled',
        backgroundColor: Colors.orange.withValues(alpha: 0.85), colorText: Colors.white);
  }

  Future<void> removeStaff(UserEntity member) async {
    final confirm = await Get.dialog<bool>(AlertDialog(
      backgroundColor: const Color(0xFF1A0D35),
      title: const Text('Remove Staff', style: TextStyle(color: Colors.white)),
      content: Text('Remove ${member.name ?? member.email} from your store?',
          style: const TextStyle(color: Color(0xFFCDB4DB))),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    ));
    if (confirm != true) return;

    final result = await _client.mutate(MutationOptions(
      document: gql(_removeStaffMutation),
      variables: {'userId': member.id},
    ));
    if (result.hasException) return;
    staff.removeWhere((s) => s.id == member.id);
    Get.snackbar('Removed', '${member.name ?? member.email} removed from store',
        backgroundColor: Colors.orange.withValues(alpha: 0.85), colorText: Colors.white);
  }

  void showAddStaffDialog() {
    nameCtrl.clear();
    emailCtrl.clear();
    Get.bottomSheet(
      _AddStaffSheet(controller: this),
      isScrollControlled: true,
    );
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    super.onClose();
  }
}

class _AddStaffSheet extends StatelessWidget {
  final StaffManagementController controller;
  const _AddStaffSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A0D35),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Scrollable form area ─────────────────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Invite Staff Member',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text(
                    'They will receive an email with an invite code to join your store.',
                    style: TextStyle(color: Color(0xFFCDB4DB), fontSize: 13)),
                const SizedBox(height: 24),
                _sheetField(controller.nameCtrl, 'Full Name',
                    Icons.person_outline_rounded, TextCapitalization.words),
                const SizedBox(height: 14),
                _sheetField(
                    controller.emailCtrl,
                    'Email Address',
                    Icons.email_outlined,
                    TextCapitalization.none,
                    TextInputType.emailAddress),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // ── Pinned Send Invite button — always visible above keyboard ────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: Obx(() => ElevatedButton(
                    onPressed:
                        controller.isInviting.value ? null : controller.inviteStaff,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B2FBE),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF7B2FBE).withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: controller.isInviting.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('Send Invite',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sheetField(TextEditingController ctrl, String label, IconData icon,
      TextCapitalization cap, [TextInputType kt = TextInputType.text]) {
    return TextField(
      controller: ctrl,
      keyboardType: kt,
      textCapitalization: cap,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFCDB4DB), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFFCDB4DB), size: 18),
        filled: true,
        fillColor: Colors.white10,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white24)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white24)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF7B2FBE))),
      ),
    );
  }
}
