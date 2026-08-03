import 'deadline.dart';
import 'case_document.dart';

/// Status of a legal case.
enum CaseStatus { active, closed, onHold }

extension CaseStatusX on CaseStatus {
  String get wire => switch (this) {
        CaseStatus.active => 'active',
        CaseStatus.closed => 'closed',
        CaseStatus.onHold => 'on_hold',
      };

  String get label => switch (this) {
        CaseStatus.active => 'Active',
        CaseStatus.closed => 'Closed',
        CaseStatus.onHold => 'On Hold',
      };

  static CaseStatus fromWire(String? value) => switch (value) {
        'closed' => CaseStatus.closed,
        'on_hold' => CaseStatus.onHold,
        _ => CaseStatus.active,
      };
}

/// Payment status of a case.
enum PaymentStatus { paid, partial, unpaid }

extension PaymentStatusX on PaymentStatus {
  String get wire => switch (this) {
        PaymentStatus.paid => 'paid',
        PaymentStatus.partial => 'partial',
        PaymentStatus.unpaid => 'unpaid',
      };

  String get label => switch (this) {
        PaymentStatus.paid => 'Paid',
        PaymentStatus.partial => 'Partial',
        PaymentStatus.unpaid => 'Unpaid',
      };

  static PaymentStatus fromWire(String? value) => switch (value) {
        'paid' => PaymentStatus.paid,
        'partial' => PaymentStatus.partial,
        _ => PaymentStatus.unpaid,
      };
}

/// A legal case owned by a lawyer (user).
class LegalCase {
  final int id;
  final int userId;
  final String title;
  final String? caseNumber;
  final String clientName;
  final String? clientPhone;
  final String? clientEmail;
  final String? clientAddress;
  final String? courtName;
  final String? judgeName;
  final String? bench;
  final String? opposingParty;
  final String? opposingLawyer;
  final String? caseType;
  final CaseStatus status;
  final String? notes;

  // Important dates & reminders.
  final DateTime? filingDate;
  final DateTime? nextHearingDate;
  final DateTime? judgmentDate;
  final DateTime? reminderDate;
  final String? reminderTime;
  final String? reminderOption;
  final bool repeatReminder;

  // Financial information.
  final double? professionalFee;
  final double? paidAmount;
  final double? dueAmount;
  final PaymentStatus paymentStatus;

  // Case progress + AI placeholder.
  final List<Map<String, dynamic>> caseProgress;
  final List<dynamic> aiFlags;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Deadline> deadlines;
  final List<CaseDocument> documents;

  const LegalCase({
    required this.id,
    required this.userId,
    required this.title,
    this.caseNumber,
    required this.clientName,
    this.clientPhone,
    this.clientEmail,
    this.clientAddress,
    this.courtName,
    this.judgeName,
    this.bench,
    this.opposingParty,
    this.opposingLawyer,
    this.caseType,
    this.status = CaseStatus.active,
    this.notes,
    this.filingDate,
    this.nextHearingDate,
    this.judgmentDate,
    this.reminderDate,
    this.reminderTime,
    this.reminderOption,
    this.repeatReminder = false,
    this.professionalFee,
    this.paidAmount,
    this.dueAmount,
    this.paymentStatus = PaymentStatus.unpaid,
    this.caseProgress = const [],
    this.aiFlags = const [],
    this.createdAt,
    this.updatedAt,
    this.deadlines = const [],
    this.documents = const [],
  });

