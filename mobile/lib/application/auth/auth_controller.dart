import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/user.dart';
import '../../data/providers/repository_providers.dart';
import '../../data/repositories/auth_repository.dart';

/// Auth session state.
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isInitializing;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isInitializing = true,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isInitializing,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isInitializing: isInitializing ?? this.isInitializing,
    );
  }

  bool get isAuthenticated => user != null;
}

/// Manages the auth session: restore, login, register, logout, profile refresh.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Restore the session from the stored token.
    _restoreSession();
    return const AuthState(isInitializing: true);
  }

  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  Future<void> _restoreSession() async {
    final storage = ref.read(tokenStorageProvider);
    final hasToken = await storage.hasToken();
    if (!hasToken) {
      state = const AuthState(isInitializing: false);
      return;
    }
    try {
      final user = await _authRepository.me();
      state = AuthState(user: user, isInitializing: false);
    } on UnauthorizedException {
      await storage.clear();
      state = const AuthState(isInitializing: false);
    } catch (e) {
      // Network hiccup on restore — keep the token but mark unauthenticated so
      // the user can log in again; the token remains for retry.
      state = AuthState(
        isInitializing: false,
        error: e is AppException ? e.message : 'Failed to restore session.',
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authRepository.login(LoginInput(email: email, password: password));
      await ref.read(tokenStorageProvider).write(result.token);
      state = AuthState(user: result.user, isLoading: false, isInitializing: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : 'Login failed. Please try again.',
      );
      return false;
    }
  }

  Future<bool> register(RegisterInput input) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authRepository.register(input);
      await ref.read(tokenStorageProvider).write(result.token);
      state = AuthState(user: result.user, isLoading: false, isInitializing: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : 'Registration failed. Please try again.',
      );
      return false;
    }
  }

  Future<void> refreshUser() async {
    try {
      final user = await _authRepository.me();
      state = state.copyWith(user: user);
    } catch (_) {
      // Silent refresh failure — keep the cached user.
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AuthState(isInitializing: false);
  }

  void clearError() => state = state.copyWith(error: null);
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

/// Convenience provider for the current user.
final currentUserProvider = Provider<User?>(
  (ref) => ref.watch(authControllerProvider).user,
);


