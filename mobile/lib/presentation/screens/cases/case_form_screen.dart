import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../application/cases/case_list_controller.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/case_document.dart';
import '../../../data/models/legal_case.dart';
import '../../../data/providers/repository_providers.dart';
import '../../widgets/state_widgets.dart';

/// Add/Edit case form.
///
/// Organized into clearly labeled sections. Basic Information, Client
/// Information and Important Dates are required and shown fully expanded;
/// optional sections (Court, Opposing Party, Financial, Documents, Case
/// Progress) are collapsible dropdowns so a lawyer can create a case quickly
/// and enrich it later.
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

  // Basic info.
  final _titleController = TextEditingController();
  final _caseNumberController = TextEditingController();
  final _caseTypeController = TextEditingController();
  CaseStatus _status = CaseStatus.active;

  // Client info.
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _clientAddressController = TextEditingController();

  // Court info.
  final _courtNameController = TextEditingController();
  final _judgeNameController = TextEditingController();
  final _benchController = TextEditingController();

  // Important dates.
  DateTime? _filingDate;
  DateTime? _nextHearingDate;
  DateTime? _judgmentDate;
  DateTime? _reminderDate;
  TimeOfDay? _reminderTime;
  String _reminderOption = '1';
  bool _repeatReminder = false;

  // Opposing party.
  final _opposingPartyController = TextEditingController();
  final _opposingLawyerController = TextEditingController();

  // Financial.
  final _professionalFeeController = TextEditingController();
  final _paidAmountController = TextEditingController();
  final _dueAmountController = TextEditingController();
  PaymentStatus _paymentStatus = PaymentStatus.unpaid;

  // Notes.
  final _notesController = TextEditingController();

  // Documents.
  final List<CaseDocument> _documents = [];

  // Section collapse state (optional sections expandable).
  bool _courtOpen = false;
  bool _opposingOpen = false;
  bool _financialOpen = false;
  bool _documentsOpen = false;
  bool _progressOpen = false;

  bool _isSubmitting = false;
  bool _isLoading = false;

  bool get _isEdit => widget.caseId != null;

  static const _reminderOptions = [
    ('1', '1 day before'),
    ('2', '2 days before'),
    ('3', '3 days before'),
    ('7', '7 days before'),
    ('custom', 'Custom'),
  ];

  @override
  void initState() {
    super.initState();
    if (_isEdit) _loadCase();
  }

  Future<void> _loadCase() async {
    setState(() => _isLoading = true);
    try {
      final legalCase = await ref
          .read(caseRepositoryProvider)
          .getCase(widget.caseId!);
      _titleController.text = legalCase.title;
      _caseNumberController.text = legalCase.caseNumber ?? '';
      _caseTypeController.text = legalCase.caseType ?? '';
      _status = legalCase.status;

      _clientNameController.text = legalCase.clientName;
      _clientPhoneController.text = legalCase.clientPhone ?? '';
      _clientEmailController.text = legalCase.clientEmail ?? '';
      _clientAddressController.text = legalCase.clientAddress ?? '';

      _courtNameController.text = legalCase.courtName ?? '';
      _judgeNameController.text = legalCase.judgeName ?? '';
      _benchController.text = legalCase.bench ?? '';

      _filingDate = legalCase.filingDate;
      _nextHearingDate = legalCase.nextHearingDate;
      _judgmentDate = legalCase.judgmentDate;
      _reminderDate = legalCase.reminderDate;
      _reminderTime = legalCase.reminderTime != null
          ? _parseTime(legalCase.reminderTime!)
          : null;
      _reminderOption = legalCase.reminderOption ?? '1';
      _repeatReminder = legalCase.repeatReminder;

      _opposingPartyController.text = legalCase.opposingParty ?? '';
      _opposingLawyerController.text = legalCase.opposingLawyer ?? '';

      _professionalFeeController.text = _fmtMoney(legalCase.professionalFee);
      _paidAmountController.text = _fmtMoney(legalCase.paidAmount);
      _dueAmountController.text = _fmtMoney(legalCase.dueAmount);
      _paymentStatus = legalCase.paymentStatus;

      _notesController.text = legalCase.notes ?? '';
      _documents
        ..clear()
        ..addAll(legalCase.documents);
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  static TimeOfDay? _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  static String _fmtMoney(double? v) {
    if (v == null) return '';
    return v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _caseNumberController.dispose();
    _caseTypeController.dispose();
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _clientEmailController.dispose();
    _clientAddressController.dispose();
    _courtNameController.dispose();
    _judgeNameController.dispose();
    _benchController.dispose();
    _opposingPartyController.dispose();
    _opposingLawyerController.dispose();
    _professionalFeeController.dispose();
    _paidAmountController.dispose();
    _dueAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _autoCalcDue() {
    final fee = double.tryParse(_professionalFeeController.text.trim());
    final paid = double.tryParse(_paidAmountController.text.trim());
    if (fee != null && paid != null) {
      final due = (fee - paid).clamp(0, double.infinity).toDouble();
      _dueAmountController.text = _fmtMoney(due);
    }
  }

  Future<void> _pickDate(ValueChanged<DateTime?> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  Future<void> _pickDocuments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'heic', 'doc', 'docx'],
    );
    if (result == null || result.files.isEmpty) return;

    final repo = ref.read(caseDocumentRepositoryProvider);
    for (final file in result.files) {
      final path = file.path;
      if (path == null) continue;
      try {
        final type = _docTypeFromName(file.name);
        if (_isEdit) {
          final doc = await repo.uploadDocument(
            caseId: widget.caseId!,
            filePath: path,
            fileName: file.name,
            type: type,
          );
          if (mounted) setState(() => _documents.add(doc));
        } else {
          // In create mode, keep a local record; uploads happen after case creation.
          final size = await File(path).length();
          if (mounted) {
            setState(
              () => _documents.add(
                CaseDocument(
                  id: -DateTime.now().millisecondsSinceEpoch,
                  fileName: file.name,
                  filePath: path,
                  mimeType: type.wire,
                  size: size,
                  type: type,
                ),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload ${file.name}.')),
          );
        }
      }
    }
  }

  static CaseDocumentType _docTypeFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return CaseDocumentType.pdf;
    if (lower.endsWith('.doc') || lower.endsWith('.docx'))
      return CaseDocumentType.word;
    return CaseDocumentType.image;
  }

  Future<void> _removeDocument(CaseDocument doc) async {
    if (doc.id > 0) {
      try {
        await ref
            .read(caseDocumentRepositoryProvider)
            .deleteDocument(widget.caseId!, doc.id);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete document.')),
          );
          return;
        }
      }
    }
    if (mounted) setState(() => _documents.remove(doc));
  }

  Future<void> _downloadDocument(CaseDocument doc) async {
    if (doc.id <= 0) return; // Not yet uploaded.
    try {
      final bytes = await ref
          .read(caseDocumentRepositoryProvider)
          .downloadDocument(widget.caseId!, doc.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded ${bytes.length} bytes.')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download document.')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    if (_isSubmitting) return; // Prevent duplicate submissions.

    _autoCalcDue();

    final input = CaseInput(
      title: _titleController.text.trim(),
      caseNumber: _caseNumberController.text.trim().isEmpty
          ? null
          : _caseNumberController.text.trim(),
      clientName: _clientNameController.text.trim(),
      clientPhone: _clientPhoneController.text.trim().isEmpty
          ? null
          : _clientPhoneController.text.trim(),
      clientEmail: _clientEmailController.text.trim().isEmpty
          ? null
          : _clientEmailController.text.trim(),
      clientAddress: _clientAddressController.text.trim().isEmpty
          ? null
          : _clientAddressController.text.trim(),
      courtName: _courtNameController.text.trim().isEmpty
          ? null
          : _courtNameController.text.trim(),
      judgeName: _judgeNameController.text.trim().isEmpty
          ? null
          : _judgeNameController.text.trim(),
      bench: _benchController.text.trim().isEmpty
          ? null
          : _benchController.text.trim(),
      opposingParty: _opposingPartyController.text.trim().isEmpty
          ? null
          : _opposingPartyController.text.trim(),
      opposingLawyer: _opposingLawyerController.text.trim().isEmpty
          ? null
          : _opposingLawyerController.text.trim(),
      caseType: _caseTypeController.text.trim().isEmpty
          ? null
          : _caseTypeController.text.trim(),
      status: _status,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      filingDate: _filingDate,
      nextHearingDate: _nextHearingDate,
      judgmentDate: _judgmentDate,
      reminderDate: _reminderDate,
      reminderTime: _reminderTime != null
          ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
          : null,
      reminderOption: _reminderOption,
      repeatReminder: _repeatReminder,
      professionalFee: _parseMoney(_professionalFeeController.text),
      paidAmount: _parseMoney(_paidAmountController.text),
      dueAmount: _parseMoney(_dueAmountController.text),
      paymentStatus: _paymentStatus,
    );

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(caseRepositoryProvider);
      int? createdId;
      if (_isEdit) {
        await repo.updateCase(widget.caseId!, input);
      } else {
        final created = await repo.createCase(input);
        createdId = created.id;
      }
      if (!mounted) return;

      // Upload any pending (create-mode) documents now that the case exists.
      if (createdId != null) {
        final docRepo = ref.read(caseDocumentRepositoryProvider);
        for (final doc in _documents.where((d) => d.id < 0)) {
          try {
            await docRepo.uploadDocument(
              caseId: createdId,
              filePath: doc.filePath,
              fileName: doc.fileName,
              type: doc.type,
            );
          } catch (_) {
            // Best-effort; individual upload failures are non-fatal.
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit
                ? 'Case updated successfully.'
                : 'Case created successfully.',
          ),
        ),
      );
      Navigator.of(context).pop(true);
      ref.read(caseListControllerProvider.notifier).refresh();
    } on CaseLimitReachedException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      final shouldUpgrade = await Navigator.of(
        context,
      ).pushNamed<bool>(AppRoutes.upgrade, arguments: {'limit': e.limit});
      if (shouldUpgrade == true && mounted) Navigator.of(context).pop(false);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    }
  }

  static double? _parseMoney(String v) {
    final t = v.trim();
    if (t.isEmpty) return null;
    final d = double.tryParse(t);
    return d == null ? null : d;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Case' : 'Add Case')),
      body: _isLoading
          ? const LoadingState()
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 40),
                  children: [
                    const SizedBox(height: 8),
                    _Section(
                      icon: Icons.badge_outlined,
                      title: 'Basic Information',
                      subtitle: 'Required',
                      child: Column(
                        children: [
                          _field(
                            _titleController,
                            'Case title *',
                            'e.g. Rahim vs. Karim – Title Dispute',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Title is required'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          _field(
                            _caseNumberController,
                            'Case number *',
                            'e.g. Civil Suit 145/2023',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Case number is required'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          _field(
                            _caseTypeController,
                            'Case type *',
                            'e.g. Civil, Criminal, Family, Property',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Case type is required'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _statusSelector(),
                        ],
                      ),
                    ),
                    _Section(
                      icon: Icons.person_outline,
                      title: 'Client Information',
                      subtitle: 'Required',
                      child: Column(
                        children: [
                          _field(
                            _clientNameController,
                            'Client name *',
                            'e.g. Abdul Rahim',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Client name is required'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          _field(
                            _clientPhoneController,
                            'Client phone *',
                            '01XXXXXXXXX',
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Client phone is required';
                              if (!RegExp(
                                r'^01[3-9][0-9]{8}$',
                              ).hasMatch(v.trim())) {
                                return 'Enter a valid Bangladeshi number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _field(
                            _clientEmailController,
                            'Client email (optional)',
                            'client@example.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return null;
                              if (!RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              ).hasMatch(v.trim())) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _field(
                            _clientAddressController,
                            'Client address (optional)',
                            'House, Road, Thana',
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    _ExpandableSection(
                      icon: Icons.location_on_outlined,
                      title: 'Court Information',
                      subtitle: 'Optional',
                      open: _courtOpen,
                      onToggle: () => setState(() => _courtOpen = !_courtOpen),
                      child: Column(
                        children: [
                          _field(
                            _courtNameController,
                            'Court (optional)',
                            'e.g. Dhaka District Court',
                          ),
                          const SizedBox(height: 14),
                          _field(
                            _judgeNameController,
                            'Judge name (optional)',
                            'e.g. Md. Kamal Hossain',
                          ),
                          const SizedBox(height: 14),
                          _field(
                            _benchController,
                            'Bench (optional)',
                            'e.g. Civil Bench 1',
                          ),
                        ],
                      ),
                    ),
                    _Section(
                      icon: Icons.event_outlined,
                      title: 'Important Dates',
                      subtitle: 'Required',
                      child: Column(
                        children: [
                          _dateField(
                            'Case filing date',
                            _filingDate,
                            (d) => setState(() => _filingDate = d),
                          ),
                          const SizedBox(height: 12),
                          _dateField(
                            'Next hearing date',
                            _nextHearingDate,
                            (d) => setState(() => _nextHearingDate = d),
                          ),
                          const SizedBox(height: 12),
                          _dateField(
                            'Judgment date (optional)',
                            _judgmentDate,
                            (d) => setState(() => _judgmentDate = d),
                          ),
                          const Divider(height: 28),
                          _dateField(
                            'Reminder date',
                            _reminderDate,
                            (d) => setState(() => _reminderDate = d),
                          ),
                          const SizedBox(height: 12),
                          _timeField(),
                          const SizedBox(height: 12),
                          _reminderOptionSelector(),
                          const SizedBox(height: 4),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Repeat reminder',
                              style: TextStyle(fontSize: 14),
                            ),
                            subtitle: const Text(
                              'Remind on every occurrence',
                              style: TextStyle(fontSize: 12),
                            ),
                            value: _repeatReminder,
                            activeTrackColor: AppColors.primary,
                            onChanged: (v) =>
                                setState(() => _repeatReminder = v),
                          ),
                          if (_reminderDate == null)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                'No reminder will be scheduled without a reminder date.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    _ExpandableSection(
                      icon: Icons.gavel,
                      title: 'Opposing Party',
                      subtitle: 'Optional',
                      open: _opposingOpen,
                      onToggle: () =>
                          setState(() => _opposingOpen = !_opposingOpen),
                      child: Column(
                        children: [
                          _field(
                            _opposingPartyController,
                            'Opposing party',
                            'e.g. Karim Mia',
                          ),
                          const SizedBox(height: 14),
                          _field(
                            _opposingLawyerController,
                            'Opposing lawyer',
                            'e.g. Advocate Rahim Mia',
                          ),
                        ],
                      ),
                    ),
                    _ExpandableSection(
                      icon: Icons.payments_outlined,
                      title: 'Financial Information',
                      subtitle: 'Optional',
                      open: _financialOpen,
                      onToggle: () =>
                          setState(() => _financialOpen = !_financialOpen),
                      child: Column(
                        children: [
                          _field(
                            _professionalFeeController,
                            'Professional fee',
                            'e.g. 25000',
                            keyboardType: TextInputType.number,
                            onChanged: (_) => _autoCalcDue(),
                          ),
                          const SizedBox(height: 14),
                          _field(
                            _paidAmountController,
                            'Paid amount',
                            'e.g. 10000',
                            keyboardType: TextInputType.number,
                            onChanged: (_) => _autoCalcDue(),
                          ),
                          const SizedBox(height: 14),
                          _field(
                            _dueAmountController,
                            'Due amount (auto-calculated)',
                            '0',
                            keyboardType: TextInputType.number,
                            readOnly: true,
                          ),
                          const SizedBox(height: 16),
                          _paymentStatusSelector(),
                        ],
                      ),
                    ),
                    _ExpandableSection(
                      icon: Icons.attach_file,
                      title: 'Documents',
                      subtitle: 'PDF · Images · Word',
                      open: _documentsOpen,
                      onToggle: () =>
                          setState(() => _documentsOpen = !_documentsOpen),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _isSubmitting ? null : _pickDocuments,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Attach documents'),
                          ),
                          const SizedBox(height: 12),
                          if (_documents.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'No documents attached.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          else
                            ..._documents.map(
                              (d) => _DocumentTile(
                                doc: d,
                                onDownload: () => _downloadDocument(d),
                                onRemove: () => _removeDocument(d),
                              ),
                            ),
                        ],
                      ),
                    ),
                    _ExpandableSection(
                      icon: Icons.timeline,
                      title: 'Case Progress',
                      subtitle: 'Timeline placeholder',
                      open: _progressOpen,
                      onToggle: () =>
                          setState(() => _progressOpen = !_progressOpen),
                      child: const _ProgressPlaceholder(),
                    ),
                    const SizedBox(height: 8),
                    _field(
                      _notesController,
                      'Notes',
                      'Anything relevant about this case…',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
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
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String hint, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
      ),
      validator: validator,
    );
  }

  Widget _dateField(
    String label,
    DateTime? value,
    ValueChanged<DateTime?> onPicked,
  ) {
    return InkWell(
      onTap: () => _pickDate(onPicked),
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(
          value == null
              ? 'Select date'
              : DateFormat('d MMM yyyy').format(value),
          style: TextStyle(
            fontSize: 14,
            color: value == null
                ? AppColors.textSecondary
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _timeField() {
    return InkWell(
      onTap: _pickTime,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Reminder time',
          suffixIcon: Icon(Icons.access_time, size: 18),
        ),
        child: Text(
          _reminderTime == null
              ? 'Select time'
              : _reminderTime!.format(context),
          style: TextStyle(
            fontSize: 14,
            color: _reminderTime == null
                ? AppColors.textSecondary
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _statusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status *',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
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
      ],
    );
  }

  Widget _reminderOptionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reminder option',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _reminderOptions.map((opt) {
            final selected = _reminderOption == opt.$1;
            return ChoiceChip(
              label: Text(opt.$2),
              selected: selected,
              onSelected: (_) => setState(() => _reminderOption = opt.$1),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _paymentStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment status',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<PaymentStatus>(
          segments: const [
            ButtonSegment(value: PaymentStatus.paid, label: Text('Paid')),
            ButtonSegment(value: PaymentStatus.partial, label: Text('Partial')),
            ButtonSegment(value: PaymentStatus.unpaid, label: Text('Unpaid')),
          ],
          selected: {_paymentStatus},
          onSelectionChanged: (s) => setState(() => _paymentStatus = s.first),
        ),
      ],
    );
  }
}

/// A labeled grouping of form fields (always expanded).
class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  const _Section({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _Badge(text: subtitle),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

/// Collapsible section used for optional case details.
class _ExpandableSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool open;
  final VoidCallback onToggle;
  final Widget child;
  const _ExpandableSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.open,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          children: [
            InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(icon, size: 20, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      open ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            if (open) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 16),
                child: child,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A single document row with preview, download and remove actions.
class _DocumentTile extends StatelessWidget {
  final CaseDocument doc;
  final VoidCallback onDownload;
  final VoidCallback onRemove;
  const _DocumentTile({
    required this.doc,
    required this.onDownload,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final icon = switch (doc.type) {
      CaseDocumentType.pdf => Icons.picture_as_pdf,
      CaseDocumentType.word => Icons.description_outlined,
      CaseDocumentType.image => Icons.image_outlined,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (doc.sizeLabel.isNotEmpty)
                  Text(
                    doc.sizeLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Download',
            icon: const Icon(Icons.download_outlined, size: 20),
            onPressed: onDownload,
          ),
          IconButton(
            tooltip: 'Remove',
            icon: const Icon(
              Icons.delete_outline,
              size: 20,
              color: AppColors.danger,
            ),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _ProgressPlaceholder extends StatelessWidget {
  const _ProgressPlaceholder();

  @override
  Widget build(BuildContext context) {
    const stages = [
      'Case Created',
      'Documents Uploaded',
      'First Hearing',
      'Next Hearing',
      'Judgment',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Timeline placeholders — timestamps will be recorded as the case advances.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        ...stages.map(
          (s) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.circle_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Text(
                  s,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
