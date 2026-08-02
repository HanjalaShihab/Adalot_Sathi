import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/deadline.dart';

/// A single deadline row, color-coded by urgency.
class DeadlineTile extends StatelessWidget {
  final Deadline deadline;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final bool showCaseContext;

  const DeadlineTile({
    super.key,
    required this.deadline,
    this.onTap,
    this.onComplete,
    this.showCaseContext = false,
  });

  Color get _urgencyColor {
    if (deadline.isCompleted) return AppColors.success;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final diff = deadline.dueDate.difference(todayStart).inDays;
    if (diff < 0) return AppColors.urgencyOverdue;
    if (diff == 0) return AppColors.urgencyToday;
    if (diff <= 7) return AppColors.urgencyWeek;
    return AppColors.urgencyLater;
  }

  String get _dateLabel {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final due = deadline.dueDate;
    final diff = due.difference(todayStart).inDays;

    if (diff < 0) return '${diff.abs()}d overdue';
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return DateFormat('EEE, d MMM').format(due);
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = deadline.isCompleted;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Urgency indicator.
              Container(
                width: 5,
                height: 44,
                decoration: BoxDecoration(
                  color: _urgencyColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              // Content.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deadline.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (showCaseContext && deadline.caseSummary != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          deadline.caseSummary!['title']?.toString() ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.primary),
                        ),
                      ),
                    Row(
                      children: [
                        Icon(
                          _eventIcon(deadline.eventType),
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          deadline.eventType.label,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.event,
                          size: 14,
                          color: _urgencyColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _dateLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _urgencyColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Complete action.
              if (!isCompleted && onComplete != null)
                IconButton(
                  icon: const Icon(Icons.check_circle_outline, color: AppColors.success),
                  tooltip: 'Mark completed',
                  onPressed: onComplete,
                )
              else if (isCompleted)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(Icons.check_circle, color: AppColors.success, size: 22),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _eventIcon(DeadlineEventType type) => switch (type) {
        DeadlineEventType.hearing => Icons.gavel,
        DeadlineEventType.filing => Icons.article_outlined,
        DeadlineEventType.appeal => Icons.account_balance,
        DeadlineEventType.other => Icons.event_note,
      };
}


