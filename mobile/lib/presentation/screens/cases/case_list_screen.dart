import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/cases/case_list_controller.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/legal_case.dart';
import '../../../data/providers/repository_providers.dart';
import '../../widgets/case_card.dart';
import '../../widgets/state_widgets.dart';

/// Searchable, filterable list of the user's cases.
class CaseListScreen extends ConsumerStatefulWidget {
  const CaseListScreen({super.key});

  @override
  ConsumerState<CaseListScreen> createState() => _CaseListScreenState();
}

class _CaseListScreenState extends ConsumerState<CaseListScreen> {
  final _searchController = TextEditingController();
  String? _statusFilter;
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(caseListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cases'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
            tooltip: 'Filter by status',
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add case',
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.caseCreate),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                // Debounce via a short timer is handled by the controller reset.
                ref.read(caseListControllerProvider.notifier).setSearch(value.trim());
              },
              decoration: InputDecoration(
                hintText: 'Search by case no., client, or title',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(caseListControllerProvider.notifier).setSearch(null);
                        },
                      ),
              ),
            ),
          ),
          if (_showFilters) _buildFilterRow(),
          Expanded(child: _buildBody(context, state)),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          _filterChip('All', null),
          const SizedBox(width: 8),
          _filterChip('Active', 'active'),
          const SizedBox(width: 8),
          _filterChip('On Hold', 'on_hold'),
          const SizedBox(width: 8),
          _filterChip('Closed', 'closed'),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String? value) {
    final selected = _statusFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() => _statusFilter = selected ? null : value);
        ref.read(caseListControllerProvider.notifier).setStatusFilter(selected ? null : value);
      },
    );
  }

  Widget _buildBody(BuildContext context, CaseListState state) {
    if (state.isLoading && state.cases.isEmpty) {
      return const LoadingState(message: 'Loading cases…');
    }

    if (state.error != null && state.cases.isEmpty) {
      return ErrorState(message: state.error!, onRetry: () => ref.read(caseListControllerProvider.notifier).refresh());
    }

    if (state.cases.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 100),
          EmptyState(
            icon: Icons.folder_open,
            title: 'No cases found',
            message: 'Search for your cases or add a new one to get started.',
            actionLabel: 'Add Case',
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: state.cases.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.cases.length) {
          // Loading-more footer.
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        final legalCase = state.cases[index];
        return CaseCard(
          legalCase: legalCase,
          onTap: () => Navigator.of(context).pushNamed(
            AppRoutes.caseDetail,
            arguments: legalCase.id,
          ),
          onLongPress: () => _showDeleteDialog(context, legalCase),
        );
      },
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, LegalCase legalCase) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete case?'),
        content: Text(
          'Delete "${legalCase.title}"? Its deadlines will also be removed. This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(caseRepositoryProvider).deleteCase(legalCase.id);
        ref.read(caseListControllerProvider.notifier).refresh();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Case deleted.')),
          );
        }
      } on AppException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
        }
      }
    }
  }
}


