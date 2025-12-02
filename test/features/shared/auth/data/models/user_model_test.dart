import 'package:admin_panel/features/shared/auth/data/models/user_model.dart';
import 'package:admin_panel/features/shared/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../fixtures/auth_fixtures.dart';

void main() {
  group('UserModel', () {
    group('fromJson', () {
      test('should return valid admin UserModel', () {
        // Act
        final result = UserModel.fromJson(AuthFixtures.adminUserJson);

        // Assert
        expect(result, isA<UserModel>());
        expect(result.userType, UserType.admin);
        expect(result.email, 'admin@bytehub.com');
        expect(result.isActive, true);
      });

      test('should return valid merchandiser UserModel', () {
        // Act
        final result = UserModel.fromJson(AuthFixtures.merchandiserUserJson);

        // Assert
        expect(result.userType, UserType.merchandiser);
        expect(result.mustChangePassword, false);
      });

      test('should handle must_change_password flag', () {
        // Act
        final result = UserModel.fromJson(
          AuthFixtures.merchandiserNeedsPasswordChangeJson,
        );

        // Assert
        expect(result.mustChangePassword, true);
      });

      test('should throw FormatException for invalid user_type', () {
        // Arrange
        final invalidJson = {'user_type': 'invalid_type'};

        // Act & Assert
        expect(
          () => UserModel.fromJson(invalidJson),
          throwsA(isA<FormatException>()),
        );
      });

      test('should handle missing optional fields', () {
        // Arrange
        final minimalJson = {
          'id': 'test-123',
          'email': 'test@test.com',
          'user_type': 'admin',
        };

        // Act
        final result = UserModel.fromJson(minimalJson);

        // Assert
        expect(result.fullName, isNull);
        expect(result.token, isNull);
        expect(result.mustChangePassword, false);
        expect(result.isActive, true);
      });
    });

    group('toJson', () {
      test('should return valid JSON map', () {
        // Arrange
        const userModel = AuthFixtures.adminUser;

        // Act
        final result = userModel.toJson();

        // Assert
        expect(result['id'], 'admin-123');
        expect(result['email'], 'admin@bytehub.com');
        expect(result['user_type'], 'admin');
      });
    });
  });

  group('UserType', () {
    test('should convert string to UserType correctly', () {
      expect(UserType.fromString('admin'), UserType.admin);
      expect(UserType.fromString('ADMIN'), UserType.admin);
      expect(UserType.fromString('merchandiser'), UserType.merchandiser);
      expect(UserType.fromString('customer'), UserType.customer);
    });

    test('should throw ArgumentError for invalid type', () {
      expect(
        () => UserType.fromString('invalid'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should return correct display name', () {
      expect(UserType.admin.displayName, 'Admin');
      expect(UserType.merchandiser.displayName, 'Merchandiser');
      expect(UserType.customer.displayName, 'Customer');
    });
  });
}
