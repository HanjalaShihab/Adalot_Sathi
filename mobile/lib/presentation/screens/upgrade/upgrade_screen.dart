import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user.dart';

/// Upgrade prompt shown when a free-tier user hits the 5-active-case limit.
///
/// This is the main monetization moment — designed to be clear, non-punishing,
/// and to communicate exactly what upgrading unlocks.
class UpgradeScreen extends ConsumerWidget {
  const UpgradeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final args = ModalRoute.of(context)?.settings.arguments;
    final limit = args is Map ? (args['limit'] as int? ?? 5) : 5;

    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero icon.
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.workspace_premium, color: AppColors.accent, size: 52),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'You\'ve reached your free limit',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'The free plan includes up to $limit active cases. Upgrade to Adalot Sathi Pro to manage unlimited cases and get SMS reminders so you never miss a deadline.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Usage summary.
            if (user != null) _UsageCard(user: user),
            const SizedBox(height: 20),

            // Pro plan card.
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.workspace_premium, color: AppColors.accent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Adalot Sathi Pro',
                        style: TextStyle(
                          color: AppColors.textOnPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const _ProFeatureRow(icon: Icons.all_inclusive, text: 'Unlimited active cases'),
                  const _ProFeatureRow(icon: Icons.notifications_active, text: 'Push notifications on every deadline'),
                  const _ProFeatureRow(icon: Icons.sms, text: 'SMS reminders so nothing slips through'),
                  const _ProFeatureRow(icon: Icons.support_agent, text: 'Priority support'),
                  const SizedBox(height: 14),
                  const Text(
                    '৳99/month or ৳999/year',
                    style: TextStyle(
                      color: AppColors.textOnPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Cancel anytime. Annual plan saves 2 months.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // CTA.
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textOnAccent,
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: () {
                // Phase: real billing is not yet wired (no payment provider).
                // This is the future subscription-purchase entry point.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Upgrade flow is coming soon. Contact us to enable Pro.'),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Upgrade to Pro'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Not now'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageCard extends StatelessWidget {
  final User user;
  const _UsageCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final used = user.subscription.activeCasesCount;
    final limit = user.subscription.activeCaseLimit ?? 5;
    final remaining = user.subscription.remainingActiveSlots;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Free plan usage',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: limit == 0 ? 0 : used / limit,
              minHeight: 8,
              backgroundColor: AppColors.surfaceAlt,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$used of $limit active cases used · $remaining slot${remaining == 1 ? '' : 's'} left',
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _ProFeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ProFeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: AppColors.textOnPrimary, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}


