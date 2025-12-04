import 'package:admin_panel/core/error/exceptions.dart';
import 'package:admin_panel/features/shared/auth/data/models/user_model.dart';
import 'package:admin_panel/features/shared/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../fixtures/auth_fixtures.dart';
import '../../../../../helpers/fakes.dart';

void main() {
  late FakeAuthRemoteDataSource dataSource;

  setUp(() {
    dataSource = FakeAuthRemoteDataSource();
  });

  group('login', () {
    const tEmail = AuthFixtures.validEmail;
    const tPassword = AuthFixtures.validPassword;

    test(
      'should return UserModel when login is successful for admin',
      () async {
        // Act
        final result = await dataSource.login(tEmail, tPassword);

        // Assert
        expect(result, isA<UserModel>());
        expect(result.userType, UserType.admin);
        expect(result.email, tEmail);
        expect(result.isActive, true);
      },
    );

    test(
      'should return UserModel when login is successful for merchandiser',
      () async {
        // Act
        final result = await dataSource.login(
          'merchandiser@bytehub.com',
          tPassword,
        );

        // Assert
        expect(result, isA<UserModel>());
        expect(result.userType, UserType.merchandiser);
      },
    );

    test('should throw ServerException when user type is customer', () async {
      // Act & Assert
      expect(
        () => dataSource.login('customer@bytehub.com', tPassword),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('Invalid user type'),
          ),
        ),
      );
    });

    test('should throw ServerException when user is inactive', () async {
      // Act & Assert
      expect(
        () => dataSource.login('inactive@bytehub.com', tPassword),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Account has been deactivated',
          ),
        ),
      );
    });

    test('should throw ServerException when credentials are invalid', () async {
      // Act & Assert
      expect(
        () => dataSource.login(
          AuthFixtures.invalidEmail,
          AuthFixtures.invalidPassword,
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Invalid email or password',
          ),
        ),
      );
    });
  });

  group('logout', () {
    test('should complete successfully', () async {
      // Act & Assert
      expect(() => dataSource.logout(), returnsNormally);
    });

    test('should throw exception when logout fails', () async {
      // Arrange
      dataSource.shouldFail = true;
      dataSource.failureMessage = 'Logout failed';

      // Act & Assert
      expect(() => dataSource.logout(), throwsA(isA<ServerException>()));
    });
  });
}
