/// Subscription tier of a user.
enum SubscriptionTier { free, paid }

/// Role of a user.
enum UserRole { lawyer, admin }

extension UserRoleX on UserRole {
  String get wire => switch (this) {
        UserRole.lawyer => 'lawyer',
        UserRole.admin => 'admin',
      };

  static UserRole fromWire(String value) => switch (value) {
        'admin' => UserRole.admin,
        _ => UserRole.lawyer,
      };
}

extension SubscriptionTierX on SubscriptionTier {
  String get wire => switch (this) {
        SubscriptionTier.free => 'free',
        SubscriptionTier.paid => 'paid',
      };

  static SubscriptionTier fromWire(String value) => switch (value) {
        'paid' => SubscriptionTier.paid,
        _ => SubscriptionTier.free,
      };
}

/// Subscription summary returned by the API inside the user object.
class SubscriptionSummary {
  final SubscriptionTier tier;
  final bool isPaid;
  final int? activeCaseLimit;
  final int activeCasesCount;
  final int remainingActiveSlots;

  const SubscriptionSummary({
    required this.tier,
    required this.isPaid,
    this.activeCaseLimit,
    required this.activeCasesCount,
    required this.remainingActiveSlots,
  });

  factory SubscriptionSummary.fromJson(Map<String, dynamic> json) {
    return SubscriptionSummary(
      tier: SubscriptionTierX.fromWire(json['tier'] as String? ?? 'free'),
      isPaid: json['is_paid'] as bool? ?? false,
      activeCaseLimit: json['active_case_limit'] as int?,
      activeCasesCount: json['active_cases_count'] as int? ?? 0,
      remainingActiveSlots: json['remaining_active_slots'] as int? ?? 0,
    );
  }
}

/// A user of the Adalot Sathi app (lawyer or admin).
class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final SubscriptionTier subscriptionTier;
  final String? subscriptionExpiresAt;
  final SubscriptionSummary subscription;
  final String? verificationStatus;
  final String? rejectionReason;
  final bool isSuspended;
  final String? suspendedUntil;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Personal information.
  final String? barCouncilNumber;
  final String? chamberName;
  final String? address;
  final String? district;
  final String? profilePhoto;

  // Professional information.
  final int? yearsOfExperience;
  final List<String> practiceAreas;
  final String? preferredCourt;

  // Preferences.
  final String appLanguage;
  final Map<String, dynamic> notificationSettings;
  final Map<String, dynamic> reminderSettings;
  final bool darkMode;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role = UserRole.lawyer,
    this.subscriptionTier = SubscriptionTier.free,
    this.subscriptionExpiresAt,
    required this.subscription,
    this.verificationStatus,
    this.rejectionReason,
    this.isSuspended = false,
    this.suspendedUntil,
    this.createdAt,
    this.updatedAt,
    this.barCouncilNumber,
    this.chamberName,
    this.address,
    this.district,
    this.profilePhoto,
    this.yearsOfExperience,
    this.practiceAreas = const [],
    this.preferredCourt,
    this.appLanguage = 'bn',
    this.notificationSettings = const {},
    this.reminderSettings = const {},
    this.darkMode = false,
  });

  bool get isPaid => subscriptionTier == SubscriptionTier.paid;

  bool get isAdmin => role == UserRole.admin;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: UserRoleX.fromWire(json['role'] as String? ?? 'lawyer'),
      subscriptionTier:
          SubscriptionTierX.fromWire(json['subscription_tier'] as String? ?? 'free'),
      subscriptionExpiresAt: json['subscription_expires_at'] as String?,
      subscription: SubscriptionSummary.fromJson(
        (json['subscription'] as Map<String, dynamic>?) ?? const {},
      ),
      verificationStatus: json['verification_status'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      isSuspended: json['is_suspended'] as bool? ?? false,
      suspendedUntil: json['suspended_until'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
      barCouncilNumber: json['bar_council_number'] as String?,
      chamberName: json['chamber_name'] as String?,
      address: json['address'] as String?,
      district: json['district'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      yearsOfExperience: json['years_of_experience'] as int?,
      practiceAreas: (json['practice_areas'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      preferredCourt: json['preferred_court'] as String?,
      appLanguage: json['app_language'] as String? ?? 'bn',
      notificationSettings:
          (json['notification_settings'] as Map<String, dynamic>?) ?? const {},
      reminderSettings:
          (json['reminder_settings'] as Map<String, dynamic>?) ?? const {},
      darkMode: json['dark_mode'] as bool? ?? false,
    );
  }
}
