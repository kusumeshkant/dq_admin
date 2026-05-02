import 'package:dq_admin/widgets/app_glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../domain/entity/user_entity.dart';
import '../../theme/app_theme.dart';
import 'staff_management_controller.dart';

class StaffManagementPage extends StatefulWidget {
  const StaffManagementPage({super.key});

  @override
  State<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends State<StaffManagementPage>
    with WidgetsBindingObserver {
  late final StaffManagementController c;

  @override
  void initState() {
    super.initState();
    c = Get.find<StaffManagementController>();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) c.loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0621),
      appBar: AppBar(
        title: const Text('Staff Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: c.loadAll,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'staff_fab',
        onPressed: c.showAddStaffDialog,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Invite Staff'),
        backgroundColor: AppTheme.primary,
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        }
        if (c.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, color: AppTheme.textSecondary, size: 48),
                const SizedBox(height: 12),
                Text(c.errorMessage.value, style: const TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: c.loadAll, child: const Text('Retry')),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: c.loadAll,
          color: AppTheme.primary,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [

              // ── Active Staff ──────────────────────────────────────────────
              _SectionHeader(
                icon: Icons.people_rounded,
                title: 'Active Staff',
                count: c.staff.length,
              ),
              const SizedBox(height: 10),

              if (c.staff.isEmpty)
                _EmptyState(
                  icon: Icons.person_off_rounded,
                  message: 'No staff members yet.\nTap "Invite Staff" to add your first team member.',
                )
              else
                ...c.staff.map((member) => _StaffCard(member: member, controller: c)),

              const SizedBox(height: 28),

              // ── Pending Invites ───────────────────────────────────────────
              _SectionHeader(
                icon: Icons.mail_outline_rounded,
                title: 'Pending Invites',
                count: c.pendingInvites.length,
              ),
              const SizedBox(height: 10),

              if (c.pendingInvites.isEmpty)
                _EmptyState(
                  icon: Icons.mark_email_read_rounded,
                  message: 'No pending invites.',
                )
              else
                ...c.pendingInvites.map((invite) => _InviteCard(invite: invite, controller: c)),
            ],
          ),
        );
      }),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;

  const _SectionHeader({required this.icon, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 18),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('$count', style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

// ── Staff member card ─────────────────────────────────────────────────────────
class _StaffCard extends StatelessWidget {
  final UserEntity member;
  final StaffManagementController controller;

  const _StaffCard({required this.member, required this.controller});

  @override
  Widget build(BuildContext context) {
    final initials = (member.name?.isNotEmpty == true)
        ? member.name!.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';

    return AppGlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(initials,
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name ?? 'Unnamed',
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(member.email ?? '',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                if (member.phone != null && member.phone!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(member.phone!,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ],
            ),
          ),

          // Role chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: member.role == 'admin'
                  ? Colors.amber.withValues(alpha: 0.15)
                  : Colors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              member.role?.toUpperCase() ?? 'STAFF',
              style: TextStyle(
                color: member.role == 'admin' ? Colors.amber : Colors.green,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Remove button (only for staff, not admin)
          if (member.role != 'admin')
            IconButton(
              icon: const Icon(Icons.person_remove_rounded, color: Colors.redAccent, size: 20),
              tooltip: 'Remove from store',
              onPressed: () => controller.removeStaff(member),
            ),
        ],
      ),
    );
  }
}

// ── Pending invite card ───────────────────────────────────────────────────────
class _InviteCard extends StatelessWidget {
  final PendingInvite invite;
  final StaffManagementController controller;

  const _InviteCard({required this.invite, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Mail icon
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mail_outline_rounded, color: Colors.orange, size: 22),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invite.name,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(invite.email,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                // Invite code chip — tap to copy
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: invite.token));
                    Get.snackbar('Copied!', 'Invite code copied to clipboard.',
                        backgroundColor: Colors.green.withValues(alpha: 0.85),
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(invite.token,
                            style: const TextStyle(color: Colors.white70, fontSize: 11,
                                fontFamily: 'monospace', letterSpacing: 1.5)),
                        const SizedBox(width: 6),
                        const Icon(Icons.copy_rounded, color: Colors.white38, size: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cancel
          IconButton(
            icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 20),
            tooltip: 'Cancel invite',
            onPressed: () => controller.cancelInvite(invite),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 40),
          const SizedBox(height: 10),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}
