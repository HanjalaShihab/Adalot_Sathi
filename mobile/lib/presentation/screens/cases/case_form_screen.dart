import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/cases/case_list_controller.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/legal_case.dart';
import '../../../data/providers/repository_providers.dart';
import '../../widgets/state_widgets.dart';

/// Add/Edit case form.
///
/// When the repository returns [CaseLimitReachedException] (free tier, 5-case
/// limit), a dedicated, non-punishing upgrade prompt is shown instead of a
/// generic error toast.
class CaseFormScreen extends ConsumerStatefulWidget {
  final int? caseId;
  const CaseFormScreen({super.key, this.caseId});

  @override
  ConsumerState<CaseFormScreen> createState() => _CaseFormScreenState();
}

class _CaseFormScreenState extends ConsumerState<CaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _caseNumberController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _courtNameController = TextEditingController();
  final _opposingPartyController = TextEditingController();
  final _caseTypeController = TextEditingController();
  final _notesController = TextEditingController();
  CaseStatus _status = CaseStatus.active;
  bool _isSubmitting = false;
  bool _isLoading = false;

  bool get _isEdit => widget.caseId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) _loadCase();
  }

  Future<void> _loadCase() async {
    setState(() => _isLoading = true);
    try {
      final legalCase = await ref.read(caseRepositoryProvider).getCase(widget.caseId!);
      _titleController.text = legalCase.title;
      _caseNumberController.text = legalCase.caseNumber ?? '';
      _clientNameController.text = legalCase.clientName;
      _clientPhoneController.text = legalCase.clientPhone ?? '';
      _courtNameController.text = legalCase.courtName ?? '';
      _opposingPartyController.text = legalCase.opposingParty ?? '';
      _caseTypeController.text = legalCase.caseType ?? '';
      _notesController.text = legalCase.notes ?? '';
      _status = legalCase.status;
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _caseNumberController.dispose();
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _courtNameController.dispose();
    _opposingPartyController.dispose();
    _caseTypeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final input = CaseInput(
      title: _titleController.text.trim(),
      caseNumber: _caseNumberController.text.trim().isEmpty ? null : _caseNumberController.text.trim(),
      clientName: _clientNameController.text.trim(),
      clientPhone: _clientPhoneController.text.trim().isEmpty ? null : _clientPhoneController.text.trim(),
      courtName: _courtNameController.text.trim().isEmpty ? null : _courtNameController.text.trim(),
      opposingParty: _opposingPartyController.text.trim().isEmpty ? null : _opposingPartyController.text.trim(),
      caseType: _caseTypeController.text.trim().isEmpty ? null : _caseTypeController.text.trim(),
      status: _status,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(caseRepositoryProvider);
      if (_isEdit) {
        await repo.updateCase(widget.caseId!, input);
      } else {
        await repo.createCase(input);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ref.read(caseListControllerProvider.notifier).refresh();
    } on CaseLimitReachedException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      // The monetization moment — a proper screen, not a toast.
      final shouldUpgrade = await Navigator.of(context).pushNamed<bool>(
        AppRoutes.upgrade,
        arguments: {'limit': e.limit},
      );
      if (shouldUpgrade == true && mounted) Navigator.of(context).pop(false);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Case' : 'Add Case')),
      body: _isLoading
          ? const LoadingState()
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Case title *',
                          hintText: 'e.g. Rahim vs. Karim – Title Dispute',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _caseNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Case number',
                          hintText: 'e.g. Civil Suit 145/2023',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _clientNameController,
                        decoration: const InputDecoration(
                          labelText: 'Client name *',
                          hintText: 'e.g. Abdul Rahim',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Client name is required' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _clientPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Client phone',
                          hintText: '01XXXXXXXXX',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _courtNameController,
                        decoration: const InputDecoration(
                          labelText: 'Court',
                          hintText: 'e.g. Dhaka District Court',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _opposingPartyController,
                        decoration: const InputDecoration(
                          labelText: 'Opposing party',
                          hintText: 'e.g. Karim Mia',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _caseTypeController,
                        decoration: const InputDecoration(
                          labelText: 'Case type',
                          hintText: 'e.g. Civil, Criminal, Family, Property',
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Status',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<CaseStatus>(
                        segments: const [
                          ButtonSegment(value: CaseStatus.active, label: Text('Active')),
                          ButtonSegment(value: CaseStatus.onHold, label: Text('On Hold')),
                          ButtonSegment(value: CaseStatus.closed, label: Text('Closed')),
                        ],
                        selected: {_status},
                        onSelectionChanged: (s) => setState(() => _status = s.first),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          hintText: 'Anything relevant about this case…',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.textOnPrimary,
                                ),
                              )
                            : Text(_isEdit ? 'Save Changes' : 'Add Case'),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}


