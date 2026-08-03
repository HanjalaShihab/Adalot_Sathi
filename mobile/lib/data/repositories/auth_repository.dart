import '../models/user.dart';

/// Result of a successful auth call (login or register).
class AuthResult {
  final String token;
  final User user;

  const AuthResult({required this.token, required this.user});
}

/// Credentials for registration.
class RegisterInput {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;

  const RegisterInput({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
  });
}

/// Credentials for login.
class LoginInput {
  final String email;
  final String password;

  const LoginInput({required this.email, required this.password});
}

/// Auth data source contract. Screens depend on this interface, never on a
/// concrete implementation, so the mock and the real API are interchangeable.
abstract interface class AuthRepository {
  Future<AuthResult> login(LoginInput input);
  Future<AuthResult> register(RegisterInput input);
  Future<User> me();
  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? password,
    String? barCouncilNumber,
    String? chamberName,
    String? address,
    String? district,
    String? profilePhoto,
    int? yearsOfExperience,
    List<String>? practiceAreas,
    String? preferredCourt,
    String? appLanguage,
    Map<String, dynamic>? notificationSettings,
    Map<String, dynamic>? reminderSettings,
    bool? darkMode,
  });
  Future<void> logout();
}


