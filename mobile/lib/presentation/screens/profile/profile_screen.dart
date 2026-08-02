import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user.dart';

/// Profile screen: basic info, subscription tier + usage, logout.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                const SizedBox(height: 16),
                _buildHeader(user),
                const SizedBox(height: 20),
                _buildSubscriptionCard(context, ref, user),
                const SizedBox(height: 16),
                _buildInfoCard(user),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: authState.isLoading
                        ? null
                        : () => _confirmLogout(context, ref),
                    icon: const Icon(Icons.logout),
                    label: const Text('Log out'),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Adalot Sathi v1.0.0\nআদালত সাথী — Legal Case Deadline Manager',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(User user) {
    final initials = user.name
        .split(' ')
        .where((s) => s.isNotEmpty)
        .map((s) => s[0])
        .take(2)
        .join()
        .toUpperCase();

    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.primary,
          child: Text(
            initials,
            style: const TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user.name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        if (user.phone != null && user.phone!.isNotEmpty)
          Text(
            user.phone!,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
      ],
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, WidgetRef ref, User user) {
    final isPaid = user.isPaid;
    final used = user.subscription.activeCasesCount;
    final limit = user.subscription.activeCaseLimit;
    final remaining = user.subscription.remainingActiveSlots;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPaid ? Icons.workspace_premium : Icons.lock_outline,
                  color: isPaid ? AppColors.accent : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  isPaid ? 'Pro Plan' : 'Free Plan',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const Spacer(),
                if (isPaid)
                  _Badge(text: 'ACTIVE', color: AppColors.success)
                else
                  _Badge(text: 'FREE', color: AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: 12),
            if (isPaid) ...[
              const Text(
                'Unlimited active cases · Push + SMS reminders',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              if (user.subscriptionExpiresAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Renews ${DateFormat('d MMM yyyy').format(DateTime.parse(user.subscriptionExpiresAt!))}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ),
            ] else ...[
              const Text(
                'Push reminders on up to 5 active cases',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              if (limit != null && limit > 0)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: used / limit,
                    minHeight: 8,
                    backgroundColor: AppColors.surfaceAlt,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                '$used of $limit active cases used · $remaining slot${remaining == 1 ? '' : 's'} left',
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Upgrade flow is coming soon.')),
                    );
                  },
                  icon: const Icon(Icons.workspace_premium),
                  label: const Text('Upgrade to Pro'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(User user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            _infoRow(Icons.badge_outlined, 'Role', user.role == UserRole.admin ? 'Administrator' : 'Lawyer'),
            if (user.createdAt != null)
              _infoRow(
                Icons.calendar_today_outlined,
                'Joined',
                DateFormat('d MMM yyyy').format(user.createdAt!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to log in again to access your cases.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}


