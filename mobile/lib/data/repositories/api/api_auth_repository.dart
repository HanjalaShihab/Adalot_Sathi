import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../models/user.dart';
import '../auth_repository.dart';

/// Real implementation of [AuthRepository] backed by the Adalot Sathi API.
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({required ApiClient apiClient, required TokenStorage tokenStorage})
      : _api = apiClient,
        _tokenStorage = tokenStorage;

  final ApiClient _api;
  final TokenStorage _tokenStorage;

  @override
  Future<AuthResult> login(LoginInput input) async {
    try {
      final response = await _api.dio.post('/login', data: input.toJson());
      return _handleAuthResponse(response);
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  @override
  Future<AuthResult> register(RegisterInput input) async {
    try {
      final response = await _api.dio.post('/register', data: input.toJson());
      return _handleAuthResponse(response);
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  AuthResult _handleAuthResponse(Response<dynamic> response) {
    final data = response.data as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    return AuthResult(token: token, user: user);
  }

  @override
  Future<User> me() async {
    try {
      final response = await _api.dio.get('/me');
      return User.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  @override
  Future<void> updateProfile({String? name, String? email, String? phone, String? password}) async {
    try {
      final data = <String, dynamic>{
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (password != null && password.isNotEmpty) 'password': password,
      };
      await _api.dio.put('/me', data: data);
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _api.dio.post('/logout');
    } catch (e) {
      // Swallow network errors during logout — the local token must be cleared regardless.
    } finally {
      await _tokenStorage.clear();
    }
  }
}

extension on LoginInput {
  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

extension on RegisterInput {
  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };
}


