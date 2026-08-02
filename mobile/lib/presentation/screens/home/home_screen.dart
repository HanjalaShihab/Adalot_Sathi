import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../application/deadlines/deadline_form_controller.dart';
import '../../../application/home/home_controller.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/deadline.dart';
import '../../widgets/deadline_tile.dart';
import '../../widgets/state_widgets.dart';

/// "Today & upcoming" — the single most important screen.
///
/// Deadlines grouped into Overdue / Today / This week / Later, color-coded by
/// urgency so a lawyer understands what needs attention in 2 seconds.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Adalot Sathi'),
            if (user != null)
              Text(
                'Welcome, ${user.name.split(' ').first}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Debug: simulate notification tap',
            icon: const Icon(Icons.notifications_none),
            onPressed: () => _simulateDeepLink(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
        child: _buildBody(context, ref, homeState),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, HomeState state) {
    if (state.isLoading) {
      return const LoadingState(message: 'Loading your deadlines…');
    }

    if (state.error != null && state.grouped == null) {
      return ErrorState(message: state.error!, onRetry: () => ref.read(homeControllerProvider.notifier).refresh());
    }

    final grouped = state.grouped;
    if (grouped == null || grouped.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          EmptyState(
            icon: Icons.event_available,
            title: 'No upcoming deadlines',
            message: 'You\'re all caught up. Add a case and its deadlines to see them here.',
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.urgencyOverdue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.danger, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(state.error!, style: const TextStyle(fontSize: 13, color: AppColors.danger)),
                  ),
                ],
              ),
            ),
          ),
        _buildBucket(
          context,
          ref,
          title: 'Overdue',
          subtitle: 'Needs your attention now',
          color: AppColors.urgencyOverdue,
          deadlines: grouped.overdue,
        ),
        _buildBucket(
          context,
          ref,
          title: 'Today',
          subtitle: 'Due today — don\'t miss these',
          color: AppColors.urgencyToday,
          deadlines: grouped.today,
        ),
        _buildBucket(
          context,
          ref,
          title: 'This week',
          subtitle: 'Due in the next 7 days',
          color: AppColors.urgencyWeek,
          deadlines: grouped.week,
        ),
        _buildBucket(
          context,
          ref,
          title: 'Later',
          subtitle: 'On the horizon',
          color: AppColors.urgencyLater,
          deadlines: grouped.later,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBucket(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required Color color,
    required List<Deadline> deadlines,
  }) {
    if (deadlines.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        ...deadlines.map(
          (d) => DeadlineTile(
            deadline: d,
            showCaseContext: true,
            onTap: () => _openDeadline(context, d),
            onComplete: () => _completeDeadline(context, ref, d),
          ),
        ),
      ],
    );
  }

  Future<void> _completeDeadline(BuildContext context, WidgetRef ref, Deadline d) async {
    final ok = await ref.read(deadlineFormControllerProvider.notifier).markCompleted(d.caseId, d.id);
    if (!context.mounted) return;
    if (ok) {
      ref.read(homeControllerProvider.notifier).refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deadline marked as completed.')),
      );
    } else {
      final error = ref.read(deadlineFormControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed to complete deadline.')),
      );
    }
  }

  void _openDeadline(BuildContext context, Deadline d) {
    final caseId = d.caseId;
    Navigator.of(context).pushNamed(
      AppRoutes.deepLink,
      arguments: {'type': 'deadline', 'caseId': caseId, 'deadlineId': d.id},
    );
  }

  /// Debug-only trigger simulating a push notification tap. Real push wiring
  /// will call the exact same routing path.
  void _simulateDeepLink(BuildContext context, WidgetRef ref) {
    final grouped = ref.read(homeControllerProvider).grouped;
    if (grouped == null || grouped.isEmpty) return;
    final all = [...grouped.overdue, ...grouped.today, ...grouped.week, ...grouped.later];
    if (all.isEmpty) return;
    final target = all.first;
    _openDeadline(context, target);
  }
}


