import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the Sanctum auth token securely on-device.
///
/// This uses the real OS-backed secure storage (Keychain / Keystore), not a
/// mock — the only thing that changes between environments is the network call
/// that produces the token.
class TokenStorage {
  static const _tokenKey = 'adalot_sathi_auth_token';

  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> read() => _storage.read(key: _tokenKey);

  Future<void> write(String token) => _storage.write(key: _tokenKey, value: token);

  Future<void> clear() => _storage.delete(key: _tokenKey);

  Future<bool> hasToken() async => (await read())?.isNotEmpty ?? false;
}


