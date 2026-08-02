import 'deadline.dart';

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

/// A legal case owned by a lawyer (user).
class LegalCase {
  final int id;
  final int userId;
  final String title;
  final String? caseNumber;
  final String clientName;
  final String? clientPhone;
  final String? courtName;
  final String? opposingParty;
  final String? caseType;
  final CaseStatus status;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Deadline> deadlines;

  const LegalCase({
    required this.id,
    required this.userId,
    required this.title,
    this.caseNumber,
    required this.clientName,
    this.clientPhone,
    this.courtName,
    this.opposingParty,
    this.caseType,
    this.status = CaseStatus.active,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.deadlines = const [],
  });

  factory LegalCase.fromJson(Map<String, dynamic> json) {
    return LegalCase(
      id: json['id'] as int,
      userId: json['user_id'] as int? ?? 0,
      title: json['title'] as String,
      caseNumber: json['case_number'] as String?,
      clientName: json['client_name'] as String? ?? '',
      clientPhone: json['client_phone'] as String?,
      courtName: json['court_name'] as String?,
      opposingParty: json['opposing_party'] as String?,
      caseType: json['case_type'] as String?,
      status: CaseStatusX.fromWire(json['status'] as String?),
      notes: json['notes'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
      deadlines: (json['deadlines'] as List<dynamic>? ?? const [])
          .map((e) => Deadline.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Input used when creating or updating a case.
class CaseInput {
  final String title;
  final String? caseNumber;
  final String clientName;
  final String? clientPhone;
  final String? courtName;
  final String? opposingParty;
  final String? caseType;
  final CaseStatus status;
  final String? notes;

  const CaseInput({
    required this.title,
    this.caseNumber,
    required this.clientName,
    this.clientPhone,
    this.courtName,
    this.opposingParty,
    this.caseType,
    this.status = CaseStatus.active,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'case_number': caseNumber,
        'client_name': clientName,
        'client_phone': clientPhone,
        'court_name': courtName,
        'opposing_party': opposingParty,
        'case_type': caseType,
        'status': status.wire,
        'notes': notes,
      };
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


