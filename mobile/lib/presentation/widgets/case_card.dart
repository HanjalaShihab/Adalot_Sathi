import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/legal_case.dart';

/// A case summary card for the case list screen.
class CaseCard extends StatelessWidget {
  final LegalCase legalCase;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CaseCard({
    super.key,
    required this.legalCase,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final pendingCount =
        legalCase.deadlines.where((d) => !d.isCompleted).length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            legalCase.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        _StatusBadge(status: legalCase.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (legalCase.caseNumber != null && legalCase.caseNumber!.isNotEmpty)
                      Text(
                        legalCase.caseNumber!,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            legalCase.clientName.isEmpty
                                ? 'No client'
                                : legalCase.clientName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                          ),
                        ),
                        if (legalCase.courtName != null && legalCase.courtName!.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              legalCase.courtName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: pendingCount > 0 ? AppColors.accentSoft : AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            pendingCount > 0
                                ? '$pendingCount pending deadline${pendingCount == 1 ? '' : 's'}'
                                : 'No pending deadlines',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: pendingCount > 0 ? AppColors.textOnAccent : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
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
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}


