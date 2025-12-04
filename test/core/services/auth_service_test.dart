import 'package:flutter_test/flutter_test.dart';
import '../../helpers/fake_auth_service.dart';

void main() {
  late FakeAuthService authService;

  setUp(() {
    authService = FakeAuthService();
  });

  group('currentUserId', () {
    test('should return user ID when user is authenticated', () {
      // Arrange
      authService.setAuthenticatedUser('user-123', 'admin');

      // Act
      final result = authService.currentUserId;

      // Assert
      expect(result, 'user-123');
    });

    test('should return null when user is not authenticated', () {
      // Act
      final result = authService.currentUserId;

      // Assert
      expect(result, null);
    });
  });

  group('isAuthenticated', () {
    test('should return true when user is authenticated', () {
      // Arrange
      authService.setAuthenticatedUser('user-123', 'admin');

      // Act
      final result = authService.isAuthenticated;

      // Assert
      expect(result, true);
    });

    test('should return false when user is not authenticated', () {
      // Act
      final result = authService.isAuthenticated;

      // Assert
      expect(result, false);
    });
  });

  group('getMerchandiserId', () {
    test('should return merchandiser ID when user is merchandiser', () async {
      // Arrange
      authService.setAuthenticatedUser('profile-123', 'merchandiser');

      // Act
      final result = await authService.getMerchandiserId();

      // Assert
      expect(result, 'merchandiser-123');
    });

    test('should return null when user is not merchandiser', () async {
      // Arrange
      authService.setAuthenticatedUser('admin-123', 'admin');

      // Act
      final result = await authService.getMerchandiserId();

      // Assert
      expect(result, null);
    });
  });

  group('getUserType', () {
    test('should return "admin" for admin user', () async {
      // Arrange
      authService.setAuthenticatedUser('admin-123', 'admin');

      // Act
      final result = await authService.getUserType();

      // Assert
      expect(result, 'admin');
    });

    test('should return "merchandiser" for merchandiser user', () async {
      // Arrange
      authService.setAuthenticatedUser('merchandiser-123', 'merchandiser');

      // Act
      final result = await authService.getUserType();

      // Assert
      expect(result, 'merchandiser');
    });
  });

  group('isValidWebUser', () {
    test('should return true for admin user', () async {
      // Arrange
      authService.setAuthenticatedUser('admin-123', 'admin');

      // Act
      final result = await authService.isValidWebUser();

      // Assert
      expect(result, true);
    });

    test('should return true for merchandiser user', () async {
      // Arrange
      authService.setAuthenticatedUser('merchandiser-123', 'merchandiser');

      // Act
      final result = await authService.isValidWebUser();

      // Assert
      expect(result, true);
    });

    test('should return false for customer user', () async {
      // Arrange
      authService.setAuthenticatedUser('customer-123', 'customer');

      // Act
      final result = await authService.isValidWebUser();

      // Assert
      expect(result, false);
    });
  });
}
