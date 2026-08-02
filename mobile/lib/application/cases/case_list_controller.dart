import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/legal_case.dart';
import '../../data/providers/repository_providers.dart';

class CaseListState {
  final List<LegalCase> cases;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final String? search;
  final String? statusFilter;
  final int currentPage;
  final int lastPage;

  const CaseListState({
    this.cases = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.search,
    this.statusFilter,
    this.currentPage = 0,
    this.lastPage = 1,
  });

  CaseListState copyWith({
    List<LegalCase>? cases,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    String? search,
    String? statusFilter,
    int? currentPage,
    int? lastPage,
  }) {
    return CaseListState(
      cases: cases ?? this.cases,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      search: search ?? this.search,
      statusFilter: statusFilter ?? this.statusFilter,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
    );
  }

  bool get hasMore => currentPage < lastPage;
}

class CaseListController extends Notifier<CaseListState> {
  @override
  CaseListState build() {
    _load(reset: true);
    return const CaseListState(isLoading: true);
  }

  Future<void> _load({bool reset = false}) async {
    final current = state;
    final page = reset ? 1 : current.currentPage + 1;

    state = reset
        ? current.copyWith(isLoading: true, error: null)
        : current.copyWith(isLoadingMore: true, error: null);

    try {
      final repo = ref.read(caseRepositoryProvider);
      final result = await repo.getCases(
        search: current.search,
        status: current.statusFilter,
        page: page,
        perPage: 20,
      );

      state = state.copyWith(
        cases: reset ? result.cases : [...current.cases, ...result.cases],
        isLoading: false,
        isLoadingMore: false,
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e is AppException ? e.message : 'Failed to load cases.',
      );
    }
  }

  void setSearch(String? search) {
    state = state.copyWith(search: search);
    _load(reset: true);
  }

  void setStatusFilter(String? status) {
    state = state.copyWith(statusFilter: status);
    _load(reset: true);
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.isLoadingMore) return;
    await _load(reset: false);
  }

  Future<void> refresh() => _load(reset: true);
}

final caseListControllerProvider = NotifierProvider<CaseListController, CaseListState>(
  CaseListController.new,
);


