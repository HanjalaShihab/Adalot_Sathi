/// Event type of a legal deadline.
enum DeadlineEventType { hearing, filing, appeal, other }

extension DeadlineEventTypeX on DeadlineEventType {
  String get wire => switch (this) {
        DeadlineEventType.hearing => 'hearing',
        DeadlineEventType.filing => 'filing',
        DeadlineEventType.appeal => 'appeal',
        DeadlineEventType.other => 'other',
      };

  String get label => switch (this) {
        DeadlineEventType.hearing => 'Hearing',
        DeadlineEventType.filing => 'Filing',
        DeadlineEventType.appeal => 'Appeal',
        DeadlineEventType.other => 'Other',
      };

  static DeadlineEventType fromWire(String? value) => switch (value) {
        'hearing' => DeadlineEventType.hearing,
        'filing' => DeadlineEventType.filing,
        'appeal' => DeadlineEventType.appeal,
        _ => DeadlineEventType.other,
      };
}

/// Status of a deadline.
enum DeadlineStatus { pending, completed, missed }

extension DeadlineStatusX on DeadlineStatus {
  String get wire => switch (this) {
        DeadlineStatus.pending => 'pending',
        DeadlineStatus.completed => 'completed',
        DeadlineStatus.missed => 'missed',
      };

  String get label => switch (this) {
        DeadlineStatus.pending => 'Pending',
        DeadlineStatus.completed => 'Completed',
        DeadlineStatus.missed => 'Missed',
      };

  static DeadlineStatus fromWire(String? value) => switch (value) {
        'completed' => DeadlineStatus.completed,
        'missed' => DeadlineStatus.missed,
        _ => DeadlineStatus.pending,
      };
}

/// A legal deadline attached to a case.
class Deadline {
  final int id;
  final int caseId;
  final String title;
  final DeadlineEventType eventType;
  final DateTime dueDate;
  final String? dueTime;
  final String? description;
  final DeadlineStatus status;
  final List<int> reminderDaysBefore;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Populated by the upcoming-deadlines endpoint (case summary).
  final Map<String, dynamic>? caseSummary;

  const Deadline({
    required this.id,
    required this.caseId,
    required this.title,
    required this.eventType,
    required this.dueDate,
    this.dueTime,
    this.description,
    this.status = DeadlineStatus.pending,
    this.reminderDaysBefore = const [7, 3, 1],
    this.createdAt,
    this.updatedAt,
    this.caseSummary,
  });

  bool get isCompleted => status == DeadlineStatus.completed;

  factory Deadline.fromJson(Map<String, dynamic> json) {
    return Deadline(
      id: json['id'] as int,
      caseId: json['case_id'] as int,
      title: json['title'] as String,
      eventType: DeadlineEventTypeX.fromWire(json['event_type'] as String?),
      dueDate: DateTime.tryParse(json['due_date'] as String? ?? '') ?? DateTime.now(),
      dueTime: json['due_time'] as String?,
      description: json['description'] as String?,
      status: DeadlineStatusX.fromWire(json['status'] as String?),
      reminderDaysBefore: (json['reminder_days_before'] as List<dynamic>? ?? const [])
          .map((e) => e as int)
          .toList(),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
      caseSummary: json['case'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'event_type': eventType.wire,
        'due_date': _dateOnly(dueDate),
        'due_time': dueTime,
        'description': description,
        'status': status.wire,
        'reminder_days_before': reminderDaysBefore,
      };

  static String _dateOnly(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';
}

/// Input used when creating or updating a deadline.
class DeadlineInput {
  final String title;
  final DeadlineEventType eventType;
  final DateTime dueDate;
  final String? dueTime;
  final String? description;
  final DeadlineStatus? status;
  final List<int> reminderDaysBefore;

  const DeadlineInput({
    required this.title,
    required this.eventType,
    required this.dueDate,
    this.dueTime,
    this.description,
    this.status,
    this.reminderDaysBefore = const [7, 3, 1],
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'event_type': eventType.wire,
        'due_date': '${dueDate.year.toString().padLeft(4, '0')}-'
            '${dueDate.month.toString().padLeft(2, '0')}-'
            '${dueDate.day.toString().padLeft(2, '0')}',
        'due_time': dueTime,
        'description': description,
        if (status != null) 'status': status!.wire,
        'reminder_days_before': reminderDaysBefore,
      };
}

