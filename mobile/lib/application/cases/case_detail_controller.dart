import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/legal_case.dart';
import '../../data/providers/repository_providers.dart';

class CaseDetailState {
  final LegalCase? legalCase;
  final bool isLoading;
  final String? error;
  final bool isSubmitting;

  const CaseDetailState({
    this.legalCase,
    this.isLoading = false,
    this.error,
    this.isSubmitting = false,
  });

  CaseDetailState copyWith({
    LegalCase? legalCase,
    bool? isLoading,
    String? error,
    bool? isSubmitting,
  }) {
    return CaseDetailState(
      legalCase: legalCase ?? this.legalCase,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// Family of providers parameterized by case id.
class CaseDetailController extends FamilyNotifier<CaseDetailState, int> {
  @override
  CaseDetailState build(int caseId) {
    _load(caseId);
    return const CaseDetailState(isLoading: true);
  }

  Future<void> _load(int caseId) async {
    try {
      final repo = ref.read(caseRepositoryProvider);
      final legalCase = await repo.getCase(caseId);
      state = CaseDetailState(legalCase: legalCase, isLoading: false);
    } catch (e) {
      state = CaseDetailState(
        isLoading: false,
        error: e is AppException ? e.message : 'Failed to load case.',
      );
    }
  }

  Future<void> refresh() async {
    final caseId = arg;
    await _load(caseId);
  }

  Future<void> updateStatus(CaseStatus status) async {
    final current = state.legalCase;
    if (current == null || current.status == status) return;

    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final repo = ref.read(caseRepositoryProvider);
      final input = CaseInput(
        title: current.title,
        caseNumber: current.caseNumber,
        clientName: current.clientName,
        clientPhone: current.clientPhone,
        courtName: current.courtName,
        opposingParty: current.opposingParty,
        caseType: current.caseType,
        status: status,
        notes: current.notes,
      );
      final updated = await repo.updateCase(current.id, input);
      state = CaseDetailState(legalCase: updated, isSubmitting: false);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e is AppException ? e.message : 'Failed to update case.',
      );
    }
  }

  Future<void> deleteCase() async {
    final current = state.legalCase;
    if (current == null) return;
    final repo = ref.read(caseRepositoryProvider);
    await repo.deleteCase(current.id);
  }
}

final caseDetailControllerProvider = NotifierProvider.family<CaseDetailController, CaseDetailState, int>(
  CaseDetailController.new,
);


