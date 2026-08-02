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
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role = UserRole.lawyer,
    this.subscriptionTier = SubscriptionTier.free,
    this.subscriptionExpiresAt,
    required this.subscription,
    this.createdAt,
    this.updatedAt,
  });

  bool get isPaid => subscriptionTier == SubscriptionTier.paid;

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
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
    );
  }
}

