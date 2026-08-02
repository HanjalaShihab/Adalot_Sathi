import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/deadline.dart';
import '../../data/providers/repository_providers.dart';

/// Groups upcoming deadlines into urgency buckets for the home screen.
enum DeadlineBucket { overdue, today, week, later }

extension DeadlineBucketX on DeadlineBucket {
  String get label => switch (this) {
        DeadlineBucket.overdue => 'Overdue',
        DeadlineBucket.today => 'Today',
        DeadlineBucket.week => 'This week',
        DeadlineBucket.later => 'Later',
      };

  String get subtitle => switch (this) {
        DeadlineBucket.overdue => 'Needs your attention now',
        DeadlineBucket.today => 'Due today — don\'t miss these',
        DeadlineBucket.week => 'Due in the next 7 days',
        DeadlineBucket.later => 'On the horizon',
      };
}

/// Groups upcoming deadlines by urgency bucket, each sorted by due date.
class UpcomingGrouped {
  final List<Deadline> overdue;
  final List<Deadline> today;
  final List<Deadline> week;
  final List<Deadline> later;

  const UpcomingGrouped({
    required this.overdue,
    required this.today,
    required this.week,
    required this.later,
  });

  bool get isEmpty => overdue.isEmpty && today.isEmpty && week.isEmpty && later.isEmpty;

  int get totalCount => overdue.length + today.length + week.length + later.length;

  DeadlineBucket bucketFor(Deadline d) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final due = d.dueDate;
    final diff = due.difference(todayStart).inDays;

    if (diff < 0) return DeadlineBucket.overdue;
    if (diff == 0) return DeadlineBucket.today;
    if (diff <= 7) return DeadlineBucket.week;
    return DeadlineBucket.later;
  }
}

class HomeState {
  final UpcomingGrouped? grouped;
  final bool isLoading;
  final String? error;

  const HomeState({this.grouped, this.isLoading = false, this.error});

  HomeState copyWith({UpcomingGrouped? grouped, bool? isLoading, String? error}) {
    return HomeState(
      grouped: grouped ?? this.grouped,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Loads upcoming deadlines for the home screen and groups them by urgency.
class HomeController extends Notifier<HomeState> {
  @override
  HomeState build() {
    _load();
    return const HomeState(isLoading: true);
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(deadlineRepositoryProvider);
      final deadlines = await repo.getUpcoming();
      final grouped = _group(deadlines);
      state = HomeState(grouped: grouped, isLoading: false);
    } catch (e) {
      state = HomeState(
        isLoading: false,
        error: e is AppException ? e.message : 'Failed to load deadlines.',
      );
    }
  }

  UpcomingGrouped _group(List<Deadline> deadlines) {
    final overdue = <Deadline>[];
    final today = <Deadline>[];
    final week = <Deadline>[];
    final later = <Deadline>[];

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekEnd = todayStart.add(const Duration(days: 7));

    for (final d in deadlines) {
      final due = d.dueDate;
      if (due.isBefore(todayStart)) {
        overdue.add(d);
      } else if (due == todayStart || due.difference(todayStart).inDays == 0) {
        today.add(d);
      } else if (due.isBefore(weekEnd)) {
        week.add(d);
      } else {
        later.add(d);
      }
    }

    return UpcomingGrouped(
      overdue: overdue,
      today: today,
      week: week,
      later: later,
    );
  }

  Future<void> refresh() => _load();
}

final homeControllerProvider = NotifierProvider<HomeController, HomeState>(
  HomeController.new,
);


