import '../models/deadline.dart';

/// Deadline data source contract.
abstract interface class DeadlineRepository {
  /// All deadlines for a case.
  Future<List<Deadline>> getDeadlines(int caseId, {String? status});

  /// A single deadline.
  Future<Deadline> getDeadline(int caseId, int deadlineId);

  /// Create a deadline under a case.
  Future<Deadline> createDeadline(int caseId, DeadlineInput input);

  /// Update a deadline.
  Future<Deadline> updateDeadline(int caseId, int deadlineId, DeadlineInput input);

  /// Delete a deadline.
  Future<void> deleteDeadline(int caseId, int deadlineId);

  /// Mark a deadline as completed.
  Future<Deadline> markCompleted(int caseId, int deadlineId);

  /// Upcoming deadlines across all the user's cases, sorted by due date asc.
  Future<List<Deadline>> getUpcoming({DateTime? from, DateTime? to, String? eventType});
}