  factory LegalCase.fromJson(Map<String, dynamic> json) {
    return LegalCase(
      id: json['id'] as int,
      userId: json['user_id'] as int? ?? 0,
      title: json['title'] as String,
      caseNumber: json['case_number'] as String?,
      clientName: json['client_name'] as String? ?? '',
      clientPhone: json['client_phone'] as String?,
      clientEmail: json['client_email'] as String?,
      clientAddress: json['client_address'] as String?,
      courtName: json['court_name'] as String?,
      judgeName: json['judge_name'] as String?,
      bench: json['bench'] as String?,
      opposingParty: json['opposing_party'] as String?,
      opposingLawyer: json['opposing_lawyer'] as String?,
      caseType: json['case_type'] as String?,
      status: CaseStatusX.fromWire(json['status'] as String?),
      notes: json['notes'] as String?,
      filingDate: DateTime.tryParse(json['filing_date'] as String? ?? ''),
      nextHearingDate: DateTime.tryParse(json['next_hearing_date'] as String? ?? ''),
      judgmentDate: DateTime.tryParse(json['judgment_date'] as String? ?? ''),
      reminderDate: DateTime.tryParse(json['reminder_date'] as String? ?? ''),
      reminderTime: json['reminder_time'] as String?,
      reminderOption: json['reminder_option'] as String?,
      repeatReminder: json['repeat_reminder'] as bool? ?? false,
      professionalFee: _toDouble(json['professional_fee']),
      paidAmount: _toDouble(json['paid_amount']),
      dueAmount: _toDouble(json['due_amount']),
      paymentStatus: PaymentStatusX.fromWire(json['payment_status'] as String?),
      caseProgress: _toMapList(json['case_progress']),
      aiFlags: (json['ai_flags'] as List<dynamic>? ?? const []),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
      deadlines: (json['deadlines'] as List<dynamic>? ?? const [])
          .map((e) => Deadline.fromJson(e as Map<String, dynamic>))
          .toList(),
      documents: (json['documents'] as List<dynamic>? ?? const [])
          .map((e) => CaseDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    return (v as num).toDouble();
  }

  static List<Map<String, dynamic>> _toMapList(dynamic v) {
    if (v == null) return const [];
    return (v as List<dynamic>).whereType<Map<String, dynamic>>().toList();
  }
}

/// Input used when creating or updating a case.
class CaseInput {
  final String title;
  final String? caseNumber;
  final String clientName;
  final String? clientPhone;
  final String? clientEmail;
  final String? clientAddress;
  final String? courtName;
  final String? judgeName;
  final String? bench;
  final String? opposingParty;
  final String? opposingLawyer;
  final String? caseType;
  final CaseStatus status;
  final String? notes;

  final DateTime? filingDate;
  final DateTime? nextHearingDate;
  final DateTime? judgmentDate;
  final DateTime? reminderDate;
  final String? reminderTime;
  final String? reminderOption;
  final bool repeatReminder;

  final double? professionalFee;
  final double? paidAmount;
  final double? dueAmount;
  final PaymentStatus paymentStatus;

  final List<Map<String, dynamic>> caseProgress;
  final List<dynamic> aiFlags;

  const CaseInput({
    required this.title,
    this.caseNumber,
    required this.clientName,
    this.clientPhone,
    this.clientEmail,
    this.clientAddress,
    this.courtName,
    this.judgeName,
    this.bench,
    this.opposingParty,
    this.opposingLawyer,
    this.caseType,
    this.status = CaseStatus.active,
    this.notes,
    this.filingDate,
    this.nextHearingDate,
    this.judgmentDate,
    this.reminderDate,
    this.reminderTime,
    this.reminderOption,
    this.repeatReminder = false,
    this.professionalFee,
    this.paidAmount,
    this.dueAmount,
    this.paymentStatus = PaymentStatus.unpaid,
    this.caseProgress = const [],
    this.aiFlags = const [],
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'case_number': caseNumber,
        'client_name': clientName,
        'client_phone': clientPhone,
        'client_email': clientEmail,
        'client_address': clientAddress,
        'court_name': courtName,
        'judge_name': judgeName,
        'bench': bench,
        'opposing_party': opposingParty,
        'opposing_lawyer': opposingLawyer,
        'case_type': caseType,
        'status': status.wire,
        'notes': notes,
        'filing_date': _dateOnly(filingDate),
        'next_hearing_date': _dateOnly(nextHearingDate),
        'judgment_date': _dateOnly(judgmentDate),
        'reminder_date': _dateOnly(reminderDate),
        'reminder_time': reminderTime,
        'reminder_option': reminderOption,
        'repeat_reminder': repeatReminder,
        'professional_fee': professionalFee,
        'paid_amount': paidAmount,
        'due_amount': dueAmount,
        'payment_status': paymentStatus.wire,
        'case_progress': caseProgress,
        'ai_flags': aiFlags,
      };

  static String? _dateOnly(DateTime? dt) {
    if (dt == null) return null;
    return '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
  }
}

/// Paginated result wrapper for case lists.
class CasePage {
  final List<LegalCase> cases;
  final int currentPage;
  final int lastPage;
  final int total;

  const CasePage({
    required this.cases,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;

  factory CasePage.fromJson(Map<String, dynamic> json) {
    return CasePage(
      cases: (json['data'] as List<dynamic>? ?? const [])
          .map((e) => LegalCase.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      total: json['total'] as int? ?? 0,
    );
  }
}
