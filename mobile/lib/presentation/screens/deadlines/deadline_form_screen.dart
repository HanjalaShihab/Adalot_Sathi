import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../application/cases/case_detail_controller.dart';
import '../../../application/deadlines/deadline_form_controller.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/deadline.dart';
import '../../../data/providers/repository_providers.dart';
import '../../widgets/state_widgets.dart';

/// Add/Edit deadline form.
class DeadlineFormScreen extends ConsumerStatefulWidget {
  final int caseId;
  final int? deadlineId;
  const DeadlineFormScreen({super.key, required this.caseId, this.deadlineId});

  @override
  ConsumerState<DeadlineFormScreen> createState() => _DeadlineFormScreenState();
}

class _DeadlineFormScreenState extends ConsumerState<DeadlineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DeadlineEventType _eventType = DeadlineEventType.hearing;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay? _dueTime;
  List<int> _reminderDays = const [7, 3, 1];
  bool _isLoading = false;
  bool _isSubmitting = false;

  bool get _isEdit => widget.deadlineId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) _loadDeadline();
  }

  Future<void> _loadDeadline() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(deadlineRepositoryProvider);
      final d = await repo.getDeadline(widget.caseId, widget.deadlineId!);
      _titleController.text = d.title;
      _descriptionController.text = d.description ?? '';
      _eventType = d.eventType;
      _dueDate = d.dueDate;
      if (d.dueTime != null) {
        final parts = d.dueTime!.split(':');
        if (parts.length >= 2) {
          _dueTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
      }
      _reminderDays = d.reminderDaysBefore.isEmpty ? const [7, 3, 1] : d.reminderDaysBefore;
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
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) setState(() => _dueTime = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final input = DeadlineInput(
      title: _titleController.text.trim(),
      eventType: _eventType,
      dueDate: _dueDate,
      dueTime: _dueTime == null
          ? null
          : '${_dueTime!.hour.toString().padLeft(2, '0')}:'
              '${_dueTime!.minute.toString().padLeft(2, '0')}',
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      reminderDaysBefore: _reminderDays,
    );

    setState(() => _isSubmitting = true);
    try {
      final controller = ref.read(deadlineFormControllerProvider.notifier);
      final ok = _isEdit
          ? await controller.update(widget.caseId, widget.deadlineId!, input)
          : await controller.create(widget.caseId, input);
      if (!mounted) return;
      if (ok) {
        ref.read(caseDetailControllerProvider(widget.caseId).notifier).refresh();
        Navigator.of(context).pop(true);
      } else {
        final error = ref.read(deadlineFormControllerProvider).error;
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Failed to save deadline.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')),
      );
    }
  }

  Future<void> _deleteDeadline() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete deadline?'),
        content: const Text('This will remove the deadline permanently.'),
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
    if (confirmed == true && mounted) {
      final ok = await ref
          .read(deadlineFormControllerProvider.notifier)
          .delete(widget.caseId, widget.deadlineId!);
      if (ok && mounted) {
        ref.read(caseDetailControllerProvider(widget.caseId).notifier).refresh();
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Deadline' : 'Add Deadline'),
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: 'Delete deadline',
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteDeadline,
            ),
        ],
      ),
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
                          labelText: 'Title *',
                          hintText: 'e.g. Hearing – Second date',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Event type',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<DeadlineEventType>(
                        segments: const [
                          ButtonSegment(value: DeadlineEventType.hearing, label: Text('Hearing'), icon: Icon(Icons.gavel)),
                          ButtonSegment(value: DeadlineEventType.filing, label: Text('Filing'), icon: Icon(Icons.article_outlined)),
                          ButtonSegment(value: DeadlineEventType.appeal, label: Text('Appeal'), icon: Icon(Icons.account_balance)),
                          ButtonSegment(value: DeadlineEventType.other, label: Text('Other'), icon: Icon(Icons.event_note)),
                        ],
                        selected: {_eventType},
                        onSelectionChanged: (s) => setState(() => _eventType = s.first),
                      ),
                      const SizedBox(height: 18),
                      // Due date + time.
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _pickDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(labelText: 'Due date *'),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
                                    const SizedBox(width: 8),
                                    Text(DateFormat('EEE, d MMM yyyy').format(_dueDate)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: _pickTime,
                              child: InputDecorator(
                                decoration: const InputDecoration(labelText: 'Due time'),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 18, color: AppColors.textSecondary),
                                    const SizedBox(width: 8),
                                    Text(_dueTime == null
                                        ? 'Not set'
                                        : _dueTime!.format(context)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'e.g. Submit written statement',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Remind me',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      _buildReminderDays(),
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
                            : Text(_isEdit ? 'Save Changes' : 'Add Deadline'),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildReminderDays() {
    const options = [1, 3, 7];
    const labels = {1: '1 day before', 3: '3 days before', 7: '7 days before'};
    final selectedSet = _reminderDays.toSet();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((day) {
        final selected = selectedSet.contains(day);
        return FilterChip(
          label: Text(labels[day]!),
          selected: selected,
          onSelected: (on) {
            setState(() {
              if (on) {
                _reminderDays = {...selectedSet, day}.toList()..sort((a, b) => b.compareTo(a));
              } else {
                _reminderDays = selectedSet.difference({day}).toList()..sort((a, b) => b.compareTo(a));
              }
            });
          },
        );
      }).toList(),
    );
  }
}


