import 'package:flutter_test/flutter_test.dart';
import 'package:pos/core/services/secure_storage_service.dart';

void main() {
  group('SecureStorageService & Platform Keychain Tests (TASK-5.3)', () {
    late SecureStorageService service;

    setUp(() {
      service = SecureStorageService();
    });

    test('Stores and retrieves authentication token securely', () async {
      await service.saveAuthToken('mock_jwt_token_header.payload.signature');
      final retrieved = await service.getAuthToken();
      expect(retrieved, 'mock_jwt_token_header.payload.signature');
    });

    test('Stores and retrieves refresh token securely', () async {
      await service.saveRefreshToken('mock_refresh_token_xyz987');
      final retrieved = await service.getRefreshToken();
      expect(retrieved, 'mock_refresh_token_xyz987');
    });

    test('Persists complete user session and cleans up fully upon logout', () async {
      await service.saveUserSession(
        email: 'rebecca@streamworks.app',
        token: 'token_123',
        refreshToken: 'refresh_456',
      );

      expect(await service.getAuthToken(), 'token_123');
      expect(await service.getRefreshToken(), 'refresh_456');

      // Logout / session cleanup
      await service.clearSession();

      expect(await service.getAuthToken(), isNull);
      expect(await service.getRefreshToken(), isNull);
    });
  });
}
