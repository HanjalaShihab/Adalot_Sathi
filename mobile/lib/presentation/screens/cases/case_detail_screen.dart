import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/cases/case_detail_controller.dart';
import '../../../application/deadlines/deadline_form_controller.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/deadline.dart';
import '../../../data/models/legal_case.dart';
import '../../widgets/deadline_tile.dart';
import '../../widgets/state_widgets.dart';

class CaseDetailScreen extends ConsumerWidget {
  final int caseId;
  const CaseDetailScreen({super.key, required this.caseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(caseDetailControllerProvider(caseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Details'),
        actions: [
          IconButton(
            tooltip: 'Edit case',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoutes.caseEdit,
              arguments: {'id': caseId},
            ),
          ),
        ],
      ),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, CaseDetailState state) {
    if (state.isLoading && state.legalCase == null) {
      return const LoadingState(message: 'Loading case…');
    }

    if (state.error != null && state.legalCase == null) {
      return ErrorState(message: state.error!);
    }

    final legalCase = state.legalCase;
    if (legalCase == null) {
      return const ErrorState(message: 'Case not found.');
    }

    final pendingDeadlines = legalCase.deadlines.where((d) => !d.isCompleted).toList();
    final completedDeadlines = legalCase.deadlines.where((d) => d.isCompleted).toList();

    return RefreshIndicator(
      onRefresh: () => ref.read(caseDetailControllerProvider(caseId).notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          _CaseInfoCard(legalCase: legalCase),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Deadlines',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ),
                Text(
                  '${pendingDeadlines.length} pending',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (pendingDeadlines.isEmpty && completedDeadlines.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: EmptyState(
                icon: Icons.event_note,
                title: 'No deadlines yet',
                message: 'Add a hearing, filing, or appeal deadline to this case.',
              ),
            )
          else ...[
            ...pendingDeadlines.map(
              (d) => DeadlineTile(
                deadline: d,
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.deadlineEdit,
                  arguments: {'caseId': caseId, 'deadlineId': d.id},
                ),
                onComplete: () => _completeDeadline(context, ref, d),
              ),
            ),
            if (completedDeadlines.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  'Completed',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ),
              ...completedDeadlines.map(
                (d) => DeadlineTile(
                  deadline: d,
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.deadlineEdit,
                    arguments: {'caseId': caseId, 'deadlineId': d.id},
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _completeDeadline(BuildContext context, WidgetRef ref, Deadline d) async {
    final ok = await ref.read(deadlineFormControllerProvider.notifier).markCompleted(caseId, d.id);
    if (!context.mounted) return;
    if (ok) {
      ref.read(caseDetailControllerProvider(caseId).notifier).refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deadline marked as completed.')),
      );
    } else {
      final error = ref.read(deadlineFormControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Failed.')));
    }
  }
}

class _CaseInfoCard extends StatelessWidget {
  final LegalCase legalCase;
  const _CaseInfoCard({required this.legalCase});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    legalCase.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ),
                _StatusBadge(status: legalCase.status),
              ],
            ),
            if (legalCase.caseNumber != null && legalCase.caseNumber!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Case No: ${legalCase.caseNumber!}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
            const Divider(height: 24),
            _infoRow(Icons.person_outline, 'Client', legalCase.clientName.isEmpty ? '—' : legalCase.clientName),
            if (legalCase.clientPhone != null && legalCase.clientPhone!.isNotEmpty)
              _infoRow(Icons.phone_outlined, 'Phone', legalCase.clientPhone!),
            if (legalCase.courtName != null && legalCase.courtName!.isNotEmpty)
              _infoRow(Icons.location_on_outlined, 'Court', legalCase.courtName!),
            if (legalCase.opposingParty != null && legalCase.opposingParty!.isNotEmpty)
              _infoRow(Icons.gavel, 'Opposing party', legalCase.opposingParty!),
            if (legalCase.caseType != null && legalCase.caseType!.isNotEmpty)
              _infoRow(Icons.category_outlined, 'Case type', legalCase.caseType!),
            if (legalCase.notes != null && legalCase.notes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text('Notes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(legalCase.notes!, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
}

class _StatusBadge extends StatelessWidget {
  final CaseStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (status) {
      CaseStatus.active => ('Active', AppColors.success, const Color(0xFFE8F5EE)),
      CaseStatus.closed => ('Closed', AppColors.textSecondary, AppColors.surfaceAlt),
      CaseStatus.onHold => ('On Hold', AppColors.warning, const Color(0xFFFEF0E0)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}


