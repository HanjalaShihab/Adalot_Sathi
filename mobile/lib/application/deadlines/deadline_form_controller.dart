import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/deadline.dart';
import '../../data/providers/repository_providers.dart';

/// Form state for creating/editing a deadline.
class DeadlineFormState {
  final bool isSubmitting;
  final String? error;
  final bool success;

  const DeadlineFormState({
    this.isSubmitting = false,
    this.error,
    this.success = false,
  });

  DeadlineFormState copyWith({bool? isSubmitting, String? error, bool? success}) {
    return DeadlineFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      success: success ?? this.success,
    );
  }
}

class DeadlineFormController extends Notifier<DeadlineFormState> {
  @override
  DeadlineFormState build() => const DeadlineFormState();

  /// Create a deadline under [caseId].
  Future<bool> create(int caseId, DeadlineInput input) async {
    state = const DeadlineFormState(isSubmitting: true);
    try {
      await ref.read(deadlineRepositoryProvider).createDeadline(caseId, input);
      state = const DeadlineFormState(success: true);
      return true;
    } catch (e) {
      state = DeadlineFormState(
        error: e is AppException ? e.message : 'Failed to save deadline.',
      );
      return false;
    }
  }

  /// Update an existing deadline.
  Future<bool> update(int caseId, int deadlineId, DeadlineInput input) async {
    state = const DeadlineFormState(isSubmitting: true);
    try {
      await ref.read(deadlineRepositoryProvider).updateDeadline(caseId, deadlineId, input);
      state = const DeadlineFormState(success: true);
      return true;
    } catch (e) {
      state = DeadlineFormState(
        error: e is AppException ? e.message : 'Failed to update deadline.',
      );
      return false;
    }
  }

  /// Mark a deadline as completed.
  Future<bool> markCompleted(int caseId, int deadlineId) async {
    state = const DeadlineFormState(isSubmitting: true);
    try {
      await ref.read(deadlineRepositoryProvider).markCompleted(caseId, deadlineId);
      state = const DeadlineFormState(success: true);
      return true;
    } catch (e) {
      state = DeadlineFormState(
        error: e is AppException ? e.message : 'Failed to update deadline.',
      );
      return false;
    }
  }

  /// Delete a deadline.
  Future<bool> delete(int caseId, int deadlineId) async {
    try {
      await ref.read(deadlineRepositoryProvider).deleteDeadline(caseId, deadlineId);
      return true;
    } catch (e) {
      state = DeadlineFormState(
        error: e is AppException ? e.message : 'Failed to delete deadline.',
      );
      return false;
    }
  }
}

final deadlineFormControllerProvider = NotifierProvider<DeadlineFormController, DeadlineFormState>(
  DeadlineFormController.new,
);


