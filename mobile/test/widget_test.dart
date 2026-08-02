import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adalot_sathi/core/theme/app_colors.dart';
import 'package:adalot_sathi/data/models/deadline.dart';
import 'package:adalot_sathi/data/models/legal_case.dart';
import 'package:adalot_sathi/presentation/widgets/case_card.dart';
import 'package:adalot_sathi/presentation/widgets/deadline_tile.dart';

void main() {
  group('Adalot Sathi widgets', () {
    testWidgets('DeadlineTile renders title, date urgency, and complete action',
        (tester) async {
      final deadline = Deadline(
        id: 1,
        caseId: 10,
        title: 'Hearing – Title Dispute',
        eventType: DeadlineEventType.hearing,
        dueDate: DateTime.now(),
        reminderDaysBefore: const [7, 3, 1],
      );

      var completed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeadlineTile(
              deadline: deadline,
              onComplete: () => completed = true,
            ),
          ),
        ),
      );

      expect(find.text('Hearing – Title Dispute'), findsOneWidget);
      expect(find.text('Hearing'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.check_circle_outline));
      expect(completed, isTrue);
    });

    testWidgets('Completed deadline shows strikethrough check', (tester) async {
      final deadline = Deadline(
        id: 2,
        caseId: 10,
        title: 'File written statement',
        eventType: DeadlineEventType.filing,
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        status: DeadlineStatus.completed,
        reminderDaysBefore: const [7, 3, 1],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DeadlineTile(deadline: deadline)),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('CaseCard shows title, case number, client, and pending count',
        (tester) async {
      final legalCase = LegalCase(
        id: 1,
        userId: 5,
        title: 'Rahim vs. Karim – Title Dispute',
        caseNumber: 'Civil Suit 145/2023',
        clientName: 'Abdul Rahim',
        courtName: 'Dhaka District Court',
        status: CaseStatus.active,
        deadlines: [
          Deadline(
            id: 1,
            caseId: 1,
            title: 'Hearing',
            eventType: DeadlineEventType.hearing,
            dueDate: DateTime.now().add(const Duration(days: 2)),
          ),
          Deadline(
            id: 2,
            caseId: 1,
            title: 'Filing',
            eventType: DeadlineEventType.filing,
            dueDate: DateTime.now().add(const Duration(days: 9)),
            status: DeadlineStatus.completed,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CaseCard(legalCase: legalCase)),
        ),
      );

      expect(find.text('Rahim vs. Karim – Title Dispute'), findsOneWidget);
      expect(find.text('Civil Suit 145/2023'), findsOneWidget);
      expect(find.text('Abdul Rahim'), findsOneWidget);
      expect(find.text('1 pending deadline'), findsOneWidget);
    });

    test('AppColors exposes the official navy & gold palette', () {
      expect(AppColors.primary, const Color(0xFF1F4E79));
      expect(AppColors.accent, const Color(0xFFC9A227));
      expect(AppColors.urgencyOverdue, AppColors.danger);
    });
  });
}

