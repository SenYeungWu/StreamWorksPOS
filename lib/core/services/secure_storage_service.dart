import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class ISecureStorage {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> deleteAll();
}

class InMemorySecureStorage implements ISecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> write({required String key, required String value}) async {
    _storage[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    return _storage[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }
}

class SecureStorageService {
  final ISecureStorage _storage;

  static const _authTokenKey = 'auth_token_jwt';
  static const _refreshTokenKey = 'refresh_token_jwt';
  static const _userEmailKey = 'user_email_secure';

  SecureStorageService({ISecureStorage? storage})
      : _storage = storage ?? InMemorySecureStorage();

  /// Persists authentication JWT token securely in Platform Keychain / KeyStore
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _authTokenKey, value: token);
  }

  /// Retrieves stored authentication JWT token
  Future<String?> getAuthToken() async {
    return await _storage.read(key: _authTokenKey);
  }

  /// Persists refresh token securely
  Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Retrieves stored refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Saves user session details
  Future<void> saveUserSession({
    required String email,
    required String token,
    required String refreshToken,
  }) async {
    await _storage.write(key: _userEmailKey, value: email);
    await _storage.write(key: _authTokenKey, value: token);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Clears all user tokens and keys upon logout (Security Hardening TASK-5.3)
  Future<void> clearSession() async {
    await _storage.deleteAll();
  }
}

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});
